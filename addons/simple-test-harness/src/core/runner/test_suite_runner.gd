class_name TestSuiteRunner
extends Node2D

enum TestSuiteState {
    WAITING_SERVER_CONNECTION,
    WAITING_COMMAND,
    RUNNING_TESTS,
    ERROR_SERVER_DISCONNECTED,
    STOPPED_BY_USER,
    DONE,
}

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

@onready var _tcp_client:STHTCPClient = $sth_tcp_client

var _state:TestSuiteState

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _ready() -> void:
    # To start, we wait for server connection
    _state = TestSuiteState.WAITING_SERVER_CONNECTION

    # Setup tcp client, the one that will connect to test server
    _tcp_client.on_connection.connect(_on_sth_tcp_client_connected)
    _tcp_client.on_message_received.connect(_on_sth_tcp_client_message_received)
    _tcp_client.on_disconnection.connect(_on_sth_tcp_client_disconnected)
    _tcp_client.start()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_sth_tcp_client_connected() -> void:
    _state = TestSuiteState.WAITING_COMMAND
    _tcp_client.send_data(STHRunnerMessageHandler.create_message(STHTestsuiteClientReady.new()))

func _on_sth_tcp_client_message_received(message:String) -> void:
    var message_as_object:Variant = STHRunnerMessageHandler.get_message(message)

    if message_as_object is STHStopTestsuite:
        _stop_testsuite(message_as_object)
    if message_as_object is STHRunSingleTestCommand or message_as_object is STHRunTestsCommand:
        var execution_plan:STHExecutionPlan
        if message_as_object is STHRunSingleTestCommand:
            execution_plan = _prepare_single_test_method_plan(message_as_object)
        elif message_as_object is STHRunTestsCommand:
            execution_plan = _prepare_tests_plan(message_as_object)

        var plan_ready_message:STHTestsuitePlanReady = STHTestsuitePlanReady.new()
        plan_ready_message.plan = execution_plan
        _notify_test_suite_plan_ready(plan_ready_message)
        _execute_execution_plan(execution_plan)

func _on_sth_tcp_client_disconnected() -> void:
    _state = TestSuiteState.ERROR_SERVER_DISCONNECTED

func _prepare_tests_plan(command:STHRunTestsCommand) -> STHExecutionPlan:
    var execution_plan:STHExecutionPlan = STHExecutionPlan.new()

    # Just scan for test cases and add it all in exec plan !
    var test_case_finder:TestCaseFinder = TestCaseFinder.new()
    test_case_finder.lookup_paths = command.lookup_paths
    execution_plan.test_case_plans = test_case_finder.execute()

    return execution_plan

func _prepare_single_test_method_plan(command:STHRunSingleTestCommand) -> STHExecutionPlan:
    var execution_plan:STHExecutionPlan = STHExecutionPlan.new()

    # First, find the corresponding test case plan. Should find only one !
    var test_case_finder:TestCaseFinder = TestCaseFinder.new()
    test_case_finder.lookup_paths = [command.test_case_path]
    var test_case_plans:Array[STHTestCasePlan] = test_case_finder.execute()
    if test_case_plans.size() > 1:
        push_error("Multiple test case plans when running a single test method command (path: %s, method: %s)" % [command.test_case_path, command.test_case_method_name])
    elif test_case_plans.is_empty():
        push_error("No test case plan found when running a single test method command (path: %s, method: %s)" % [command.test_case_path, command.test_case_method_name])
    else:
        # It's ok from there
        # Remove from plan methods not corresponding to the ask method
        var test_case_plan:STHTestCasePlan = test_case_plans[0]
        var new_methods:Array[STHTestCaseMethodPlan] = []
        for method in test_case_plan.test_case_methods:
            if method.test_method_name == command.test_case_method_name:
                new_methods.append(method)
                break
        test_case_plan.test_case_methods = new_methods
        execution_plan.test_case_plans = [test_case_plan]
    return execution_plan

func _execute_execution_plan(execution_plan:STHExecutionPlan) -> void:
    _state = TestSuiteState.RUNNING_TESTS

    _notify_test_suite_started()

    var plan_start_time_ms:int = Time.get_ticks_msec()

    for test_case in execution_plan.test_case_plans:
        # Recheck if testsuite must continue or not
        if _state == TestSuiteState.RUNNING_TESTS:
            var runner:TestCaseRunner = preload("res://addons/simple-test-harness/src/core/runner/test_case_runner.tscn").instantiate()
            add_child(runner)
            await Engine.get_main_loop().process_frame
            runner.tcp_client = _tcp_client
            runner.call_deferred("execute", test_case)
            await runner.completed
            remove_child(runner)
            await Engine.get_main_loop().process_frame
        else:
            if _state == TestSuiteState.STOPPED_BY_USER:
                print("TestSuite aborted by user")
            else:
                push_error("Testsuite stopped for unknown reason, state is %s" % TestSuiteState.keys()[_state])

    var plan_stop_time_ms:int = Time.get_ticks_msec()
    var execution_time_ms:int = plan_stop_time_ms - plan_start_time_ms

    _notify_test_suite_finished(execution_time_ms)

    _state = TestSuiteState.DONE
    get_tree().quit()

func _stop_testsuite(_object:STHStopTestsuite) -> void:
    _state = TestSuiteState.STOPPED_BY_USER

func _notify_test_suite_plan_ready(plan:STHTestsuitePlanReady) -> void:
    _tcp_client.send_data(STHRunnerMessageHandler.create_message(plan))

func _notify_test_suite_started() -> void:
    var ts_started_message:STHTestsuiteStarted = STHTestsuiteStarted.new()
    ts_started_message.start_datetime = Time.get_datetime_string_from_system()
    _tcp_client.send_data(STHRunnerMessageHandler.create_message(ts_started_message))

func _notify_test_suite_finished(execution_time_ms:int) -> void:
    var finished_message:STHTestsuiteFinished = STHTestsuiteFinished.new()
    finished_message.finish_datetime = Time.get_datetime_string_from_system()
    finished_message.duration_ms = execution_time_ms
    finished_message.aborted = _state != TestSuiteState.RUNNING_TESTS
    _tcp_client.send_data(STHRunnerMessageHandler.create_message(finished_message))

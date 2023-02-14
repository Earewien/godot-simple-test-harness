class_name TestCaseRunner
extends Node

#------------------------------------------
# Signaux
#------------------------------------------

signal completed
signal method_completed

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var tcp_client:STHTCPClient
var aborted:bool = false

#------------------------------------------
# Variables privées
#------------------------------------------

var _number_of_successful_method:int = 0
var _number_of_skipped_method:int = 0
var _number_of_failed_method:int = 0
var _number_of_aborted_method:int = 0

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute(test_case_plan:STHTestCasePlan) -> void:
    _notify_test_case_started(test_case_plan)



    # Pas de constructeur, on passe !
    if not test_case_plan.has_default_constructor:
        # On prend toutes les méthodes, et on skip !
        for test_method in test_case_plan.test_case_methods:
            var method_report:STHTestCaseMethodReport = STHTestCaseMethodReport.new()
            method_report.test_case_name = test_case_plan.test_case_name
            method_report.test_case_path = test_case_plan.test_case_path
            method_report.method_name = test_method.test_method_name
            method_report.line_number = test_method.test_method_line_number
            method_report.execution_time_ms = 0
            method_report.result = STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED
            method_report.result_description = "No _init function with 0 argument. Cannot instantiate script."
            _number_of_skipped_method += 1
            _notify_test_case_method_report(method_report)
        _notify_test_case_skipped(test_case_plan)
    else:
        # On doit pouvoir instantier le script ici ...
        # Le script étend TestCase, donc on a des méthodes connues !
        var tested_script:GDScript = GDScriptFactory.get_gdscript(test_case_plan.test_case_path)
        if tested_script.get_meta(GDScriptFactory.META_LOAD_ERROR) != OK:
            # Something went wrong while loading script, report it and pass
            _notify_test_case_failed(test_case_plan, tested_script.get_meta(GDScriptFactory.META_LOAD_ERROR))
        else:
            var test_case_start_time_ms:int = Time.get_ticks_msec()
            # BEFORE ALL
            tested_script.beforeAll()

            for test_method in test_case_plan.test_case_methods:
                var tested_script_instance:TestCase = tested_script.new()
                call_deferred("_execute_method", test_case_plan, tested_script_instance, test_method)
                await method_completed
                tested_script_instance.free()

            # AFTER ALL
            tested_script.afterAll()

            var test_case_stop_time_ms:int = Time.get_ticks_msec()
            var execution_time_ms:int = test_case_stop_time_ms - test_case_start_time_ms

            _notify_test_case_finished(test_case_plan, execution_time_ms)

    completed.emit()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _execute_method(test_case_plan:STHTestCasePlan, test_script_instance:TestCase, test_method:STHTestCaseMethodPlan) -> void:
    _notify_test_case_method_started(test_case_plan, test_method)

    var method_report:STHTestCaseMethodReport = STHTestCaseMethodReport.new()
    method_report.test_case_name = test_case_plan.test_case_name
    method_report.test_case_path = test_case_plan.test_case_path
    method_report.method_name = test_method.test_method_name
    method_report.line_number = test_method.test_method_line_number

    if aborted:
        # Report aborted test
        method_report.execution_time_ms = 0
        method_report.result = STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_ABORTED
    # TODO parametrized method not yet supported
    elif test_method.test_method_arguments_count > 0:
        method_report.execution_time_ms = 0
        method_report.result = STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED
        method_report.result_description = "Parametrized test not yet supported"
    else:
        var godot_log_handler:GodotLogHandler = GodotLogHandler.new()

        var test_case_method_start_time_ms:int = Time.get_ticks_msec()

        # INIT
        var assertion_reporter:AssertionReporter = AssertionReporter.new(test_method.test_method_name)
        test_script_instance._set_assertion_reporter(assertion_reporter)
        add_child(test_script_instance)

        # BEFORE
        test_script_instance.beforeEach()

        # TEST
        await test_script_instance.call(test_method.test_method_name)
        # Give some time to Godot to do defered calls
        await get_tree().process_frame

        # AFTER
        test_script_instance.afterEach()

        # FINALIZE
         # Give some time to Godot to do defered calls
        await get_tree().process_frame
        remove_child(test_script_instance)

        # TIME REPORT
        var test_case_method_stop_time_ms:int = Time.get_ticks_msec()
        method_report.execution_time_ms = test_case_method_stop_time_ms - test_case_method_start_time_ms

        # SET LOGS
        var test_logs:PackedStringArray = godot_log_handler.get_log_content()
        method_report.logs = test_logs

        # ANALYZE SCRIPT ERRORS
        var log_analyzer:GogotErrorLogAnalyzer = GogotErrorLogAnalyzer.new()
        var error_descriptor:GodotErrorLogDescriptor = log_analyzer.analyze(test_logs)

        # Keep assertion reports
        for ar in assertion_reporter.assertion_reports:
            var ser_ass_report:STHTestCaseAssertionReport = STHTestCaseAssertionReport.new()
            ser_ass_report.is_success = ar.is_success
            ser_ass_report.line_number = ar.line_number
            ser_ass_report.description = ar.description
            method_report.assertion_reports.append(ser_ass_report)

        if error_descriptor:
            # In case of error (script, ..), add a failed AR to pass test in failure
            method_report.result = STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_FAILURE
            var script_error_assertion_report:STHTestCaseAssertionReport = STHTestCaseAssertionReport.new()
            script_error_assertion_report.is_success = false
            script_error_assertion_report.description = error_descriptor.error_description
            script_error_assertion_report.line_number = error_descriptor.error_line_number
            method_report.assertion_reports.append(script_error_assertion_report)
        else:
            method_report.result = STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_FAILURE if assertion_reporter.has_failures() else STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_SUCCESS

        godot_log_handler.close()

    if method_report.result == STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_SUCCESS:
        _number_of_successful_method += 1
    elif method_report.result == STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED:
        _number_of_skipped_method += 1
    elif method_report.result == STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_FAILURE:
        _number_of_failed_method += 1
    elif method_report.result == STHTestCaseMethodReport.TEST_CASE_METHOD_RESULT_ABORTED:
        _number_of_aborted_method += 1

    _notify_test_case_method_report(method_report)

    method_completed.emit()


func _notify_test_case_started(test_case_plan:STHTestCasePlan) -> void:
    var tc_started_message:STHTestCaseStarted = STHTestCaseStarted.new()
    tc_started_message.test_case_name = test_case_plan.test_case_name
    tc_started_message.test_case_path = test_case_plan.test_case_path
    tcp_client.send_data(STHRunnerMessageHandler.create_message(tc_started_message))

func _notify_test_case_method_started(test_case_plan:STHTestCasePlan, test_method:STHTestCaseMethodPlan) -> void:
    var tcm_started_message:STHTestCaseMethodStarted = STHTestCaseMethodStarted.new()
    tcm_started_message.test_case_name = test_case_plan.test_case_name
    tcm_started_message.test_case_path = test_case_plan.test_case_path
    tcm_started_message.test_case_method_name = test_method.test_method_name
    tcp_client.send_data(STHRunnerMessageHandler.create_message(tcm_started_message))

func _notify_test_case_method_report(report:STHTestCaseMethodReport) -> void:
    tcp_client.send_data(STHRunnerMessageHandler.create_message(report))

func _notify_test_case_skipped(test_case_plan:STHTestCasePlan) -> void:
    var tc_skipped_message:STHTestCaseFinished = STHTestCaseFinished.new()
    tc_skipped_message.test_case_name = test_case_plan.test_case_name
    tc_skipped_message.test_case_path = test_case_plan.test_case_path
    tc_skipped_message.test_case_execution_time_ms = 0
    tc_skipped_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_SKIPPED
    tcp_client.send_data(STHRunnerMessageHandler.create_message(tc_skipped_message))

func _notify_test_case_failed(test_case_plan:STHTestCasePlan, error:int) -> void:
    var tc_failed_message:STHTestCaseFinished = STHTestCaseFinished.new()
    tc_failed_message.test_case_name = test_case_plan.test_case_name
    tc_failed_message.test_case_path = test_case_plan.test_case_path
    tc_failed_message.test_case_execution_time_ms = 0
    tc_failed_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_FAILED
    tc_failed_message.test_case_result_description = "Unable to load script : %s" % error_string(error)
    tcp_client.send_data(STHRunnerMessageHandler.create_message(tc_failed_message))

func _notify_test_case_finished(test_case_plan:STHTestCasePlan, execution_time_ms:int) -> void:
    var tc_finished_message:STHTestCaseFinished = STHTestCaseFinished.new()
    tc_finished_message.test_case_name = test_case_plan.test_case_name
    tc_finished_message.test_case_path = test_case_plan.test_case_path
    tc_finished_message.test_case_execution_time_ms = execution_time_ms
    if _number_of_skipped_method > 0:
        if _number_of_failed_method > 0 or _number_of_successful_method > 0:
            tc_finished_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_UNSTABLE
        else:
            tc_finished_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_SKIPPED
    elif _number_of_failed_method > 0:
        if _number_of_skipped_method > 0 or _number_of_successful_method > 0:
            tc_finished_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_UNSTABLE
        else:
            tc_finished_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_FAILED
    elif _number_of_aborted_method > 0:
        tc_finished_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_ABORTED
    else:
        tc_finished_message.test_case_status = STHTestCaseFinished.TEST_CASE_STATUS_SUCCESSFUL

    tcp_client.send_data(STHRunnerMessageHandler.create_message(tc_finished_message))

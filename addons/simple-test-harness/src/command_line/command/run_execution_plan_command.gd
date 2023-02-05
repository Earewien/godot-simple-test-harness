class_name RunExecutionPlanCommand
extends Node

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

var _execution_plan:BuildExecutionPlanReport

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(execution_plan_path:String) -> void:
    _execution_plan = BuildExecutionPlanReport.deserialize(str_to_var(FileAccess.get_file_as_string(execution_plan_path)))

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> RunExecutionPlanReport:
    var report:RunExecutionPlanReport = RunExecutionPlanReport.new()

    report.execution_date_time = Time.get_datetime_string_from_system(false, true)

    var plan_start_time_ms:int = Time.get_ticks_msec()

    for test_case in _execution_plan.test_case_plan:
        var test_case_report:TestCaseReport = TestCaseReport.from(test_case)
        var runner:TestCaseRunner = TestCaseRunner.new(test_case, test_case_report)
        var scene_tree:SceneTree = Engine.get_main_loop()
        add_child(runner)
        await Engine.get_main_loop().process_frame
        runner.call_deferred("execute")
        await runner.completed
        remove_child(runner)
        await Engine.get_main_loop().process_frame
        report.test_case_reports.append(test_case_report)

    var plan_stop_time_ms:int = Time.get_ticks_msec()
    report.execution_time_ms = plan_stop_time_ms - plan_start_time_ms

    return report

#------------------------------------------
# Fonctions privées
#------------------------------------------

class TestCaseRunner extends Node:

    signal completed
    signal method_completed

    var test_case_plan:TestCasePlan
    var test_case_report:TestCaseReport

    func _init(tcp:TestCasePlan, tcr:TestCaseReport) -> void:
        test_case_plan = tcp
        test_case_report = tcr

    func execute() -> void:
        # Pas de constructeur, on passe !
        if not test_case_plan.has_default_constructor:
            # On prend toutes les méthodes, et on skip !
            for method_plan in test_case_plan.test_case_methods:
                var method_report:TestCaseMethodReport = TestCaseMethodReport.new()
                method_report.method_name = method_plan.test_method_name
                method_report.line_number = method_plan.test_method_line_number
                method_report.execution_time_ms = 0
                method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED
                method_report.result_description = "No _init function with 0 argument. Cannot instantiate script."
                test_case_report.method_reports.append(method_report)
                completed.emit()
            return

        # On doit pouvoir instantier le script ici ...
        # Le script étend TestCase, donc on a des méthodes connues !
        var tested_script:GDScript = ResourceLoader.load(test_case_plan.test_case_path)

        var test_case_start_time_ms:int = Time.get_ticks_msec()

        # BEFORE ALL
        tested_script.beforeAll()

        for method_plan in test_case_plan.test_case_methods:
            var tested_script_instance:TestCase = tested_script.new()
            call_deferred("_execute_method", tested_script_instance, method_plan)
            await method_completed

        # AFTER ALL
        tested_script.afterAll()

        var test_case_stop_time_ms:int = Time.get_ticks_msec()
        test_case_report.execution_time_ms = test_case_stop_time_ms - test_case_start_time_ms

        completed.emit()

    func _execute_method(test_script_instance:TestCase, method_plan:TestCaseMethodPlan) -> void:
        var method_report:TestCaseMethodReport = TestCaseMethodReport.new()
        method_report.method_name = method_plan.test_method_name
        method_report.line_number = method_plan.test_method_line_number

        # TODO parametrized method not yet supported
        if method_plan.test_method_arguments_count > 0:
            method_report.execution_time_ms = 0
            method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED
            method_report.result_description = "Parametrized test not yet supported"
        else:
            var test_case_method_start_time_ms:int = Time.get_ticks_msec()

            # INIT
            var assertion_reporter:AssertionReporter = AssertionReporter.new(method_plan.test_method_name)
            test_script_instance._set_assertion_reporter(assertion_reporter)
            add_child(test_script_instance)

            # BEFORE
            test_script_instance.beforeEach()
            # TEST
            if method_plan.is_coroutine:
                await test_script_instance.call(method_plan.test_method_name)
            else:
                test_script_instance.call(method_plan.test_method_name)

            # AFTER
            test_script_instance.afterEach()

            # FINALIZE
            remove_child(test_script_instance)

            var test_case_method_stop_time_ms:int = Time.get_ticks_msec()
            method_report.execution_time_ms = test_case_method_stop_time_ms - test_case_method_start_time_ms
            method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_FAILURE if assertion_reporter.has_failures() else TestCaseMethodReport.TEST_CASE_METHOD_RESULT_SUCCESS
            method_report.assertion_reports = assertion_reporter.assertion_reports

        test_case_report.method_reports.append(method_report)

        method_completed.emit()

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

var test_case_report:TestCaseReport

#------------------------------------------
# Variables privées
#------------------------------------------

var _descriptor:TestCaseRunnerDescriptor

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(descriptor:TestCaseRunnerDescriptor) -> void:
    _descriptor = descriptor

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> void:
    test_case_report = TestCaseReport.new()
    test_case_report.test_case_name = _descriptor.test_case_name
    test_case_report.test_case_path = _descriptor.test_case_path

    # Pas de constructeur, on passe !
    if not _descriptor.test_case_has_default_constructor:
        # On prend toutes les méthodes, et on skip !
        for test_method in _descriptor.test_case_test_methods:
            var method_report:TestCaseMethodReport = TestCaseMethodReport.new()
            method_report.method_name = test_method["name"]
            method_report.line_number = test_method["line_number"]
            method_report.execution_time_ms = 0
            method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED
            method_report.result_description = "No _init function with 0 argument. Cannot instantiate script."
            test_case_report.method_reports.append(method_report)
            completed.emit()
        return

    # On doit pouvoir instantier le script ici ...
    # Le script étend TestCase, donc on a des méthodes connues !
    var tested_script:GDScript = ResourceLoader.load(_descriptor.test_case_path)

    var test_case_start_time_ms:int = Time.get_ticks_msec()

    # BEFORE ALL
    tested_script.beforeAll()

    for test_method in _descriptor.test_case_test_methods:
        var tested_script_instance:TestCase = tested_script.new()
        call_deferred("_execute_method", test_case_report, tested_script_instance, test_method)
        await method_completed

    # AFTER ALL
    tested_script.afterAll()

    var test_case_stop_time_ms:int = Time.get_ticks_msec()
    test_case_report.execution_time_ms = test_case_stop_time_ms - test_case_start_time_ms

    completed.emit()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _execute_method(test_case_report:TestCaseReport, test_script_instance:TestCase, test_method:Dictionary) -> void:
    var godot_log_handler:GodotLogHandler = GodotLogHandler.new()

    var method_report:TestCaseMethodReport = TestCaseMethodReport.new()
    method_report.method_name = test_method["name"]
    method_report.line_number = test_method["line_number"]

    # TODO parametrized method not yet supported
    if test_method["arg_count"] > 0:
        method_report.execution_time_ms = 0
        method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_SKIPPED
        method_report.result_description = "Parametrized test not yet supported"
    else:
        var test_case_method_start_time_ms:int = Time.get_ticks_msec()

        # INIT
        var assertion_reporter:AssertionReporter = AssertionReporter.new(test_method["name"])
        test_script_instance._set_assertion_reporter(assertion_reporter)
        add_child(test_script_instance)

        # BEFORE
        test_script_instance.beforeEach()

        # TEST
        await test_script_instance.call(test_method["name"])

        # AFTER
        test_script_instance.afterEach()

        # FINALIZE
        remove_child(test_script_instance)

        # TIME REPORT
        var test_case_method_stop_time_ms:int = Time.get_ticks_msec()
        method_report.execution_time_ms = test_case_method_stop_time_ms - test_case_method_start_time_ms

        # ANALYZE SCRIPT ERRORS
        var log_analyzer:GogotErrorLogAnalyzer = GogotErrorLogAnalyzer.new()
        var error_descriptor:GodotErrorLogDescriptor = log_analyzer.analyze(godot_log_handler.get_log_content())

        if error_descriptor:
            method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_FAILURE
            var script_error_assertion_report:TestCaseAssertionReport = TestCaseAssertionReport.new()
            script_error_assertion_report.is_success = false
            script_error_assertion_report.description = error_descriptor.error_description
            script_error_assertion_report.line_number = error_descriptor.error_line_number
            # L'erreur de script peut dépendre d'une assertion en échec en amont
            # On les garde donc !
            method_report.assertion_reports.append_array(assertion_reporter.assertion_reports)
            method_report.assertion_reports.append(script_error_assertion_report)
        else:
            method_report.result = TestCaseMethodReport.TEST_CASE_METHOD_RESULT_FAILURE if assertion_reporter.has_failures() else TestCaseMethodReport.TEST_CASE_METHOD_RESULT_SUCCESS
            method_report.assertion_reports = assertion_reporter.assertion_reports

    test_case_report.method_reports.append(method_report)

    godot_log_handler.close()

    method_completed.emit()

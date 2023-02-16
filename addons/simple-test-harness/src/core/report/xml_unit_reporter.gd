class_name XMLUnitReporter
extends RefCounted

const XML_FILE_DEF:String = """<?xml version="1.0" encoding="utf-8"?>"""
const XML_TESTSUITES_TEMPLATE:String = \
"""
<testsuites id="%s" name="%s" time="%s">
%s
</testsuites>
"""

const XML_TESTSUITE_TEMPLATE:String = \
"""
    <testsuite name="%s" tests="%s" failures="%s" skipped="%s" time="%s">
    %s
    </testsuite>
"""

const XML_TESTCASE_TEMPLATE:String = \
"""
        <testcase name="%s" classname="%s" time="%s">
        %s
        </testcase>
"""

const XML_ERROR_TEMPLATE:String = \
"""
            <error message="%s" type="%s">
%s
            </error>
"""

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var output_directory:String = "res://"

#------------------------------------------
# Variables privées
#------------------------------------------

var _testsuite_start_datetime:String
var _testsuite_duration:int
var _test_cases:Dictionary = {}
var _testsuite_successful:bool = true

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init() -> void:
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_runner_message_received.connect(_on_orchestrator_runner_message_received)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_last_testsuite_successful() -> bool:
    return _testsuite_successful

func finalize() -> void:
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_runner_message_received.disconnect(_on_orchestrator_runner_message_received)

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_orchestrator_runner_message_received(message) -> void:
    if message is STHTestsuiteStarted:
        _registrer_test_suite_started_report(message)
    elif message is STHTestCaseMethodReport:
        _registrer_test_case_method_report(message)
    elif message is STHTestCaseFinished:
        _register_test_case_report(message)
    elif message is STHTestsuiteFinished:
        _register_test_suite_finished_report(message)

func _registrer_test_suite_started_report(report:STHTestsuiteStarted) -> void:
    _reset_reporter_state()
    _testsuite_start_datetime = report.start_datetime

func _registrer_test_case_method_report(report:STHTestCaseMethodReport) -> void:
    if not _test_cases.has(report.test_case_path):
        _test_cases[report.test_case_path] = {
            "test_case_path" : report.test_case_path,
            "test_case_name" : report.test_case_name,
            "test_case_methods" : []
        }

    var method_report:Dictionary = {
        "name" : report.method_name,
        "failed" : report.is_failed(),
        "skipped" : report.is_aborted() or report.is_skipped(),
        "errors" : [],
        "logs" : report.logs,
        "duration" : report.execution_time_ms
    }
    _test_cases[report.test_case_path]["test_case_methods"].append(method_report)
    for ar in report.assertion_reports:
        if not ar.is_success:
            method_report["errors"].append(ar.description)
    if not report.is_successful() and not report.result_description.is_empty():
        method_report["errors"].append(report.result_description)

func _register_test_case_report(report:STHTestCaseFinished) -> void:
    if not _test_cases.has(report.test_case_path):
        _test_cases[report.test_case_path] = {
            "test_case_path" : report.test_case_path,
            "test_case_name" : report.test_case_name,
            "test_case_methods" : []
        }
    _test_cases[report.test_case_path]["duration"] = report.test_case_execution_time_ms

func _register_test_suite_finished_report(report:STHTestsuiteFinished) -> void:
    _testsuite_duration = report.duration_ms

    _do_report()
    _reset_reporter_state()

func _do_report() -> void:
    if not DirAccess.dir_exists_absolute(output_directory):
        var error:int = DirAccess.make_dir_recursive_absolute(output_directory)
        if error != OK:
            push_error("Unable to create durectory %s : %s" % [output_directory, error_string(error)])
            return


    var test_suites_report:String = ""

    # Build down to top !
    for key in _test_cases.keys():
        var tc_report:Dictionary = _test_cases[key]
        var test_cases_report:String = ""
        var error_count:int = 0
        var skip_count:int = 0
        for method_report in tc_report["test_case_methods"]:
            if method_report["failed"]:
                error_count += 1
            if method_report["skipped"]:
                skip_count += 1
            var method_error_report:String = ""
            for method_error in method_report["errors"]:
                method_error_report += XML_ERROR_TEMPLATE % [method_error, "FAILURE", "\n".join(method_report["logs"]).strip_edges()]
            var test_case_report:String = XML_TESTCASE_TEMPLATE % [method_report["name"], method_report["name"], method_report["duration"], method_error_report]
            test_cases_report += test_case_report
        var test_suite_report:String = XML_TESTSUITE_TEMPLATE % [
            tc_report["test_case_name"],
            tc_report["test_case_methods"].size(),
            error_count,
            skip_count,
            tc_report["duration"],
            test_cases_report
        ]
        test_suites_report += test_suite_report

        if error_count > 0:
            _testsuite_successful = false

    var report_content:String = XML_FILE_DEF + "\n" + XML_TESTSUITES_TEMPLATE % [
        _testsuite_start_datetime,
        "report_%s" % _testsuite_start_datetime,
        _testsuite_duration,
        test_suites_report
    ]

    var report_filename:String = "report_%s.xml" %_testsuite_start_datetime.replace(":", "_")
    var file:FileAccess = FileAccess.open(output_directory.path_join(report_filename).simplify_path(), FileAccess.WRITE)
    file.store_string(report_content)
    file.flush()

func _reset_reporter_state() -> void:
    _testsuite_successful = true
    _testsuite_start_datetime = ""
    _test_cases.clear()
    _testsuite_duration = 0

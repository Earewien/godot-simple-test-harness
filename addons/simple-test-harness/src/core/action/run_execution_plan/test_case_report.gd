class_name TestCaseReport
extends RefCounted

enum {
    TEST_CASE_REPORT_STATE_SUCCESS,
    TEST_CASE_REPORT_STATE_FAILURE,
    TEST_CASE_REPORT_STATE_SKIPPED,
    TEST_CASE_REPORT_STATE_UNSTABLE
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

var test_case_name:String
var test_case_path:String
var execution_time_ms:int
var method_reports:Array[TestCaseMethodReport] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func from(plan:TestCasePlan) -> TestCaseReport:
    var report:TestCaseReport = TestCaseReport.new()
    report.test_case_name = plan.test_case_name
    report.test_case_path = plan.test_case_path
    return report

static func deserialize(data:Dictionary) -> TestCaseReport:
    var report:TestCaseReport = TestCaseReport.new()
    report.test_case_name = data["test_case_name"]
    report.test_case_path = data["test_case_path"]
    report.execution_time_ms = data["execution_time_ms"]
    for smr in data["method_reports"]:
        report.method_reports.append(TestCaseMethodReport.deserialize(smr))
    return report

func serialize() -> Dictionary:
    return {
        "test_case_name" : test_case_name,
        "test_case_path" : test_case_path,
        "execution_time_ms" : execution_time_ms,
        "method_reports" : method_reports.map(func(mr):return mr.serialize())
    }

func get_state() -> int:
    var success_count:int = 0
    var failure_count:int = 0
    var skip_count:int = 0

    for method_report in method_reports:
        if method_report.is_successful():
            success_count += 1
        elif method_report.is_skipped():
            skip_count += 1
        elif method_report.is_failed():
            failure_count += 1

    if failure_count == method_reports.size():
        return TEST_CASE_REPORT_STATE_FAILURE
    elif skip_count == method_reports.size():
        return TEST_CASE_REPORT_STATE_SKIPPED
    elif success_count == method_reports.size():
        return TEST_CASE_REPORT_STATE_SUCCESS
    else:
        return TEST_CASE_REPORT_STATE_UNSTABLE

#------------------------------------------
# Fonctions privées
#------------------------------------------


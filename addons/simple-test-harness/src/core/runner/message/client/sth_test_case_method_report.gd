class_name STHTestCaseMethodReport
extends RefCounted

enum {
    TEST_CASE_METHOD_RESULT_SUCCESS,
    TEST_CASE_METHOD_RESULT_FAILURE,
    TEST_CASE_METHOD_RESULT_SKIPPED
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
var method_name:String
var line_number:int = -1
var execution_time_ms:int
var result:int
var result_description:String
var assertion_reports:Array[STHTestCaseAssertionReport] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) -> STHTestCaseMethodReport:
    var report:STHTestCaseMethodReport = STHTestCaseMethodReport.new()
    report.test_case_name = data["test_case_name"]
    report.test_case_path = data["test_case_path"]
    report.method_name = data["method_name"]
    report.line_number = data["line_number"]
    report.execution_time_ms = data["execution_time_ms"]
    report.result = data["result"]
    report.result_description = data["result_description"]
    for sar in data["assertion_reports"]:
        report.assertion_reports.append(STHTestCaseAssertionReport.deserialize(sar))
    return report

func serialize() -> Dictionary:
    return {
        "test_case_name" : test_case_name,
        "test_case_path" : test_case_path,
        "method_name" : method_name,
        "line_number" : line_number,
        "execution_time_ms" : execution_time_ms,
        "result" : result,
        "result_description" : result_description,
        "assertion_reports" : assertion_reports.map(func(ar):return ar.serialize())
    }

func get_type() -> String:
    return "STHTestCaseMethodReport"

func is_successful() -> bool:
    return result == TEST_CASE_METHOD_RESULT_SUCCESS

func is_skipped() -> bool:
    return result == TEST_CASE_METHOD_RESULT_SKIPPED

func is_failed() -> bool:
    return result == TEST_CASE_METHOD_RESULT_FAILURE

#------------------------------------------
# Fonctions privées
#------------------------------------------


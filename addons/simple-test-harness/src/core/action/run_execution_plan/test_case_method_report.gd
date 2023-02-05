class_name TestCaseMethodReport
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

var method_name:String
var line_number:int = -1
var execution_time_ms:int
var result:int
var result_description:String
var assertion_reports:Array[TestCaseAssertionReport] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) -> TestCaseMethodReport:
    var method_result:TestCaseMethodReport = TestCaseMethodReport.new()
    method_result.method_name = data["method_name"]
    method_result.line_number = data["line_number"]
    method_result.execution_time_ms = data["execution_time_ms"]
    method_result.result = data["result"]
    method_result.result_description = data["result_description"]
    for sar in data["assertion_reports"]:
        method_result.assertion_reports.append(TestCaseAssertionReport.deserialize(sar))
    return method_result

func serialize() -> Dictionary:
    return {
        "method_name" : method_name,
        "line_number" : line_number,
        "execution_time_ms" : execution_time_ms,
        "result" : result,
        "result_description" : result_description,
        "assertion_reports" : assertion_reports.map(func(ar):return ar.serialize())
    }

func is_successful() -> bool:
    return result == TEST_CASE_METHOD_RESULT_SUCCESS

func is_skipped() -> bool:
    return result == TEST_CASE_METHOD_RESULT_SKIPPED

func is_failed() -> bool:
    return result == TEST_CASE_METHOD_RESULT_FAILURE

#------------------------------------------
# Fonctions privées
#------------------------------------------


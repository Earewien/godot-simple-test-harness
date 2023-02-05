class_name RunExecutionPlanReport
extends RefCounted

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var execution_date_time:String
var execution_time_ms:int
var test_case_reports:Array[TestCaseReport] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) -> RunExecutionPlanReport:
    var report:RunExecutionPlanReport = RunExecutionPlanReport.new()
    report.execution_date_time = data["execution_date_time"]
    report.execution_time_ms = data["execution_time_ms"]
    for stcr in data["test_case_reports"]:
        report.test_case_reports.append(TestCaseReport.deserialize(stcr))
    return report

func serialize() -> Dictionary:
    return {
        "execution_date_time": execution_date_time,
        "execution_time_ms" : execution_time_ms,
        "test_case_reports" : test_case_reports.map(func(tcr):return tcr.serialize())
    }

#------------------------------------------
# Fonctions privées
#------------------------------------------


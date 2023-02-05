class_name BuildExecutionPlanReport
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

var test_case_plan:Array[TestCasePlan] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) -> BuildExecutionPlanReport:
    var report:BuildExecutionPlanReport = BuildExecutionPlanReport.new()
    for stcp in data["test_case_plan"]:
        report.test_case_plan.append(TestCasePlan.deserialize(stcp))
    return report

func serialize() -> Dictionary:
    return {
        "test_case_plan" : test_case_plan.map(func(tcp):return tcp.serialize())
    }

#------------------------------------------
# Fonctions privées
#------------------------------------------


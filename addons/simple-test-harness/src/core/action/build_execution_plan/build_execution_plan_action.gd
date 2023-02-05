class_name BuildExecutionPlanAction
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

#------------------------------------------
# Variables privées
#------------------------------------------

var _test_case_report:ListTestCaseReport

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(test_case_report:ListTestCaseReport) -> void:
    _test_case_report = test_case_report

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> BuildExecutionPlanReport:
    var report:BuildExecutionPlanReport = BuildExecutionPlanReport.new()
    report.test_case_plan = _get_execution_plan()
    return report

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _get_execution_plan() -> Array[TestCasePlan]:
    var plan:Array[TestCasePlan] = []
    for parsed_test_case in _test_case_report.test_cases:
        var test_case_plan:TestCasePlan = TestCasePlan.from(parsed_test_case)
        if test_case_plan.has_test_methods():
            plan.append(test_case_plan)

    return plan

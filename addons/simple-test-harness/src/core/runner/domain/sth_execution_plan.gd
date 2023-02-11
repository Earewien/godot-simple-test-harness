class_name STHExecutionPlan
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

var test_case_plans:Array[STHTestCasePlan] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHExecutionPlan:
    var plan:STHExecutionPlan = STHExecutionPlan.new()
    for stcp in data["test_case_plans"]:
        plan.test_case_plans.append(STHTestCasePlan.deserialize(stcp))
    return plan

func serialize() -> Dictionary:
    return {
        "test_case_plans" : test_case_plans.map(func(tcp): return tcp.serialize())
    }

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


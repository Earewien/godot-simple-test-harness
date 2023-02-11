class_name STHTestsuitePlanReady
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

var plan:STHExecutionPlan

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestsuitePlanReady:
    var message:STHTestsuitePlanReady = STHTestsuitePlanReady.new()
    message.plan = STHExecutionPlan.deserialize(data["plan"])
    return message

func serialize() -> Dictionary:
    return {
        "plan" : plan.serialize()
    }

func get_type() -> String:
    return "STHTestsuitePlanReady"

#------------------------------------------
# Fonctions privées
#------------------------------------------


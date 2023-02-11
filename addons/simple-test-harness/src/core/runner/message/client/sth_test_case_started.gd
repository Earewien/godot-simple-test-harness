class_name STHTestCaseStarted
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

var test_case_name:String
var test_case_path:String

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestCaseStarted:
    var message:STHTestCaseStarted = STHTestCaseStarted.new()
    message.test_case_name = data["test_case_name"]
    message.test_case_path = data["test_case_path"]
    return message

func serialize() -> Dictionary:
    return {
        "test_case_name" : test_case_name,
        "test_case_path" : test_case_path
    }

func get_type() -> String:
    return "STHTestCaseStarted"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


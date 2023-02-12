class_name STHTestCaseMethodStarted
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
var test_case_method_name:String

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestCaseMethodStarted:
    var message:STHTestCaseMethodStarted = STHTestCaseMethodStarted.new()
    message.test_case_name = data["test_case_name"]
    message.test_case_path = data["test_case_path"]
    message.test_case_method_name = data["test_case_method_name"]
    return message

func serialize() -> Dictionary:
    return {
        "test_case_name" : test_case_name,
        "test_case_path" : test_case_path,
        "test_case_method_name" : test_case_method_name
    }

func get_type() -> String:
    return "STHTestCaseMethodStarted"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


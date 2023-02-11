class_name STHRunSingleTestCommand
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

var test_case_path:String
var test_case_method_name:String

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHRunSingleTestCommand:
    var command:STHRunSingleTestCommand = STHRunSingleTestCommand.new()
    command.test_case_path = data["test_case_path"]
    command.test_case_method_name = data["test_case_method_name"]
    return command

func serialize() -> Dictionary:
    return {
        "test_case_path" : test_case_path,
        "test_case_method_name" : test_case_method_name
    }

func get_type() -> String:
    return "STHRunSingleTestCommand"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


class_name STHRunTestsCommand
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

var lookup_paths:PackedStringArray = []
var from_command_line:bool = false

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHRunTestsCommand:
    var command:STHRunTestsCommand = STHRunTestsCommand.new()
    command.lookup_paths = data["lookup_paths"]
    command.from_command_line = data["from_command_line"]
    return command

func serialize() -> Dictionary:
    return {
        "lookup_paths" : lookup_paths,
        "from_command_line" : from_command_line
    }

func get_type() -> String:
    return "STHRunTestsCommand"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


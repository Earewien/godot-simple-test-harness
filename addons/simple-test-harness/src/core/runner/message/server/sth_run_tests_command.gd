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

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHRunTestsCommand:
    var command:STHRunTestsCommand = STHRunTestsCommand.new()
    command.lookup_paths = data["lookup_paths"]
    return command

func serialize() -> Dictionary:
    return {
        "lookup_paths" : lookup_paths,
    }

func get_type() -> String:
    return "STHRunTestsCommand"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


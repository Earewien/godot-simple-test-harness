class_name STHTestsuiteStarted
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

var start_datetime:String

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestsuiteStarted:
    var message:STHTestsuiteStarted = STHTestsuiteStarted.new()
    message.start_datetime = data["start_datetime"]
    return message

func serialize() -> Dictionary:
    return {
        "start_datetime" : start_datetime
    }

func get_type() -> String:
    return "STHTestsuiteStarted"

#------------------------------------------
# Fonctions privées
#------------------------------------------


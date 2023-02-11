class_name STHTestsuiteFinished
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

var aborted:bool
var finish_datetime:String
var duration_ms:int

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestsuiteFinished:
    var message:STHTestsuiteFinished = STHTestsuiteFinished.new()
    message.aborted = data["aborted"]
    message.finish_datetime = data["finish_datetime"]
    message.duration_ms = data["duration_ms"]
    return message

func serialize() -> Dictionary:
    return {
        "aborted" : aborted,
        "finish_datetime" : finish_datetime,
        "duration_ms" : duration_ms
    }

func get_type() -> String:
    return "STHTestsuiteFinished"

#------------------------------------------
# Fonctions privées
#------------------------------------------


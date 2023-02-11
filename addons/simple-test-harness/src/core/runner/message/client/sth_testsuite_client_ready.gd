class_name STHTestsuiteClientReady
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

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestsuiteClientReady:
    var message:STHTestsuiteClientReady = STHTestsuiteClientReady.new()
    return message

func serialize() -> Dictionary:
    return { }

func get_type() -> String:
    return "STHTestsuiteClientReady"

#------------------------------------------
# Fonctions privées
#------------------------------------------


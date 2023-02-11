class_name STHStopTestsuite
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

static func deserialize(data:Dictionary) ->  STHStopTestsuite:
    var order:STHStopTestsuite = STHStopTestsuite.new()
    return order

func serialize() -> Dictionary:
    return { }

func get_type() -> String:
    return "STHStopTestsuite"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


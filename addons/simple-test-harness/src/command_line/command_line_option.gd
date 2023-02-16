class_name CommandLineOption
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

var valid:bool = true
var value:Variant

#------------------------------------------
# Variables privées
#------------------------------------------

var _short_command:String
var _long_command:String
var _description:String
var _arg_type:int

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(sc:String, lc:String, desc:String, at:int = TYPE_NIL) -> void:
    _short_command = sc
    _long_command = lc
    _description = desc
    _arg_type = at

func _to_string() -> String:
    return "Opt: %s (type = %s, val = %s)" % [_short_command, _arg_type, value]

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

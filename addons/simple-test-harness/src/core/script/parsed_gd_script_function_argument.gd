class_name ParsedGDScriptFunctionArgument
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

var argument_name:String
var argument_type:int
var argument_default_value:Variant

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func from(data:Dictionary, default_value:Variant) -> ParsedGDScriptFunctionArgument:
    var arg:ParsedGDScriptFunctionArgument = ParsedGDScriptFunctionArgument.new()
    arg._read_argument_name(data)
    arg._read_argument_type(data)
    arg.argument_default_value = default_value
    return arg

static func deserialize(data:Dictionary) -> ParsedGDScriptFunctionArgument:
    var arg:ParsedGDScriptFunctionArgument = ParsedGDScriptFunctionArgument.new()
    arg.argument_name = data["argument_name"]
    arg.argument_type = data["argument_type"]
    arg.argument_default_value = str_to_var(data["argument_name"])
    return arg

func serialize() -> Dictionary:
    return {
        "argument_name" : argument_name,
        "argument_type" : argument_type,
        "argument_default_value" : var_to_str(argument_default_value)
    }

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _read_argument_name(data:Dictionary) -> void:
    argument_name = data["name"]

func _read_argument_type(data:Dictionary) -> void:
    argument_type = data["type"]

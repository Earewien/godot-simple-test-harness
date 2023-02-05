class_name CommandLineArgument
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
    return "Arg: %s (%s : %s)" % [_short_command, _long_command, _description]

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func parse_args(args:PackedStringArray) -> CommandLineOption:
    for i in args.size():
        var arg:String = args[i]
        if _short_command == arg or _long_command == arg:
            var command_line_option:CommandLineOption = CommandLineOption.new(_short_command, _long_command, _description, _arg_type)
            # Ok donc c'est notre option
            # On vérifie si on attend une valeur en paramètre ou non
            if _arg_type != TYPE_NIL:
                if i == args.size() - 1:
                    # On attend un paramètre mais la command line est finie ! Pas normal
                    command_line_option.valid = false
                else:
                    command_line_option.value = string_to_expected_type(args[i+1])

            return command_line_option

    # Bon, c'est pas notre option
    return null

#------------------------------------------
# Fonctions privées
#------------------------------------------

func string_to_expected_type(val:String) -> Variant:
    if _arg_type == TYPE_STRING:
        return val
    if _arg_type == TYPE_INT:
        return int(val)
    if _arg_type == TYPE_FLOAT:
        return float(val)
    if _arg_type == TYPE_BOOL:
        return true if val == "true" else false

    push_error("Unexpected type arg %s" % _arg_type)
    return null

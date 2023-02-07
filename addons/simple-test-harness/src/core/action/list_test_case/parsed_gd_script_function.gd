class_name ParsedGDScriptFunction
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

var function_name:String
var function_line_number:int = -1
var function_arguments:Array[ParsedGDScriptFunctionArgument] = []
var function_returned_type:int

var is_default:bool
var is_static:bool
var is_virtual:bool
var is_editor:bool

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func from(data:Dictionary, script_content:PackedStringArray) -> ParsedGDScriptFunction:
    var function:ParsedGDScriptFunction = ParsedGDScriptFunction.new()
    function._read_function_name(data)
    function._read_function_flags(data)
    function._read_line_number(script_content)
    function._read_function_arguments(data)
    function._read_function_returned_type(data)
    return function

static func deserialize(data:Dictionary) -> ParsedGDScriptFunction:
    var function:ParsedGDScriptFunction = ParsedGDScriptFunction.new()
    function.function_name = data["function_name"]
    function.function_line_number = data["function_line_number"]
    for sarg in data["function_arguments"]:
        function.function_arguments.append(ParsedGDScriptFunctionArgument.deserialize(sarg))
    function.function_returned_type = data["function_returned_type"]
    function.is_default = data["is_default"]
    function.is_static = data["is_static"]
    function.is_virtual = data["is_virtual"]
    function.is_editor = data["is_editor"]


    return function

func serialize() -> Dictionary:
    return {
        "function_name" : function_name,
        "function_line_number" : function_line_number,
        "function_arguments" : function_arguments.map(func(arg):return arg.serialize()),
        "function_returned_type" : function_returned_type,
        "is_default" : is_default,
        "is_static" : is_static,
        "is_virtual" : is_virtual,
        "is_editor" : is_editor
    }

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _read_function_name(data:Dictionary) -> void:
    function_name = data["name"]

func _read_function_flags(data:Dictionary) -> void:
    var flags:int = data["flags"]
    is_default = flags & METHOD_FLAGS_DEFAULT
    is_virtual = flags & METHOD_FLAG_VIRTUAL
    is_static = flags & METHOD_FLAG_STATIC
    is_editor = flags & METHOD_FLAG_EDITOR

func _read_line_number(script_content:PackedStringArray) -> void:
    var func_declaration_regex:RegEx = RegEx.new()
    func_declaration_regex.compile("func[\\s\\t\\r\\n]+%s" % function_name)

    # On cherche ligne par ligne pour la méthode:
    # On cherche le mot en entier correspondant au nom de la fonction
    # Si on le trouve, ça peut être plusieurs choses :
    # - un commentaire, on skip
    # - une invocation, on n'en veut pas
    # - la définition de la fonction, attention peut-être sur plusieurs lignes !
    for line_n in script_content.size():
        var line:String = script_content[line_n]
        var stripped_line:String = line.strip_edges(true, true)
        if stripped_line.begins_with("#"):
            # Commentaire!
            continue
        if stripped_line.find(function_name) != -1:
            # Invocation, ou définition ?
#           # On prend les lignes d'avant, pour essayer de trouver la chaîne "func XXX"
            var checked_content:String = ""
            for i in range(max(0, line_n - 3), line_n + 1):
                checked_content += script_content[i]
            if func_declaration_regex.search(checked_content):
                function_line_number = line_n
                break

func _read_function_arguments(data:Dictionary) -> void:
    var args:Array[Dictionary] = data["args"]
    var default_args:Array[Variant] = data["default_args"]
    var default_arg_delta_arg:int = args.size() - default_args.size()
    for arg_n in args.size():
        var arg:Dictionary = args[arg_n]
        var default_value:Variant = default_args[arg_n - default_arg_delta_arg] if arg_n >= default_arg_delta_arg else null
        function_arguments.append(ParsedGDScriptFunctionArgument.from(arg, default_value))

func _read_function_returned_type(data:Dictionary) -> void:
    function_returned_type = data["return"]["type"]

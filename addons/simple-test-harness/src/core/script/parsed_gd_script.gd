class_name ParsedGDScript
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

var script_path:String
var script_class_name:String
var script_parent_class_name:String
var script_functions:Array[ParsedGDScriptFunction] = []

var script_parent_class_name_filter:String = ""

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) -> ParsedGDScript:
    var script:ParsedGDScript = ParsedGDScript.new()
    script.script_path = data["script_path"]
    script.script_class_name = data["script_class_name"]
    script.script_parent_class_name = data["script_parent_class_name"]
    for sf in data["script_functions"]:
        script.script_functions.append(ParsedGDScriptFunction.deserialize(sf))
    script.script_parent_class_name_filter = data["script_parent_class_name_filter"]
    return script

func parse(script:GDScript) -> bool:
    script_path = script.resource_path
    _read_parent_class_name(script)
    if not script_parent_class_name_filter.is_empty() and script_parent_class_name != script_parent_class_name_filter:
        return false
    _read_class_name(script)
    _read_functions(script)
    return true

func serialize() -> Dictionary:
    return {
        "script_path" : script_path,
        "script_class_name" : script_class_name,
        "script_parent_class_name" : script_parent_class_name,
        "script_functions" : script_functions.map(func(f):return f.serialize()),
        "script_parent_class_name_filter" : script_parent_class_name_filter
    }

func has_default_constructor() -> bool:
    for function in script_functions:
        if function.function_name == "_init":
            return function.function_arguments.is_empty()
    return true

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _read_script_content(script:GDScript) -> PackedStringArray:
    return script.source_code.split("\n")

func _read_class_name(script:GDScript) -> void:
    var class_name_regexp:RegEx = RegEx.new()
    class_name_regexp.compile("class_name[\\s\\t\\n\\r]+(\\w+)")
    var search_result:RegExMatch = class_name_regexp.search(script.source_code)
    if search_result:
        # Trouvé ! On va prendre le vrai nom de la classe
        script_class_name = search_result.get_string(1)
    else:
        # Pas de nom de classe, on va prendre le nom du fichier
        script_class_name = script.resource_path.get_basename().get_file()

func _read_parent_class_name(script:GDScript) -> void:
    var parent_class_name_regexp:RegEx = RegEx.new()
    parent_class_name_regexp.compile("extends[\\s\\t\\n\\r]+(\\w+)")
    var search_result:RegExMatch = parent_class_name_regexp.search(script.source_code)
    if search_result:
        # Trouvé ! On va prendre le vrai nom du parent
        script_parent_class_name = search_result.get_string(1)
    else:
        # Pas de résultat, c'est un Node (défaut Godot)
        script_parent_class_name = "Node"

func _read_functions(script:GDScript) -> void:
    var script_content:PackedStringArray = _read_script_content(script)
    var methods:Array[Dictionary] = script.get_script_method_list()
    for method in methods:
        script_functions.append(ParsedGDScriptFunction.from(method, script_content))

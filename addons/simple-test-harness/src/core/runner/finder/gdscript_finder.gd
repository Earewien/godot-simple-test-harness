class_name GDScriptFinder
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

# Where to look for scripts. Can be directories or file paths. All directories will be scanned recursively
var lookup_paths:PackedStringArray = []

# Where to NOT look at !
var excluded_lookup_paths:PackedStringArray = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(exclude_template_dir_from_lookup_paths:bool = true) -> void:
    if exclude_template_dir_from_lookup_paths:
        var setting_template_dir:String = ProjectSettings.get_setting("editor/script/templates_search_path", "")
        if not setting_template_dir.is_empty():
            excluded_lookup_paths.append(setting_template_dir.simplify_path())

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> Array[GDScript]:
    var scripts:Array[GDScript] = []
    for path in lookup_paths:
        scripts.append_array(_recursive_find_gd_scripts(path))
    return scripts

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _recursive_find_gd_scripts(path:String) -> Array[GDScript]:
    # Since resource path is a key to identify resource, make sur each path is canonical !
    path = path.simplify_path()
    var scripts:Array[GDScript] = []

    # Check for excludes!
    if not excluded_lookup_paths.has(path):
        # Recursive search in directory
        if DirAccess.dir_exists_absolute(path):
            var res_dir:DirAccess = DirAccess.open(path)
            res_dir.list_dir_begin()
            var file_name = res_dir.get_next()
            while file_name != "":
                scripts.append_array(_recursive_find_gd_scripts(path.path_join(file_name)))
                file_name = res_dir.get_next()
        # Path represents a file !
        elif FileAccess.file_exists(path):
            # A file, maybe a GDScript ?
            if path.get_extension() == "gd":
                var loaded_file = GDScriptFactory.get_gdscript(path)
                scripts.append(loaded_file)

    return scripts

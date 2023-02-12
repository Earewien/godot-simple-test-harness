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

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

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
    var scripts:Array[GDScript] = []

    # Recursive search in directory
    if DirAccess.dir_exists_absolute(path):
        var res_dir:DirAccess = DirAccess.open(path)
        res_dir.list_dir_begin()
        var file_name = res_dir.get_next()
        while file_name != "":
            scripts.append_array(_recursive_find_gd_scripts("%s/%s" % [path, file_name]))
            file_name = res_dir.get_next()
    # Path represents a file !
    elif FileAccess.file_exists(path):
        # A file, maybe a GDScript ?
        if path.get_extension() == "gd":
            var loaded_file = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)
            if loaded_file is GDScript:
                scripts.append(loaded_file)

    return scripts
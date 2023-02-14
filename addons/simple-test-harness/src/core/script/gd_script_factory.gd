class_name GDScriptFactory
extends RefCounted

const META_LOAD_ERROR:String = "sth_meta_load_error"

# The aim is to be able to obtain a GDScript instance even if script file contains syntax errors
# When directly using ResourceLoader.load, if script has error, debugguer break. So it blocks the runner !
# We dont want that, instead we want to know if script has errors, and report that to user. So we manually
# create GDScript instances

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

static func get_gdscript(path:String) -> GDScript:
    var script:GDScript
    if ResourceLoader.has_cached(path):
        script =  ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)
        # Check for meta, if no meta (loaded elsewhere), consider it's ok
        if not script.has_meta(META_LOAD_ERROR):
            script.set_meta(META_LOAD_ERROR, OK)
    else:
        script = GDScript.new()
        if not FileAccess.file_exists(path):
            script.set_meta(META_LOAD_ERROR, ERR_FILE_NOT_FOUND)
        else:
            script.source_code = FileAccess.get_file_as_string(path)
            script.take_over_path(path)
            var script_error:int = script.reload()
            script.set_meta(META_LOAD_ERROR, script_error)
            if script_error == OK:
                script = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)
                script.set_meta(META_LOAD_ERROR, OK)

    return script

#------------------------------------------
# Fonctions privées
#------------------------------------------


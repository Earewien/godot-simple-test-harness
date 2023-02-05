class_name TempFile
extends RefCounted

const TEMP_FILE_DIR:String = "user://.sth/temp"

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

var _file_path:String

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(name_prefix:String) -> void:
    DirAccess.make_dir_recursive_absolute(TEMP_FILE_DIR)
    _file_path = "%s/%s-%s.tmp" % [TEMP_FILE_DIR, name_prefix, Time.get_ticks_usec()]

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func get_file_path() -> String:
    return _file_path

func get_file_content() -> String:
    return FileAccess.get_file_as_string(_file_path)

func get_bytes_file_content() -> PackedByteArray:
    return FileAccess.get_file_as_bytes(_file_path)

func set_file_content(content:String) -> void:
    var file:FileAccess = FileAccess.open(_file_path, FileAccess.WRITE)
    file.store_string(content)
    file.flush()

func set_bytes_file_content(content:PackedByteArray) -> void:
    var file:FileAccess = FileAccess.open(_file_path, FileAccess.WRITE)
    file.store_buffer(content)
    file.flush()

func delete() -> void:
    DirAccess.open(TEMP_FILE_DIR).remove(_file_path.get_file())

#------------------------------------------
# Fonctions privées
#------------------------------------------


class_name GodotLogHandler
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

var _original_project_settings_log_enabled:bool
var _log_file_path:String
var _log_eof_position:int

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init() -> void:
    _original_project_settings_log_enabled = ProjectSettings.get_setting("debug/file_logging/enable_file_logging")
    _log_file_path = ProjectSettings.get_setting("debug/file_logging/log_path")

    ProjectSettings.set_setting("debug/file_logging/enable_file_logging", true)
    var log_file:FileAccess = FileAccess.open(_log_file_path, FileAccess.READ)
    _log_eof_position = log_file.get_length()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func get_log_content() -> PackedStringArray:
    var lines:PackedStringArray = []
    var log_file:FileAccess = FileAccess.open(_log_file_path, FileAccess.READ)
    log_file.seek(_log_eof_position)
    while not log_file.eof_reached():
        lines.append(log_file.get_line())
    return lines

func close() -> void:
    ProjectSettings.set_setting("debug/file_logging/enable_file_logging", _original_project_settings_log_enabled)

#------------------------------------------
# Fonctions privées
#------------------------------------------


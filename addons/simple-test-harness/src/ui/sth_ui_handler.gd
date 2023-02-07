class_name UISTHHandler
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

var _fs_dock_menu_handler:FileSystemDockMenuHandler
var _script_editor_menu_handler:ScriptEditorMenuHandler
var _project_tools_menu_handler:ProjectToolsMenuHandler

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func initialize() -> void:
    _fs_dock_menu_handler = FileSystemDockMenuHandler.new()
    _fs_dock_menu_handler.initialize()
    _script_editor_menu_handler = ScriptEditorMenuHandler.new()
    _script_editor_menu_handler.initialize()
    _project_tools_menu_handler = ProjectToolsMenuHandler.new()
    _project_tools_menu_handler.initialize()

func finalize() -> void:
    if _fs_dock_menu_handler:
        _fs_dock_menu_handler.finalize()
        _fs_dock_menu_handler = null
    if _script_editor_menu_handler:
        _script_editor_menu_handler.finalize()
        _script_editor_menu_handler = null
    if _project_tools_menu_handler:
        _project_tools_menu_handler.finalize()
        _project_tools_menu_handler = null


#------------------------------------------
# Fonctions privées
#------------------------------------------


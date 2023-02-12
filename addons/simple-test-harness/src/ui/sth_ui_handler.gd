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

var _plugin:SimpleTestHarnessPlugin

var _sth_dock_view:STHDockView

var _fs_dock_menu_handler:FileSystemDockMenuHandler
var _script_editor_menu_handler:ScriptEditorMenuHandler
var _project_tools_menu_handler:ProjectToolsMenuHandler

var _script_editor_gutter_handler:ScriptEditorGutterHandler

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func initialize() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META):
        return
    _plugin = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META)

    _sth_dock_view = preload("res://addons/simple-test-harness/src/ui/dock/sth_dock_view.tscn").instantiate()
    _plugin.add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _sth_dock_view)

    _fs_dock_menu_handler = FileSystemDockMenuHandler.new()
    _fs_dock_menu_handler.initialize()
    _script_editor_menu_handler = ScriptEditorMenuHandler.new()
    _script_editor_menu_handler.initialize()
    _project_tools_menu_handler = ProjectToolsMenuHandler.new()
    _project_tools_menu_handler.initialize()
    _script_editor_gutter_handler = ScriptEditorGutterHandler.new()
    _script_editor_gutter_handler.initialize()

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
    if _script_editor_gutter_handler:
        _script_editor_gutter_handler.finalize()
        _script_editor_gutter_handler = null
    if is_instance_valid(_sth_dock_view):
        _plugin.remove_control_from_docks(_sth_dock_view)
        _sth_dock_view.queue_free()
        _sth_dock_view = null
    _plugin = null


#------------------------------------------
# Fonctions privées
#------------------------------------------


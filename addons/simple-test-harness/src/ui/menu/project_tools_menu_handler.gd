class_name ProjectToolsMenuHandler
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
var _tools_popup_menu:PopupMenu

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func initialize() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META):
        return
    _plugin = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META)

    _tools_popup_menu = PopupMenu.new()
    _add_menu_items(_tools_popup_menu)
    _plugin.add_tool_submenu_item("Simple Test Harness", _tools_popup_menu)

    _tools_popup_menu.id_pressed.connect(_on_menu_id_pressed)

func finalize() -> void:
    _plugin.remove_tool_menu_item("Simple Test Harness")
    if is_instance_valid(_tools_popup_menu):
        _tools_popup_menu.id_pressed.disconnect(_on_menu_id_pressed)
        _tools_popup_menu.queue_free()
    _plugin = null

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_menu_id_pressed(id:int) -> void:
    if MenuEntriesRegistry.is_run_test_menu(id) or MenuEntriesRegistry.is_debug_test_menu(id):
        var debug_mode:bool = MenuEntriesRegistry.is_debug_test_menu(id)
        _plugin.execute_test_cases_from_path(["res://"], debug_mode)

func _add_menu_items(menu:PopupMenu) -> void:
    menu.add_icon_item(MenuEntriesRegistry.MENU_RUN_ALL_TESTS["icon"], MenuEntriesRegistry.MENU_RUN_ALL_TESTS["name"], MenuEntriesRegistry.MENU_RUN_ALL_TESTS["id"])
    menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["icon"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["name"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["id"])

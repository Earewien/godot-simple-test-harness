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
var _can_run_tests:bool = true

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func initialize() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META):
        return
    _plugin = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META)

    # To disable run actions when testsuite is already running
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)

    _tools_popup_menu = PopupMenu.new()
    _add_menu_items(_tools_popup_menu)
    _plugin.add_tool_submenu_item("Simple Test Harness", _tools_popup_menu)

    _tools_popup_menu.id_pressed.connect(_on_menu_id_pressed)

func finalize() -> void:
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)

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

func _on_orchestrator_state_changed(state:int) -> void:
    _can_run_tests = state == STHOrchestrator.ORCHESTRATOR_STATE_IDLE
    _update_menu_item_availability()

func _on_menu_id_pressed(id:int) -> void:
    if MenuEntriesRegistry.is_run_test_case_menu(id) or MenuEntriesRegistry.is_debug_test_case_menu(id):
        var debug_mode:bool = MenuEntriesRegistry.is_debug_test_case_menu(id)
        _plugin.execute_test_cases_from_path(["res://"], debug_mode)

func _add_menu_items(menu:PopupMenu) -> void:
    menu.add_icon_shortcut(MenuEntriesRegistry.MENU_RUN_ALL_TESTS["icon"], STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_ALL_TESTS), MenuEntriesRegistry.MENU_RUN_ALL_TESTS["id"])
    menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["icon"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["name"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["id"])

func _update_menu_item_availability() -> void:
    if is_instance_valid(_tools_popup_menu):
        var all_ids:PackedInt32Array = [
            MenuEntriesRegistry.MENU_RUN_ALL_TESTS["id"],
            MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["id"]
        ]
        for id in all_ids:
            var menu_index:int = _tools_popup_menu.get_item_index(id)
            if menu_index != -1:
                _tools_popup_menu.set_item_disabled(menu_index, not _can_run_tests)

class_name ScriptEditorMenuHandler
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
var _current_script_editor_popup_menu:PopupMenu

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

    # To detect script change and hook popup menu accordingly
    if not _plugin.get_editor_interface().get_script_editor().editor_script_changed.is_connected(_on_editor_script_changed):
        _plugin.get_editor_interface().get_script_editor().editor_script_changed.connect(_on_editor_script_changed)

func finalize() -> void:
    if _plugin.get_editor_interface().get_script_editor().editor_script_changed.is_connected(_on_editor_script_changed):
        _plugin.get_editor_interface().get_script_editor().editor_script_changed.disconnect(_on_editor_script_changed)

    if _current_script_editor_popup_menu:
        if _current_script_editor_popup_menu.about_to_popup.is_connected(on_script_editor_popup_menu_showing):
            _current_script_editor_popup_menu.about_to_popup.disconnect(on_script_editor_popup_menu_showing)
        if _current_script_editor_popup_menu.id_pressed.is_connected(on_script_editor_popup_menu_id_selected):
            _current_script_editor_popup_menu.id_pressed.disconnect(on_script_editor_popup_menu_id_selected)
        if _current_script_editor_popup_menu.close_requested.is_connected(on_script_editor_popup_menu_closing):
            _current_script_editor_popup_menu.close_requested.disconnect(on_script_editor_popup_menu_closing)
    _current_script_editor_popup_menu = null

    _plugin = null

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_editor_script_changed(script) -> void:
    if _current_script_editor_popup_menu:
        _current_script_editor_popup_menu.set_meta("is_on_testcase", false)
        if _current_script_editor_popup_menu.about_to_popup.is_connected(on_script_editor_popup_menu_showing):
            _current_script_editor_popup_menu.about_to_popup.disconnect(on_script_editor_popup_menu_showing)
        if _current_script_editor_popup_menu.id_pressed.is_connected(on_script_editor_popup_menu_id_selected):
            _current_script_editor_popup_menu.id_pressed.disconnect(on_script_editor_popup_menu_id_selected)
        if _current_script_editor_popup_menu.close_requested.is_connected(on_script_editor_popup_menu_closing):
            _current_script_editor_popup_menu.close_requested.disconnect(on_script_editor_popup_menu_closing)
        _current_script_editor_popup_menu = null

    if script is GDScript:
        # Is it a test case ?
        var parsed_gd_script:ParsedGDScript = ParsedGDScript.new()
        parsed_gd_script.parse(script)
        if parsed_gd_script.script_parent_class_name == "TestCase":
            # Yes, hook menu !
            var script_editor:ScriptEditorBase = _plugin.get_editor_interface().get_script_editor().get_current_editor()
            _current_script_editor_popup_menu = _get_child_popup_menu(script_editor)
            _add_test_entries_to_menu_if_needed(_current_script_editor_popup_menu, script)
        else:
            _remove_test_entries(_current_script_editor_popup_menu)
    else:
        _remove_test_entries(_current_script_editor_popup_menu)

func _add_test_entries_to_menu_if_needed(menu:PopupMenu, script) -> void:
    if menu == null:
        push_error("A Popup menu should be present to ass test entries")
    else:
        menu.set_meta("is_on_testcase", true)
        if not menu.about_to_popup.is_connected(on_script_editor_popup_menu_showing):
            menu.about_to_popup.connect(on_script_editor_popup_menu_showing.bind(menu))
        if not menu.id_pressed.is_connected(on_script_editor_popup_menu_id_selected):
            menu.id_pressed.connect(on_script_editor_popup_menu_id_selected.bind(script))
        if not menu.close_requested.is_connected(on_script_editor_popup_menu_closing):
            menu.close_requested.connect(on_script_editor_popup_menu_closing.bind(menu))

func on_script_editor_popup_menu_showing(menu:PopupMenu) -> void:
    if menu.has_meta("is_on_testcase"):
        menu.add_separator(MenuEntriesRegistry.MENU_SEPARATOR["name"], MenuEntriesRegistry.MENU_SEPARATOR["id"])
        menu.add_icon_item(MenuEntriesRegistry.MENU_RUN_TEST["icon"], MenuEntriesRegistry.MENU_RUN_TEST["name"], MenuEntriesRegistry.MENU_RUN_TEST["id"])
        menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_TEST["icon"], MenuEntriesRegistry.MENU_DEBUG_TEST["name"], MenuEntriesRegistry.MENU_DEBUG_TEST["id"])

func on_script_editor_popup_menu_id_selected(id:int, script:GDScript) -> void:
    if MenuEntriesRegistry.is_run_test_menu(id) or MenuEntriesRegistry.is_debug_test_menu(id):
        var debug_mode:bool = MenuEntriesRegistry.is_debug_test_menu(id)
        _plugin.execute_test_cases_from_path([script.resource_path], debug_mode)

func on_script_editor_popup_menu_closing(menu:PopupMenu) -> void:
    _remove_test_entries(menu)

func _remove_test_entries(menu:PopupMenu) -> void:
    if menu:
        var all_ids:PackedInt32Array = [
            MenuEntriesRegistry.MENU_SEPARATOR["id"],
            MenuEntriesRegistry.MENU_RUN_TEST["id"],
            MenuEntriesRegistry.MENU_DEBUG_TEST["id"]
        ]
        for id in all_ids:
            var menu_index:int = menu.get_item_index(id)
            if menu_index != -1:
                menu.remove_item(menu_index)

func _get_child_popup_menu(parent_node:Node) -> PopupMenu:
    for child in parent_node.get_children():
        if child is PopupMenu:
            return child
    return null

func _get_popup_menus(parent_node:Node) -> Array[PopupMenu]:
    var menus:Array[PopupMenu] = []
    if parent_node is PopupMenu:
        menus.append(parent_node)
    for child in parent_node.get_children():
        menus.append_array(_get_popup_menus(child))
    return menus

func _get_first_item_list(parent_node:Node) -> ItemList:
    if parent_node is ItemList:
        return parent_node
    for child in parent_node.get_children():
        var item_list:ItemList = _get_first_item_list(child)
        if item_list:
            return item_list
    return null

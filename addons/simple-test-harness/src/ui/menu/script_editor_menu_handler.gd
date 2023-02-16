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

var _can_run_tests:bool = true

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

    # To disable run actions when testsuite is already running
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)

    # To detect script change and hook popup menu accordingly
    if not _plugin.get_editor_interface().get_script_editor().editor_script_changed.is_connected(_on_editor_script_changed):
        _plugin.get_editor_interface().get_script_editor().editor_script_changed.connect(_on_editor_script_changed)

func finalize() -> void:
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)

    if _plugin.get_editor_interface().get_script_editor().editor_script_changed.is_connected(_on_editor_script_changed):
        _plugin.get_editor_interface().get_script_editor().editor_script_changed.disconnect(_on_editor_script_changed)

    if is_instance_valid(_current_script_editor_popup_menu):
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

func _on_orchestrator_state_changed(state:int) -> void:
    _can_run_tests = state == STHOrchestrator.ORCHESTRATOR_STATE_IDLE
    _update_menu_item_availability()

func _on_editor_script_changed(script) -> void:
    if is_instance_valid(_current_script_editor_popup_menu):
        if _current_script_editor_popup_menu.about_to_popup.is_connected(on_script_editor_popup_menu_showing):
            _current_script_editor_popup_menu.about_to_popup.disconnect(on_script_editor_popup_menu_showing)
        if _current_script_editor_popup_menu.id_pressed.is_connected(on_script_editor_popup_menu_id_selected):
            _current_script_editor_popup_menu.id_pressed.disconnect(on_script_editor_popup_menu_id_selected)
        if _current_script_editor_popup_menu.close_requested.is_connected(on_script_editor_popup_menu_closing):
            _current_script_editor_popup_menu.close_requested.disconnect(on_script_editor_popup_menu_closing)
        _current_script_editor_popup_menu = null

    # Yes, hook menu !
    var script_editor:ScriptEditorBase = _plugin.get_editor_interface().get_script_editor().get_current_editor()
    # When script is saved or changed, reload popupmenu
    if not script_editor.edited_script_changed.is_connected(_on_editor_script_changed):
        script_editor.edited_script_changed.connect(_on_editor_script_changed.bind(script))
    _current_script_editor_popup_menu = _get_child_popup_menu(script_editor)
    _add_test_entries_to_menu_if_needed(_current_script_editor_popup_menu, script_editor)
    # And hook shortcut if needed ! Shortcuts don't work on those popup menus, have to do it manually
    _install_shortcuts_on_editor(script_editor)

func _add_test_entries_to_menu_if_needed(menu:PopupMenu, script_editor:ScriptEditorBase) -> void:
    if menu == null:
        push_error("A Popup menu should be present to ass test entries")
    else:
        if not menu.about_to_popup.is_connected(on_script_editor_popup_menu_showing):
            menu.about_to_popup.connect(on_script_editor_popup_menu_showing.bind(menu, script_editor))
        if not menu.id_pressed.is_connected(on_script_editor_popup_menu_id_selected):
            menu.id_pressed.connect(on_script_editor_popup_menu_id_selected.bind(script_editor))
        if not menu.close_requested.is_connected(on_script_editor_popup_menu_closing):
            menu.close_requested.connect(on_script_editor_popup_menu_closing.bind(menu))

func on_script_editor_popup_menu_showing(menu:PopupMenu, script_editor:ScriptEditorBase) -> void:
    var script_path = _get_edited_script_path(script_editor)
    if script_path:
        var parsed_script:ParsedGDScript = ParsedGDScript.new()
        parsed_script.parse(GDScriptFactory.get_gdscript(script_path))
        if parsed_script.script_parent_class_name == "TestCase":
            menu.add_separator(MenuEntriesRegistry.MENU_SEPARATOR["name"], MenuEntriesRegistry.MENU_SEPARATOR["id"])
            menu.add_icon_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE["icon"], STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE), MenuEntriesRegistry.MENU_RUN_TEST_CASE["id"])
            menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["icon"], MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["name"], MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["id"])

            # If carret is after a test function, add options to run test method
            if _get_function_at_caret_position_in_current_editor(parsed_script) != null:
                menu.add_icon_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE_METHOD["icon"], STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE_METHOD), MenuEntriesRegistry.MENU_RUN_TEST_CASE_METHOD["id"])
                menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_TEST_CASE_METHOD["icon"], MenuEntriesRegistry.MENU_DEBUG_TEST_CASE_METHOD["name"], MenuEntriesRegistry.MENU_DEBUG_TEST_CASE_METHOD["id"])

    _update_menu_item_availability()

func on_script_editor_popup_menu_id_selected(id:int, script_editor:ScriptEditorBase) -> void:
    var script_path = _get_edited_script_path(script_editor)
    if script_path:
        if MenuEntriesRegistry.is_run_test_case_menu(id) or MenuEntriesRegistry.is_debug_test_case_menu(id):
            var debug_mode:bool = MenuEntriesRegistry.is_debug_test_case_menu(id)
            _plugin.execute_test_cases_from_path([script_path], debug_mode)
        elif MenuEntriesRegistry.is_run_test_case_method_menu(id) or MenuEntriesRegistry.is_debug_test_case_method_menu(id):
            var debug_mode:bool = MenuEntriesRegistry.is_debug_test_case_method_menu(id)
            var parsed_script:ParsedGDScript = ParsedGDScript.new()
            parsed_script.parse(GDScriptFactory.get_gdscript(script_path))
            var test_function:ParsedGDScriptFunction = _get_function_at_caret_position_in_current_editor(parsed_script)
            if test_function != null:
                _plugin.execute_test_case_method(script_path, test_function.function_name, debug_mode)
            else:
                push_error("Unable to find test case method to run...")

func on_script_editor_popup_menu_closing(menu:PopupMenu) -> void:
    _remove_test_entries(menu)

func _remove_test_entries(menu:PopupMenu) -> void:
    if menu:
        var all_ids:PackedInt32Array = [
            MenuEntriesRegistry.MENU_SEPARATOR["id"],
            MenuEntriesRegistry.MENU_RUN_TEST_CASE["id"],
            MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["id"],
            MenuEntriesRegistry.MENU_RUN_TEST_CASE_METHOD["id"],
            MenuEntriesRegistry.MENU_DEBUG_TEST_CASE_METHOD["id"]
        ]
        for id in all_ids:
            var menu_index:int = menu.get_item_index(id)
            if menu_index != -1:
                menu.remove_item(menu_index)

func _update_menu_item_availability() -> void:
    if is_instance_valid(_current_script_editor_popup_menu):
        var all_ids:PackedInt32Array = [
            MenuEntriesRegistry.MENU_SEPARATOR["id"],
            MenuEntriesRegistry.MENU_RUN_TEST_CASE["id"],
            MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["id"],
            MenuEntriesRegistry.MENU_RUN_TEST_CASE_METHOD["id"],
            MenuEntriesRegistry.MENU_DEBUG_TEST_CASE_METHOD["id"]
        ]
        for id in all_ids:
            var menu_index:int = _current_script_editor_popup_menu.get_item_index(id)
            if menu_index != -1:
                _current_script_editor_popup_menu.set_item_disabled(menu_index, not _can_run_tests)

func _install_shortcuts_on_editor(script_editor:ScriptEditorBase) -> void:
    if script_editor.has_meta("sth_hook_shortcut"):
        script_editor.get_base_editor().remove_child(script_editor.get_meta("sth_hook_shortcut"))
        script_editor.get_meta("sth_hook_shortcut").queue_free()
        script_editor.remove_meta("sth_hook_shortcut")

    var shortcut_handler:STHShortcutHandler = preload("res://addons/simple-test-harness/src/ui/shortcut/sth_shortcut_handler.tscn").instantiate()
    script_editor.get_base_editor().add_child(shortcut_handler)
    script_editor.set_meta("sth_hook_shortcut", shortcut_handler)

    # For test cases
    shortcut_handler.add_shortcut(STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE), _get_shortcut_run_test_case_condition.bind(script_editor), _get_shortcut_run_test_case_action.bind(script_editor))
    # For methods
    shortcut_handler.add_shortcut(STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE_METHOD), _get_shortcut_run_test_case_method_condition.bind(script_editor), _get_shortcut_run_test_case_method_action.bind(script_editor))

func _get_shortcut_run_test_case_condition(script_editor:ScriptEditorBase) -> bool:
    if not _can_run_tests:
        return false

    if _plugin.get_editor_interface().get_script_editor().get_current_editor() != script_editor:
        return false

    if Engine.get_main_loop().root.gui_get_focus_owner() != script_editor.get_base_editor():
        return false

    var script_path = _get_edited_script_path(script_editor)
    if script_path:
        var parsed_script:ParsedGDScript = ParsedGDScript.new()
        parsed_script.parse(GDScriptFactory.get_gdscript(script_path))
        return parsed_script.script_parent_class_name == "TestCase"
    return false

func _get_shortcut_run_test_case_method_condition(script_editor:ScriptEditorBase) -> bool:
    if not _can_run_tests:
        return false

    if _plugin.get_editor_interface().get_script_editor().get_current_editor() != script_editor:
        return false

    if Engine.get_main_loop().root.gui_get_focus_owner() != script_editor.get_base_editor():
        return false

    var script_path = _get_edited_script_path(script_editor)
    if script_path:
        var parsed_script:ParsedGDScript = ParsedGDScript.new()
        parsed_script.parse(GDScriptFactory.get_gdscript(script_path))
        if parsed_script.script_parent_class_name == "TestCase":
            return _get_function_at_caret_position_in_current_editor(parsed_script) != null

    return false

func _get_shortcut_run_test_case_action(script_editor:ScriptEditorBase) -> void:
    var script_path = _get_edited_script_path(script_editor)
    if script_path:
         # Force save, because if there is any unsaved changed, lines will not be properly computed
        var error:int = ResourceSaver.save(GDScriptFactory.get_gdscript(script_path), script_path)
        if error != 0:
            push_error("Unable to save %s ! %s" % [script_path, error_string(error)])
        else:
            script_editor.get_base_editor().tag_saved_version()
            _plugin.execute_test_cases_from_path([script_path], false)

func _get_shortcut_run_test_case_method_action(script_editor:ScriptEditorBase) -> void:
    var script_path = _get_edited_script_path(script_editor)
    if script_path:
         # Force save, because if there is any unsaved changed, lines will not be properly computed
        var error:int = ResourceSaver.save(_plugin.get_editor_interface().get_script_editor().get_current_script(), script_path)
        if error != 0:
            push_error("Unable to save %s ! %s" % [script_path, error_string(error)])
        else:
            script_editor.get_base_editor().tag_saved_version()
            var parsed_script:ParsedGDScript = ParsedGDScript.new()
            parsed_script.parse(GDScriptFactory.get_gdscript(script_path))
            _plugin.execute_test_case_method(script_path, _get_function_at_caret_position_in_current_editor(parsed_script).function_name, false)

func _get_edited_script_path(script_editor:ScriptEditorBase) -> Variant:
    if script_editor.has_meta("_edit_res_path"):
        return script_editor.get_meta("_edit_res_path")
    return null

func _get_edited_script(script_editor:ScriptEditorBase) -> Script:
    var script_path = _get_edited_script_path(script_editor)
    if script_path:
        for script in _plugin.get_editor_interface().get_script_editor().get_open_scripts():
            if script.resource_path == script_path:
                return script
    return null

func _get_function_at_caret_position_in_current_editor(parsed_script:ParsedGDScript) -> ParsedGDScriptFunction:
    var result:ParsedGDScriptFunction = null
    var script_editor:ScriptEditorBase = _plugin.get_editor_interface().get_script_editor().get_current_editor()
    var carret_line:int = script_editor.get_base_editor().get_caret_line(0)
    var script_functions:Array[ParsedGDScriptFunction] = Array(parsed_script.script_functions)
    script_functions.sort_custom(func(a,b):return a.function_line_number < b.function_line_number)

    for i in script_functions.size():
        var function:ParsedGDScriptFunction = script_functions[i]
        if _is_executable_test_function(function):
            var next_function_line_number:int = 9999999 if i == script_functions.size() - 1 else script_functions[i+1].function_line_number
            if carret_line < next_function_line_number and carret_line >= function.function_line_number:
                result = function
                break

    return result

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

func _is_executable_test_function(function:ParsedGDScriptFunction) -> bool:
    return function.function_name.begins_with("test") \
        and function.function_returned_type == TYPE_NIL \
        and function.function_arguments.is_empty() \
        and not function.is_static \
        and not function.is_virtual \
        and not function.is_editor

class_name FileSystemDockMenuHandler
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

# Core FS view popup menu
var _fs_tree_popup_menu:PopupMenu
# Splitted view popup menu
var _fs_item_list_popup_menu:PopupMenu
# Tree showing files
var _fs_tree:Tree
# Item list when splitted view is activated
var _fs_item_list:ItemList

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

    var all_fs_fock_menus:Array[PopupMenu] = _get_popup_menus(_plugin.get_editor_interface().get_file_system_dock())
    var all_fs_dock_trees:Array[Tree] = _get_trees(_plugin.get_editor_interface().get_file_system_dock())
    var all_fs_dock_item_lists:Array[ItemList] = _get_itemlists(_plugin.get_editor_interface().get_file_system_dock())

    if all_fs_fock_menus.size() < 2 or all_fs_dock_trees.is_empty() or all_fs_dock_item_lists.is_empty():
        push_error("Expected at least 2 popup menus in FileSystem dock, 1 tree and 1 item list")
    else:
        _fs_item_list_popup_menu = all_fs_fock_menus[0]
        _fs_tree_popup_menu = all_fs_fock_menus[1]
        _fs_tree = all_fs_dock_trees[0]
        _fs_item_list = all_fs_dock_item_lists[0]

        _initialize_popup_menu(_fs_tree_popup_menu, _fs_tree)
        _initialize_popup_menu(_fs_item_list_popup_menu, _fs_item_list)
        # Shortcut in popup menus does not work, so do it manually
        _initialize_shortcuts(_fs_tree)
        _initialize_shortcuts(_fs_item_list)

        # To disable run actions when testsuite is already running
        if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
            var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
            orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)

func finalize() -> void:
    if is_instance_valid(_fs_tree_popup_menu):
        if _fs_tree_popup_menu.about_to_popup.is_connected(_on_fs_menu_showing):
            _fs_tree_popup_menu.about_to_popup.disconnect(_on_fs_menu_showing)
        if _fs_tree_popup_menu.close_requested.is_connected(_on_fs_menu_closing):
            _fs_tree_popup_menu.close_requested.disconnect(_on_fs_menu_closing)

    if is_instance_valid(_fs_item_list_popup_menu):
        if _fs_item_list_popup_menu.about_to_popup.is_connected(_on_fs_menu_showing):
            _fs_item_list_popup_menu.about_to_popup.disconnect(_on_fs_menu_showing)
        if _fs_item_list_popup_menu.close_requested.is_connected(_on_fs_menu_closing):
            _fs_item_list_popup_menu.close_requested.disconnect(_on_fs_menu_closing)

    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)

    _fs_tree_popup_menu = null
    _fs_item_list_popup_menu = null
    _fs_tree = null
    _fs_item_list = null

    _plugin = null

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_orchestrator_state_changed(state:int) -> void:
    _can_run_tests = state == STHOrchestrator.ORCHESTRATOR_STATE_IDLE
    _update_menu_item_availability(_fs_tree_popup_menu)
    _update_menu_item_availability(_fs_item_list_popup_menu)

func _initialize_popup_menu(menu:PopupMenu, container) -> void:
    if not menu.about_to_popup.is_connected(_on_fs_menu_showing):
        menu.about_to_popup.connect(_on_fs_menu_showing.bind(menu, container))
    if not menu.id_pressed.is_connected(_on_fs_menu_closing):
        menu.id_pressed.connect(_on_fs_menu_id_pressed.bind(menu, container))
    if not menu.close_requested.is_connected(_on_fs_menu_closing):
        menu.close_requested.connect(_on_fs_menu_closing.bind(menu))

func _initialize_shortcuts(node:Node) -> void:
    if node.has_meta("sth_hook_shortcut"):
        node.remove_child(node.get_meta("sth_hook_shortcut"))
        node.get_meta("sth_hook_shortcut").queue_free()
        node.remove_meta("sth_hook_shortcut")

    var shortcut_handler:STHShortcutHandler = preload("res://addons/simple-test-harness/src/ui/shortcut/sth_shortcut_handler.tscn").instantiate()
    node.add_child(shortcut_handler)
    node.set_meta("sth_hook_shortcut", shortcut_handler)

    # For test cases in folders
    shortcut_handler.add_shortcut(STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_ALL_TESTS_IN_DIRECTORY), _get_shortcut_run_test_cases_in_folder_condition.bind(node), _get_shortcut_run_test_cases_in_folder_action.bind(node))
     # For selected test cases only
    shortcut_handler.add_shortcut(STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE), _get_shortcut_run_test_case_condition.bind(node), _get_shortcut_run_test_case_action.bind(node))

func _get_shortcut_run_test_cases_in_folder_condition(node:Node) -> bool:
    if not _can_run_tests:
        return false

    if Engine.get_main_loop().root.gui_get_focus_owner() != node:
        return false

    return true

func _get_shortcut_run_test_case_condition(node:Node) -> bool:
    if not _can_run_tests:
        return false

    if Engine.get_main_loop().root.gui_get_focus_owner() != node:
        return false

    var selected_resource_paths:PackedStringArray = _get_selected_resource_paths(node)
    if not selected_resource_paths.is_empty():
        return selected_resource_paths.size() == 1 and FileAccess.file_exists(selected_resource_paths[0])

    return true

func _get_shortcut_run_test_cases_in_folder_action(node:Node) -> void:
    _do_execute_tests(node, false)

func _get_shortcut_run_test_case_action(node:Node) -> void:
    _do_execute_tests(node, false)

func _on_fs_menu_showing(menu:PopupMenu, container) -> void:
    var selected_resource_paths:PackedStringArray = _get_selected_resource_paths(container)

    if not selected_resource_paths.is_empty():
        if (selected_resource_paths.size() == 1 and DirAccess.dir_exists_absolute(selected_resource_paths[0])) or selected_resource_paths.size() > 1:
            # It's a dir ! We show menu to run all tests in this folder
            menu.add_separator(MenuEntriesRegistry.MENU_SEPARATOR["name"], MenuEntriesRegistry.MENU_SEPARATOR["id"])
            menu.add_icon_shortcut(MenuEntriesRegistry.MENU_RUN_ALL_TESTS_IN_DIRECTORY["icon"], STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_ALL_TESTS_IN_DIRECTORY), MenuEntriesRegistry.MENU_RUN_ALL_TESTS_IN_DIRECTORY["id"])
            menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["icon"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["name"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["id"])
        elif selected_resource_paths.size() == 1 and FileAccess.file_exists(selected_resource_paths[0]):
            # It's a file ! Maybe a GDScript ! Maybe a TestCase !
            if selected_resource_paths[0].get_extension() == "gd":
                var script = ResourceLoader.load(selected_resource_paths[0])
                if script is GDScript:
                    var parsed_gd_script:ParsedGDScript = ParsedGDScript.new()
                    parsed_gd_script.parse(script)
                    if parsed_gd_script.script_parent_class_name == "TestCase":
                        menu.add_separator(MenuEntriesRegistry.MENU_SEPARATOR["name"], MenuEntriesRegistry.MENU_SEPARATOR["id"])
                        menu.add_icon_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE["icon"], STHShortcutFactory.get_shortcut(MenuEntriesRegistry.MENU_RUN_TEST_CASE), MenuEntriesRegistry.MENU_RUN_TEST_CASE["id"])
                        menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["icon"], MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["name"], MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["id"])
        _update_menu_item_availability(menu)

func _get_selected_resource_paths(container:Node) -> PackedStringArray:
    var selected_resource_paths:PackedStringArray = []

    if container is Tree:
        # From FS tree
        var selected_file_or_folder_item:TreeItem = container.get_selected()
        if selected_file_or_folder_item:
            var resource_path = selected_file_or_folder_item.get_metadata(0)
            if resource_path == null:
                push_error("FileSystem tree item metadata 0 should represents resource path.")
            else:
                selected_resource_paths.append(resource_path)
    elif container is ItemList:
        # From FS splitted view
        var selected_items_indexes:PackedInt32Array = container.get_selected_items()
        for i in selected_items_indexes:
            selected_resource_paths.append(container.get_item_metadata(i))

    return selected_resource_paths

func _on_fs_menu_id_pressed(id:int, menu:PopupMenu, container) -> void:
    if MenuEntriesRegistry.is_run_test_case_menu(id) or MenuEntriesRegistry.is_debug_test_case_menu(id):
        var resource_paths:PackedStringArray = []
        var debug_mode:bool = MenuEntriesRegistry.is_debug_test_case_menu(id)
        _do_execute_tests(container, debug_mode)

func _do_execute_tests(container:Node, debug_mode:bool) -> void:
    var resource_paths:PackedStringArray = []
    if container is Tree:
            # Selection from FSTree
        var selected_folder_or_file_item:TreeItem = container.get_selected()
        var resource_path:String = selected_folder_or_file_item.get_metadata(0)
        resource_paths.append(resource_path)
    elif container is ItemList:
            # Selection from splitted view
        var selected_items_indexes:PackedInt32Array = container.get_selected_items()
        for i in selected_items_indexes:
            resource_paths.append(container.get_item_metadata(i))

    if not resource_paths.is_empty():
        _plugin.execute_test_cases_from_path(resource_paths, debug_mode)

func _on_fs_menu_closing(menu:PopupMenu) -> void:
    var all_ids:PackedInt32Array = [
        MenuEntriesRegistry.MENU_SEPARATOR["id"],
        MenuEntriesRegistry.MENU_RUN_ALL_TESTS_IN_DIRECTORY["id"],
        MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["id"],
        MenuEntriesRegistry.MENU_RUN_TEST_CASE["id"],
        MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["id"]
    ]
    for id in all_ids:
        var menu_index:int = menu.get_item_index(id)
        if menu_index != -1:
            menu.remove_item(menu_index)

func _update_menu_item_availability(menu:PopupMenu) -> void:
    if is_instance_valid(menu):
        var all_ids:PackedInt32Array = [
            MenuEntriesRegistry.MENU_SEPARATOR["id"],
            MenuEntriesRegistry.MENU_RUN_ALL_TESTS_IN_DIRECTORY["id"],
            MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["id"],
            MenuEntriesRegistry.MENU_RUN_TEST_CASE["id"],
            MenuEntriesRegistry.MENU_DEBUG_TEST_CASE["id"]
        ]
        for id in all_ids:
            var menu_index:int = menu.get_item_index(id)
            if menu_index != -1:
                menu.set_item_disabled(menu_index, not _can_run_tests)

func _get_popup_menus(parent_node:Node) -> Array[PopupMenu]:
    var menus:Array[PopupMenu] = []
    if parent_node is PopupMenu:
        menus.append(parent_node)
    for child in parent_node.get_children():
        menus.append_array(_get_popup_menus(child))
    return menus

func _get_trees(parent_node:Node) -> Array[Tree]:
    var trees:Array[Tree] = []
    if parent_node is Tree:
        trees.append(parent_node)
    for child in parent_node.get_children():
        trees.append_array(_get_trees(child))
    return trees

func _get_itemlists(parent_node:Node) -> Array[ItemList]:
    var lists:Array[ItemList] = []
    if parent_node is ItemList:
        lists.append(parent_node)
    for child in parent_node.get_children():
        lists.append_array(_get_itemlists(child))
    return lists

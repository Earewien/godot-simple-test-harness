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

    _fs_tree_popup_menu = null
    _fs_item_list_popup_menu = null
    _fs_tree = null
    _fs_item_list = null

    _plugin = null

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _initialize_popup_menu(menu:PopupMenu, container) -> void:
    if not menu.about_to_popup.is_connected(_on_fs_menu_showing):
        menu.about_to_popup.connect(_on_fs_menu_showing.bind(menu, container))
    if not menu.id_pressed.is_connected(_on_fs_menu_closing):
        menu.id_pressed.connect(_on_fs_menu_id_pressed.bind(menu, container))
    if not menu.close_requested.is_connected(_on_fs_menu_closing):
        menu.close_requested.connect(_on_fs_menu_closing.bind(menu))


func _on_fs_menu_showing(menu:PopupMenu, container) -> void:
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

    if not selected_resource_paths.is_empty():
        if (selected_resource_paths.size() == 1 and DirAccess.dir_exists_absolute(selected_resource_paths[0])) or selected_resource_paths.size() > 1:
            # It's a dir ! We show menu to run all tests in this folder
            menu.add_separator(MenuEntriesRegistry.MENU_SEPARATOR["name"], MenuEntriesRegistry.MENU_SEPARATOR["id"])
            menu.add_icon_item(MenuEntriesRegistry.MENU_RUN_ALL_TESTS["icon"], MenuEntriesRegistry.MENU_RUN_ALL_TESTS["name"], MenuEntriesRegistry.MENU_RUN_ALL_TESTS["id"])
            menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["icon"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["name"], MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["id"])
        elif selected_resource_paths.size() == 1 and FileAccess.file_exists(selected_resource_paths[0]):
            # It's a file ! Maybe a GDScript ! Maybe a TestCase !
            if selected_resource_paths[0].get_extension() == "gd":
                var script = ResourceLoader.load(selected_resource_paths[0])
                if script is GDScript:
                    var parsed_gd_script:ParsedGDScript = ParsedGDScript.new()
                    parsed_gd_script.parse(script)
                    if parsed_gd_script.script_parent_class_name == "TestCase":
                        menu.add_separator(MenuEntriesRegistry.MENU_SEPARATOR["name"], MenuEntriesRegistry.MENU_SEPARATOR["id"])
                        menu.add_icon_item(MenuEntriesRegistry.MENU_RUN_TEST["icon"], MenuEntriesRegistry.MENU_RUN_TEST["name"], MenuEntriesRegistry.MENU_RUN_TEST["id"])
                        menu.add_icon_item(MenuEntriesRegistry.MENU_DEBUG_TEST["icon"], MenuEntriesRegistry.MENU_DEBUG_TEST["name"], MenuEntriesRegistry.MENU_DEBUG_TEST["id"])

func _on_fs_menu_id_pressed(id:int, menu:PopupMenu, container) -> void:
    if MenuEntriesRegistry.is_run_test_menu(id) or MenuEntriesRegistry.is_debug_test_menu(id):
        var resource_paths:PackedStringArray = []
        var debug_mode:bool = MenuEntriesRegistry.is_debug_test_menu(id)

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

        _plugin.execute_test_cases_from_path(resource_paths, debug_mode)

func _on_fs_menu_closing(menu:PopupMenu) -> void:
    var all_ids:PackedInt32Array = [
        MenuEntriesRegistry.MENU_SEPARATOR["id"],
        MenuEntriesRegistry.MENU_RUN_ALL_TESTS["id"],
        MenuEntriesRegistry.MENU_DEBUG_ALL_TESTS["id"],
        MenuEntriesRegistry.MENU_RUN_TEST["id"],
        MenuEntriesRegistry.MENU_DEBUG_TEST["id"]
    ]
    for id in all_ids:
        var menu_index:int = menu.get_item_index(id)
        if menu_index != -1:
            menu.remove_item(menu_index)

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

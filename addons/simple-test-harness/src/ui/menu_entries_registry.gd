class_name MenuEntriesRegistry
extends RefCounted

const MENU_SEPARATOR: = {
    "name" : "",
    "id" : 1_888_000
}

const MENU_RUN_ALL_TESTS: = {
    "name" : "Run all test cases",
    "id" : 1_888_001,
    "icon" : IconRegistry.ICON_RUN_TEST,
    "shortcut" : [KEY_ALT, KEY_SHIFT, KEY_T]
}

const MENU_DEBUG_ALL_TESTS: = {
    "name" : "Debug all test cases",
    "id" : 1_888_002,
    "icon" : IconRegistry.ICON_DEBUG_TEST
}

const MENU_RUN_ALL_TESTS_IN_DIRECTORY: = {
    "name" : "Run tests in selected resources",
    "id" : 1_888_003,
    "icon" : IconRegistry.ICON_RUN_TEST,
    "shortcut" : [KEY_ALT, KEY_SHIFT, KEY_F]
}

const MENU_DEBUG_ALL_TESTS_IN_DIRECTORY: = {
    "name" : "Debug tests in selected resources",
    "id" : 1_888_004,
    "icon" : IconRegistry.ICON_DEBUG_TEST
}

const MENU_RUN_TEST_CASE: = {
    "name" : "Run test case",
    "id" : 1_888_005,
    "icon" : IconRegistry.ICON_RUN_TEST,
    "shortcut" : [KEY_CTRL, KEY_ALT, KEY_T]
}

const MENU_DEBUG_TEST_CASE: = {
    "name" : "Debug test case",
    "id" : 1_888_006,
    "icon" : IconRegistry.ICON_DEBUG_TEST
}

const MENU_RUN_TEST_CASE_METHOD: = {
    "name" : "Run test function",
    "id" : 1_888_007,
    "icon" : IconRegistry.ICON_RUN_TEST,
    "shortcut" : [KEY_CTRL, KEY_ALT, KEY_M]
}

const MENU_DEBUG_TEST_CASE_METHOD: = {
    "name" : "Debug test function",
    "id" : 1_888_008,
    "icon" : IconRegistry.ICON_DEBUG_TEST
}

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

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func is_run_test_case_menu(id:int) -> bool:
    return id == MENU_RUN_ALL_TESTS["id"] or id == MENU_RUN_TEST_CASE["id"]  or id == MENU_RUN_ALL_TESTS_IN_DIRECTORY["id"]

static func is_debug_test_case_menu(id:int) -> bool:
    return  id == MENU_DEBUG_ALL_TESTS["id"] or id == MENU_DEBUG_TEST_CASE["id"]  or id == MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["id"]

static func is_run_test_case_in_directory_menu(id:int) -> bool:
    return id == MENU_RUN_ALL_TESTS_IN_DIRECTORY["id"]

static func is_debug_test_case_directory_menu(id:int) -> bool:
    return  id == MENU_DEBUG_ALL_TESTS_IN_DIRECTORY["id"]

static func is_run_test_case_method_menu(id:int) -> bool:
    return id == MENU_RUN_TEST_CASE_METHOD["id"]

static func is_debug_test_case_method_menu(id:int) -> bool:
    return id == MENU_DEBUG_TEST_CASE_METHOD["id"]

#------------------------------------------
# Fonctions privées
#------------------------------------------


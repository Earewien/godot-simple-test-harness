class_name MenuEntriesRegistry
extends RefCounted

const MENU_SEPARATOR: = { "name" : "", "id" : 1_888_000 }
const MENU_RUN_ALL_TESTS: = { "name" : "Run all tests", "id" : 1_888_001, "icon" : IconRegistry.ICON_RUN_TEST}
const MENU_DEBUG_ALL_TESTS: = { "name" : "Debug all tests", "id" : 1_888_002, "icon" : IconRegistry.ICON_DEBUG_TEST}
const MENU_RUN_TEST: = { "name" : "Run test", "id" : 1_888_003, "icon" : IconRegistry.ICON_RUN_TEST}
const MENU_DEBUG_TEST: = { "name" : "Debug test", "id" : 1_888_004, "icon" : IconRegistry.ICON_DEBUG_TEST}

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

static func is_run_test_menu(id:int) -> bool:
    return id == MENU_RUN_ALL_TESTS["id"] or id == MENU_RUN_TEST["id"]

static func is_debug_test_menu(id:int) -> bool:
    return  id == MENU_DEBUG_ALL_TESTS["id"] or id == MENU_DEBUG_TEST["id"]

#------------------------------------------
# Fonctions privées
#------------------------------------------


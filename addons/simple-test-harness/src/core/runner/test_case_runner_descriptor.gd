class_name TestCaseRunnerDescriptor
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

var test_case_name:String
var test_case_path:String
var test_case_has_default_constructor:bool
# Format
# {
#     "name" : "aaaa",
#     "line_number" : 42,
#     "arg_count" : 0,
#     "is_coroutine" : true/false
# }
var test_case_test_methods:Array[Dictionary] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


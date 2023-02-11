class_name STHTestCasePlan
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
var has_default_constructor:bool
var test_case_methods:Array[STHTestCaseMethodPlan] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func from_parsed_script(parsed_script:ParsedGDScript) -> STHTestCasePlan:
    var test_plan:STHTestCasePlan = STHTestCasePlan.new()
    test_plan.test_case_name = parsed_script.script_class_name
    test_plan.test_case_path = parsed_script.script_path
    test_plan.has_default_constructor = parsed_script.has_default_constructor()
    for function in parsed_script.script_functions:
        if test_plan._is_test_function(function):
            test_plan.test_case_methods.append(STHTestCaseMethodPlan.from_parsed_function(function))
    return test_plan

static func deserialize(data:Dictionary) -> STHTestCasePlan:
    var test_plan:STHTestCasePlan = STHTestCasePlan.new()
    test_plan.test_case_name = data["test_case_name"]
    test_plan.test_case_path = data["test_case_path"]
    test_plan.has_default_constructor = data["has_default_constructor"]
    for stcm in data["test_case_methods"]:
        test_plan.test_case_methods.append(STHTestCaseMethodPlan.deserialize(stcm))
    return test_plan

func serialize() -> Dictionary:
    return {
        "test_case_name" : test_case_name,
        "test_case_path" : test_case_path,
        "has_default_constructor" : has_default_constructor,
        "test_case_methods" : test_case_methods.map(func(tcm):return tcm.serialize()),
    }

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func has_test_methods() -> bool:
    return not test_case_methods.is_empty()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _is_test_function(function:ParsedGDScriptFunction) -> bool:
    return function.function_name.begins_with("test") \
        and function.function_returned_type == TYPE_NIL \
        and not function.is_static \
        and not function.is_virtual \
        and not function.is_editor

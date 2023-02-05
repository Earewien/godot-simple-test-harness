class_name TestCasePlan
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
var test_case_methods:Array[TestCaseMethodPlan] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func from(parsed_test_case:ParsedGDScript) -> TestCasePlan:
    var test_plan:TestCasePlan = TestCasePlan.new()
    test_plan.test_case_name = parsed_test_case.script_class_name
    test_plan.test_case_path = parsed_test_case.script_path
    test_plan.has_default_constructor = parsed_test_case.has_default_constructor()
    test_plan._read_test_case_methods(parsed_test_case)
    return test_plan

static func deserialize(data:Dictionary) -> TestCasePlan:
    var test_plan:TestCasePlan = TestCasePlan.new()
    test_plan.test_case_name = data["test_case_name"]
    test_plan.test_case_path = data["test_case_path"]
    test_plan.has_default_constructor = data["has_default_constructor"]
    for stcm in data["test_case_methods"]:
        test_plan.test_case_methods.append(TestCaseMethodPlan.deserialize(stcm))
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

func _read_test_case_methods(parsed_test_case:ParsedGDScript) -> void:
    for function in parsed_test_case.script_functions:
        if function.function_name.begins_with("test") \
            and function.function_returned_type == TYPE_NIL \
            and not function.is_static \
            and not function.is_virtual \
            and not function.is_editor:
            test_case_methods.append(TestCaseMethodPlan.from(function))

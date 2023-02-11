class_name STHTestCaseFinished
extends RefCounted

enum {
    TEST_CASE_STATUS_SUCCESSFUL,
    TEST_CASE_STATUS_SKIPPED,
    TEST_CASE_STATUS_UNSTABLE,
    TEST_CASE_STATUS_FAILED
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

var test_case_name:String
var test_case_path:String
var test_case_execution_time_ms:int
var test_case_status:int

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func deserialize(data:Dictionary) ->  STHTestCaseFinished:
    var message:STHTestCaseFinished = STHTestCaseFinished.new()
    message.test_case_name = data["test_case_name"]
    message.test_case_path = data["test_case_path"]
    message.test_case_execution_time_ms = data["test_case_execution_time_ms"]
    message.test_case_status = data["test_case_status"]
    return message

func serialize() -> Dictionary:
    return {
        "test_case_name" : test_case_name,
        "test_case_path" : test_case_path,
        "test_case_execution_time_ms" : test_case_execution_time_ms,
        "test_case_status" : test_case_status
    }

func get_type() -> String:
    return "STHTestCaseFinished"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


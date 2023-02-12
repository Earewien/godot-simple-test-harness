class_name STHRunnerMessageHandler
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

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func create_message(message:Variant) -> String:
    return var_to_str({
        "type" : message.get_type(),
        "message" : message.serialize()
    })

static func get_message(raw_message:String) -> Variant:
    var script_type:GDScript = null
    var var_message:Dictionary = str_to_var(raw_message)

    match var_message["type"]:
        # -- CLIENT
        "STHTestsuiteClientReady":
            script_type = STHTestsuiteClientReady
        "STHTestsuitePlanReady":
            script_type = STHTestsuitePlanReady
        "STHTestsuiteStarted" :
            script_type = STHTestsuiteStarted
        "STHTestCaseStarted" :
            script_type = STHTestCaseStarted
        "STHTestCaseMethodStarted" :
            script_type = STHTestCaseMethodStarted
        "STHTestCaseMethodReport" :
            script_type = STHTestCaseMethodReport
        "STHTestCaseFinished" :
            script_type = STHTestCaseFinished
        "STHTestsuiteFinished" :
            script_type = STHTestsuiteFinished
        # -- SERVER
        "STHRunSingleTestCommand" :
            script_type = STHRunSingleTestCommand
        "STHRunTestsCommand" :
            script_type = STHRunTestsCommand
        "STHStopTestsuite" :
            script_type = STHStopTestsuite
        _:
            push_error("Unknown server message type %s" % var_message["type"])

    if script_type != null:
        return Callable(script_type, "deserialize").call(var_message["message"])
    return null


#------------------------------------------
# Fonctions privées
#------------------------------------------


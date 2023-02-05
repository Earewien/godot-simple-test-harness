class_name RunExecutionPlanAction
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

var _execution_plan:BuildExecutionPlanReport
var _headless_runner:HeadlessGodotRunner

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(execution_plan:BuildExecutionPlanReport) -> void:
    _execution_plan = execution_plan

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> RunExecutionPlanReport:
    var output_file:TempFile = TempFile.new("er")
    var plan_file:TempFile = TempFile.new("ep")
    plan_file.set_file_content(var_to_str(_execution_plan.serialize()))

    var arguments:PackedStringArray = [
        "--execute-plan",
        plan_file.get_file_path(),
        "--output",
        output_file.get_file_path()
    ]
    _headless_runner = HeadlessGodotRunner.new(arguments)
    _headless_runner.start()
    await _headless_runner.on_process_terminated
    plan_file.delete()

    if _headless_runner.get_exit_code() == 0:
        var output_content:String = output_file.get_file_content()
        output_file.delete()
        return RunExecutionPlanReport.deserialize(str_to_var(output_content))
    else:
        push_error("Fail to run execution plan.")
        return null

#------------------------------------------
# Fonctions privées
#------------------------------------------

extends Node2D
class_name UnitTestRunner

#------------------------------------------
# Signaux
#------------------------------------------

signal build_plan_ready(bep:BuildExecutionPlanReport)
signal execution_report_ready(er:RunExecutionPlanReport)

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

var running:bool = false
var finish:bool = false

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _process(delta: float) -> void:
    if not running:
        running = true
        set_directory("res://")
    if finish:
        get_tree().quit(0)


func set_directory(dir:String) -> void:
    await get_tree().create_timer(1).timeout
    var list_cmd:ListTestCaseCommand = ListTestCaseCommand.new(dir)
    var lts_report:ListTestCaseReport = list_cmd.execute()
    var bep_report:BuildExecutionPlanReport = BuildExecutionPlanAction.new(lts_report).execute()
    build_plan_ready.emit(bep_report)
    var tmp_report:TempFile = TempFile.new("rr")
    tmp_report.set_file_content(var_to_str(bep_report.serialize()))
    var rep_report:RunExecutionPlanReport = await RunExecutionPlanCommand.new(tmp_report.get_file_path()).execute()
    tmp_report.delete()
    execution_report_ready.emit(rep_report)
    finish = true

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


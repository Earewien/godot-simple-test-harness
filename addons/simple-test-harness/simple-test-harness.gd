@tool
class_name SimpleTestHarnessPlugin
extends EditorPlugin

const PLUGIN_ENGINE_META:String = "STHPlugin"

var _ui_handler:UISTHHandler
var _report_viewer:Control

func _enter_tree() -> void:
    if not Engine.has_meta(PLUGIN_ENGINE_META):
        Engine.set_meta(PLUGIN_ENGINE_META, self)
    _ui_handler = UISTHHandler.new()
    _ui_handler.initialize()

    _report_viewer = preload("res://addons/simple-test-harness/src/ui/report_viewer/report_viewer.tscn").instantiate()
    add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _report_viewer)

func _exit_tree() -> void:
    remove_control_from_docks(_report_viewer)

    if _ui_handler:
        _ui_handler.finalize()
        _ui_handler = null
    if Engine.has_meta(PLUGIN_ENGINE_META):
        Engine.remove_meta(PLUGIN_ENGINE_META)

#func _run_process_in_editor() -> void:
#    get_editor_interface().play_custom_scene("res://addons/simple-test-harness/src/command_line/runner/uni_test_runner.tscn")

func execute_test_cases_from_path(paths:PackedStringArray, debug_mode:bool = false) -> void:
    _report_viewer.clear_report()
    var lts_report:ListTestCaseReport = await ListTestCaseAction.new(paths).execute()
    var bep_report:BuildExecutionPlanReport = BuildExecutionPlanAction.new(lts_report).execute()
    _report_viewer.initialize_with_build_plan(bep_report)
    var rep_report:RunExecutionPlanReport = await RunExecutionPlanAction.new(bep_report).execute()
    _report_viewer.show_execution_report(rep_report)

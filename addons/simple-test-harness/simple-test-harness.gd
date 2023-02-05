@tool
extends EditorPlugin

var _report_viewer:Control

func _enter_tree() -> void:
    _report_viewer = preload("res://addons/simple-test-harness/src/ui/report_viewer/report_viewer.tscn").instantiate()
    add_tool_menu_item("Run TEST", _run_process)
    add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _report_viewer)

func _exit_tree() -> void:
    remove_control_from_docks(_report_viewer)
    remove_tool_menu_item("Run TEST")
    remove_tool_menu_item("Run TEST 2")
    remove_tool_menu_item("Run TEST 3")

func _run_process() -> void:
    _report_viewer.clear_report()
    var lts_report:ListTestCaseReport = await ListTestCaseAction.new().execute()
    var bep_report:BuildExecutionPlanReport = BuildExecutionPlanAction.new(lts_report).execute()
    _report_viewer.initialize_with_build_plan(bep_report)
    var rep_report:RunExecutionPlanReport = await RunExecutionPlanAction.new(bep_report).execute()
    _report_viewer.show_execution_report(rep_report)

func _run_process_in_editor() -> void:
    get_editor_interface().play_custom_scene("res://addons/simple-test-harness/src/command_line/runner/uni_test_runner.tscn")

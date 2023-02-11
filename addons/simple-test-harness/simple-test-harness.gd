@tool
class_name SimpleTestHarnessPlugin
extends EditorPlugin

const PLUGIN_ENGINE_META:String = "STHPlugin"
const PLUGIN_TCP_SERVER_META:String = "STHPluginTcpServer"
const PLUGIN_ORCHESTRATOR_META:String = "STHPluginOrchestrator"

var _ui_handler:UISTHHandler
var _report_viewer:Control
var _tcp_server:STHTCPServer

var _orchestrator:STHOrchestrator

func _enter_tree() -> void:
    if not Engine.has_meta(PLUGIN_ENGINE_META):
        Engine.set_meta(PLUGIN_ENGINE_META, self)

    if not is_instance_valid(_tcp_server):
        _tcp_server = preload("res://addons/simple-test-harness/src/core/network/sth_tcp_server.tscn").instantiate()
        Engine.set_meta(PLUGIN_TCP_SERVER_META, _tcp_server)
        add_child(_tcp_server)
        _tcp_server.start()

    if not Engine.has_meta(PLUGIN_ORCHESTRATOR_META):
        _orchestrator = STHOrchestrator.new()
        Engine.set_meta(PLUGIN_ORCHESTRATOR_META, _orchestrator)
        add_child(_orchestrator)

    _ui_handler = UISTHHandler.new()
    _ui_handler.initialize()

    _report_viewer = preload("res://addons/simple-test-harness/src/ui/report_viewer/report_viewer.tscn").instantiate()
    add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _report_viewer)


func _exit_tree() -> void:
    remove_control_from_docks(_report_viewer)
    _report_viewer.queue_free()
    _report_viewer = null

    if _ui_handler:
        _ui_handler.finalize()
        _ui_handler = null

    if is_instance_valid(_orchestrator):
        Engine.remove_meta(PLUGIN_ORCHESTRATOR_META)
        remove_child(_orchestrator)
        _orchestrator.finalize()
        _orchestrator.queue_free()

    if is_instance_valid(_tcp_server):
        remove_child(_tcp_server)
        _tcp_server.stop()
        Engine.remove_meta(PLUGIN_TCP_SERVER_META)
        _tcp_server.queue_free()
        _tcp_server = null

    if Engine.has_meta(PLUGIN_ENGINE_META):
        Engine.remove_meta(PLUGIN_ENGINE_META)

func execute_test_cases_from_path(paths:PackedStringArray, debug_mode:bool = false) -> void:
    _orchestrator.run_test_suite_from_paths(paths)
    get_editor_interface().play_custom_scene("res://addons/simple-test-harness/src/core/runner/test_suite_runner.tscn")

func execute_test_case_method(script_path:String, method_name:String, debug_mode:bool = false) -> void:
    _orchestrator.run_test_test_case_method(script_path, method_name)
    get_editor_interface().play_custom_scene("res://addons/simple-test-harness/src/core/runner/test_suite_runner.tscn")

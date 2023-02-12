@tool
class_name SimpleTestHarnessPlugin
extends EditorPlugin

const PLUGIN_ENGINE_META:String = "STHPlugin"
const PLUGIN_TCP_SERVER_META:String = "STHPluginTcpServer"
const PLUGIN_ORCHESTRATOR_META:String = "STHPluginOrchestrator"

var _ui_handler:UISTHHandler
var _tcp_server:STHTCPServer

var _orchestrator:STHOrchestrator
var _headless_runner:HeadlessTestSuiteRunner

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

func _exit_tree() -> void:
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
    _launch_test_runner(debug_mode)

func execute_test_case_method(script_path:String, method_name:String, debug_mode:bool = false) -> void:
    _orchestrator.run_test_test_case_method(script_path, method_name)
    _launch_test_runner(debug_mode)

func _launch_test_runner(degub_mode:bool) -> void:
    # In debug mode, directly play a scene, since we can benefit from godot debugger (breakpoints and all)
    # Without debug, we use the headless runner
    # TODO in debug mode : add a debugger plugin, to inspect breaks ; if its breaksq on an error, test is a failure
    if degub_mode:
        get_editor_interface().play_custom_scene("res://addons/simple-test-harness/src/core/runner/test_suite_runner.tscn")
    else:
        if is_instance_valid(_headless_runner):
            # Should never happen
            push_error("Cannot launch another headless runner")
            return

        _headless_runner = HeadlessTestSuiteRunner.new()
        _headless_runner.on_process_terminated.connect(_on_headless_runner_terminated, Node.CONNECT_ONE_SHOT)
        _headless_runner.start()

func _on_headless_runner_terminated(exit_code:int) -> void:
    if exit_code != 0:
        push_error("Headless runnner exited with code %s" % exit_code)
    _headless_runner = null

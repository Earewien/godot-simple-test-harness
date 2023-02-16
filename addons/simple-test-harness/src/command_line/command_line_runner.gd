class_name CommandLineRunner
extends SceneTree

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var CMD_ARG_LOOKUP_PATHS: = CommandLineArgument.new("-lp", "--lookup-paths", "Coma separated list of paths where to look for test cases to run", TYPE_STRING)
var CMD_ARG_OUTPUT_DIR: = CommandLineArgument.new("-o", "--output", "Output directory, where reports will be generated", TYPE_STRING)

#------------------------------------------
# Variables privées
#------------------------------------------

var _orchestrator:STHOrchestrator
var _xml_reporter:XMLUnitReporter
var _runner:TestSuiteRunner
var _tcp_server:STHTCPServer

var _testsuite_running:bool = false

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init() -> void:
    var command_line_arguments:PackedStringArray = OS.get_cmdline_args()

    var option_lookup_paths:CommandLineOption = CMD_ARG_LOOKUP_PATHS.parse_args(command_line_arguments)
    var option_output_dir:CommandLineOption = CMD_ARG_OUTPUT_DIR.parse_args(command_line_arguments)

    if option_lookup_paths != null and option_lookup_paths.valid \
        and option_output_dir != null and option_output_dir.valid:
            pass
    else:
        push_error("Missing command line argument. Quitting...")
        quit(-1000)

    _tcp_server = preload("res://addons/simple-test-harness/src/core/network/sth_tcp_server.tscn").instantiate()
    Engine.set_meta(SimpleTestHarnessPlugin.PLUGIN_TCP_SERVER_META, _tcp_server)
    root.add_child(_tcp_server)
    _tcp_server.start()

    _orchestrator = STHOrchestrator.new()
    Engine.set_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META, _orchestrator)
    root.add_child(_orchestrator)

    _xml_reporter = XMLUnitReporter.new()
    _xml_reporter.output_directory = option_output_dir.value

    _runner = preload("res://addons/simple-test-harness/src/core/runner/test_suite_runner.tscn").instantiate()
    root.add_child(_runner)

    _orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)

    _orchestrator.run_test_suite_from_paths(option_lookup_paths.value.split(","), true)

func _on_orchestrator_state_changed(state:int) -> void:
    if state != STHOrchestrator.ORCHESTRATOR_STATE_IDLE:
        if not _testsuite_running:
            _testsuite_running = true
    if _testsuite_running and state == STHOrchestrator.ORCHESTRATOR_STATE_IDLE:
        # Testsuite done !
        root.remove_child(_runner)
        _runner.queue_free()
        _runner = null

        _orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)
        _orchestrator.finalize()
        root.remove_child(_orchestrator)
        _orchestrator.queue_free()
        _orchestrator = null
        Engine.remove_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)

        _tcp_server.stop()
        root.remove_child(_tcp_server)
        _tcp_server.queue_free()
        _tcp_server = null
        Engine.remove_meta(SimpleTestHarnessPlugin.PLUGIN_TCP_SERVER_META)

        var success:bool = _xml_reporter.is_last_testsuite_successful()
        _xml_reporter.finalize()
        _xml_reporter = null

        await Engine.get_main_loop().process_frame
        quit(0 if success else 1)



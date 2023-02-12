class_name HeadlessTestSuiteRunner
extends RefCounted

const DEFAULT_ARGS:PackedStringArray = ["--headless"]

#------------------------------------------
# Signaux
#------------------------------------------

signal on_process_started
signal on_process_terminated(code:int)

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var verbose:bool = false
var print_process_output:bool = false

#------------------------------------------
# Variables privées
#------------------------------------------

var _arguments:PackedStringArray
var _thread:Thread
var _exit_code:int
var _execution_time:int

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(args:PackedStringArray = []) -> void:
    _arguments = []
    _arguments.append_array(DEFAULT_ARGS)
    # Ne peut pas être fait dans la constante !
    _arguments.append("--path")
    _arguments.append(ProjectSettings.globalize_path("res://"))
    _arguments.append("res://addons/simple-test-harness/src/core/runner/test_suite_runner.tscn")
    _arguments.append_array(args)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func start() -> void:
    if verbose:
        _arguments.insert(0, "--verbose")
    _thread = Thread.new()
    _thread.start(_do_run_godot)
    on_process_started.emit()

func get_exit_code() -> int:
    return _exit_code

func get_execution_time_ms() -> int:
    return _execution_time

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _do_run_godot() -> void:
    var std_out:Array = []
    var start_time:int = Time.get_ticks_msec()
    _exit_code = OS.execute(OS.get_executable_path(), _arguments, std_out, true, false)
    var stop_time:int = Time.get_ticks_msec()
    if print_process_output or _exit_code != 0:
        for s in std_out:
            print(s)

    _execution_time = stop_time - start_time

    call_deferred("_on_process_exited")

func _on_process_exited() -> void:
    _thread.wait_to_finish()
    _thread = null
    on_process_terminated.emit(_exit_code)

class_name STHOrchestrator
extends Node

enum {
    ORCHESTRATOR_STATE_IDLE,
    ORCHESTRATOR_STATE_PREPARING_TESTSUITE,
    ORCHESTRATOR_STATE_RUNNING_TESTSUITE,
}

#------------------------------------------
# Signaux
#------------------------------------------

signal on_state_changed(state:int)
signal on_runner_message_received(message)

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

var _state:int = ORCHESTRATOR_STATE_IDLE

var _tcp_server:STHTCPServer
var _pending_client_command:Variant

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _ready() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_TCP_SERVER_META):
        push_error("Orchestrator can not find TCP server...")
        return

    _tcp_server = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_TCP_SERVER_META)
    _tcp_server.on_client_connected.connect(_on_tcp_server_client_connected)
    _tcp_server.on_client_message_received.connect(_on_tcp_server_client_message_received)
    _tcp_server.on_client_disconnected.connect(_on_tcp_server_client_disconnected)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func run_test_suite_from_paths(paths:PackedStringArray) -> void:
    if _state != ORCHESTRATOR_STATE_IDLE:
        push_error("Orchestrator can not run a new testsuite : not idle")
        return

    var command:STHRunTestsCommand = STHRunTestsCommand.new()
    command.lookup_paths = paths
    _pending_client_command = command

    _change_state(ORCHESTRATOR_STATE_PREPARING_TESTSUITE)

func run_test_test_case_method(test_case_path:String, test_case_method_name:String) -> void:
    if _state != ORCHESTRATOR_STATE_IDLE:
        push_error("Orchestrator can not run a new test case method : not idle")
        return

    var command:STHRunSingleTestCommand = STHRunSingleTestCommand.new()
    command.test_case_path = test_case_path
    command.test_case_method_name = test_case_method_name
    _pending_client_command = command

    _change_state(ORCHESTRATOR_STATE_PREPARING_TESTSUITE)

func stop_testsuite() -> void:
    if _state == ORCHESTRATOR_STATE_IDLE:
        push_error("Orchestrator can not stop testsuite : idle")
        return
    _tcp_server.send_data(STHRunnerMessageHandler.create_message(STHStopTestsuite.new()))

func finalize() -> void:
    if is_instance_valid(_tcp_server):
        _tcp_server.on_client_connected.disconnect(_on_tcp_server_client_connected)
        _tcp_server.on_client_message_received.disconnect(_on_tcp_server_client_message_received)
        _tcp_server.on_client_disconnected.disconnect(_on_tcp_server_client_disconnected)
        _tcp_server = null

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _change_state(new_state:int) -> void:
    _state = new_state
    on_state_changed.emit(_state)

func _on_tcp_server_client_connected() -> void:
    if _state != ORCHESTRATOR_STATE_PREPARING_TESTSUITE:
        push_error("STH Runner connection not expected in state %s" % ORCHESTRATOR_STATE_PREPARING_TESTSUITE)
        return

func _on_tcp_server_client_message_received(msg:String) -> void:
    if _state == ORCHESTRATOR_STATE_PREPARING_TESTSUITE:
        # We were waiting for client connection, send him the command
        if _pending_client_command != null:
            _tcp_server.send_data(STHRunnerMessageHandler.create_message(_pending_client_command))
            _pending_client_command = null
            _change_state(ORCHESTRATOR_STATE_RUNNING_TESTSUITE)
        else:
            push_error("Client connected but no command to send (msg:%s)" % msg)
    elif _state == ORCHESTRATOR_STATE_RUNNING_TESTSUITE:
        # Client is sending messages, decode them, and process them
        on_runner_message_received.emit(STHRunnerMessageHandler.get_message(msg))
    else:
        push_error("Receiving messages from client, but orchestrator is idle (msg:%s)" % msg)

func _on_tcp_server_client_disconnected() -> void:
    _change_state(ORCHESTRATOR_STATE_IDLE)




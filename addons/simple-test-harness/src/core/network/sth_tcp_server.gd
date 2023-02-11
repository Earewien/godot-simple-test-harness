@tool
class_name STHTCPServer
extends Node

const TCP_SESSION_SCENE:PackedScene = preload("res://addons/simple-test-harness/src/core/network/sth_tcp_client_session.tscn")
const SERVER_PORT:int = 40774

#------------------------------------------
# Signaux
#------------------------------------------

signal on_client_connected
signal on_client_message_received(message:String)
signal on_client_disconnected

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

var _tcp_server:TCPServer
var _tcp_client_session:STHTCPClientSession

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _process(delta: float) -> void:
    if not is_instance_valid(_tcp_server):
        # Not started yet
        return


    # Handle server, should be done only once !
    if _tcp_server.is_listening():
        if _tcp_server.is_connection_available():
            if not is_instance_valid(_tcp_client_session):
                _tcp_client_session = TCP_SESSION_SCENE.instantiate()
                _tcp_client_session.on_connection.connect(_on_session_connected)
                _tcp_client_session.on_message_received.connect(_on_session_message_received)
                _tcp_client_session.on_disconnection.connect(_on_session_disconnected)
                _tcp_client_session.set_peer(_tcp_server.take_connection())

                add_child(_tcp_client_session)
            else:
                # Consume the connection anyway, and close it
                push_error("A client is already connected to STH server. Connection rejected")
                var connection:= _tcp_server.take_connection()
                connection.disconnect_from_host()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func start(port:int = SERVER_PORT) -> bool:
    _tcp_server = TCPServer.new()
    var error:int = _tcp_server.listen(port, "127.0.0.1")
    if error != OK:
        push_error("Unable to start STH server : %s" % error_string(error))
        return false
    return true

func send_data(data:String) -> void:
    if is_instance_valid(_tcp_client_session):
        _tcp_client_session.send_data(data)

func stop() -> void:
    if is_instance_valid(_tcp_client_session) and _tcp_client_session.is_session_connected():
        remove_child(_tcp_client_session)
        _tcp_client_session.disconnect_from_host()
        _tcp_client_session.queue_free()
        _tcp_client_session = null
        on_client_disconnected.emit()
    if is_instance_valid(_tcp_server):
        _tcp_server.stop()
        _tcp_server = null

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_session_connected() -> void:
    on_client_connected.emit()

func _on_session_message_received(message:String) -> void:
    on_client_message_received.emit(message)

func _on_session_disconnected() -> void:
    if is_instance_valid(_tcp_client_session) and get_children().has(_tcp_client_session):
        remove_child(_tcp_client_session)
        _tcp_client_session.queue_free()
        _tcp_client_session = null
    on_client_disconnected.emit()

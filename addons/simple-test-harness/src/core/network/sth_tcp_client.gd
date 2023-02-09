@tool
class_name STHTCPClient
extends Node

const TCP_SESSION_SCENE:PackedScene = preload("res://addons/simple-test-harness/src/core/network/sth_tcp_client_session.tscn")

#------------------------------------------
# Signaux
#------------------------------------------

signal on_connection
signal on_message_received(message:String)
signal on_disconnection

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

var _tcp_session:STHTCPClientSession

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func start(host:String = "127.0.0.1", port:int = STHTCPServer.SERVER_PORT) -> bool:
    var tcp_client:StreamPeerTCP = StreamPeerTCP.new()
    var error:int = tcp_client.connect_to_host(host, port)
    if error == OK:
        _tcp_session = TCP_SESSION_SCENE.instantiate()
        _tcp_session.set_peer(tcp_client)

        _tcp_session.on_connection.connect(_on_session_connected)
        _tcp_session.on_message_received.connect(_on_session_message_received)
        _tcp_session.on_disconnection.connect(_on_session_disconnected)
        add_child(_tcp_session)
        return true
    else:
        push_error("Unable to connect to %s:%s : %s" % [host, port, error])
        tcp_client.disconnect_from_host()
        tcp_client.free()
        tcp_client = null
        return false

func send_data(data:String) -> void:
    if is_instance_valid(_tcp_session):
        _tcp_session.send_data(data)

func stop() -> void:
    if is_instance_valid(_tcp_session) and _tcp_session.is_session_connected():
        remove_child(_tcp_session)
        _tcp_session.disconnect_from_host()
        _tcp_session.queue_free()
        _tcp_session = null
        on_disconnection.emit()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_session_connected() -> void:
    on_connection.emit()

func _on_session_message_received(message:String) -> void:
    on_message_received.emit(message)

func _on_session_disconnected() -> void:
    stop()

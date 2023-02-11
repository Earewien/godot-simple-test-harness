@tool
class_name STHTCPClientSession
extends Node

const MESSAGE_DELIMITER:String = "::end_of_sth_message::"

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

var _peer:StreamPeerTCP
var _connected:bool = false
var _tcp_client_data_buffer:String

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _process(delta: float) -> void:
    if is_instance_valid(_peer):
        var poll_error:int = _peer.poll()
        if poll_error != OK:
            push_error("Poll failed : %s" % error_string(poll_error))

        match _peer.get_status():
            StreamPeerTCP.STATUS_NONE:
                if _connected:
                    # Disconnection !
                    disconnect_from_host()
            StreamPeerTCP.STATUS_CONNECTING:
                pass
            StreamPeerTCP.STATUS_CONNECTED:
                if not _connected:
                    _connected = true
                    on_connection.emit()

                var available_bytes:int = _peer.get_available_bytes()
                if available_bytes > 0:
                    var result:Array = _peer.get_partial_data(available_bytes)
                    if result[0] == OK:
                        _tcp_client_data_buffer += result[1].get_string_from_ascii()
                        _try_do_read_full_data_from_buffer()
                    else:
                        push_error("Fail to read data from server : %s" % error_string(result[0]))
            StreamPeerTCP.STATUS_ERROR:
                push_error("An error occurred while connecting to server...")
                # We try to release if not already done
                disconnect_from_host()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func set_peer(peer:StreamPeerTCP) -> void:
    _peer = peer
#    _peer.set_no_delay(true)

func is_session_connected() -> bool:
    return _connected

func send_data(data:String) -> void:
    if is_instance_valid(_peer):
        _peer.put_data(("%s%s" % [data, MESSAGE_DELIMITER]).to_ascii_buffer())

func disconnect_from_host() -> void:
    if is_instance_valid(_peer):
        _peer.disconnect_from_host()
        _connected = false
        _peer = null
        on_disconnection.emit()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _try_do_read_full_data_from_buffer() -> void:
    var index_of_delimiter:int = _tcp_client_data_buffer.find(MESSAGE_DELIMITER)
    while index_of_delimiter != -1:
        var message:String = _tcp_client_data_buffer.substr(0, index_of_delimiter)
        _tcp_client_data_buffer = _tcp_client_data_buffer.substr(index_of_delimiter + MESSAGE_DELIMITER.length())
        index_of_delimiter = _tcp_client_data_buffer.find(MESSAGE_DELIMITER)
        on_message_received.emit(message)

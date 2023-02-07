class_name STHTCPClient
extends Node

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

var _tcp_client:StreamPeerTCP = StreamPeerTCP.new()
var _tcp_client_data_buffer:String
var _connected:bool = false

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _process(delta: float) -> void:
    match _tcp_client.get_status():
        StreamPeerTCP.STATUS_NONE:
            pass
        StreamPeerTCP.STATUS_CONNECTING:
            var poll_error:int = _tcp_client.poll()
            if poll_error != OK:
                push_error("Poll failed : %s" % error_string(poll_error))
        StreamPeerTCP.STATUS_CONNECTED:
            if not _connected:
                _connected = true
                on_connection.emit()

            var poll_error:int = _tcp_client.poll()
            if poll_error != OK:
                push_error("Poll failed : %s" % error_string(poll_error))
            var available_bytes:int = _tcp_client.get_available_bytes()
            if available_bytes > 0:
                var result:Array = _tcp_client.get_partial_data(available_bytes)
                if result[0] == OK:
                    _tcp_client_data_buffer += result[1].get_string_from_ascii()
                    _try_do_read_full_data_from_buffer()
                else:
                    push_error("Fail to read data from server : %s" % error_string(result[0]))
        StreamPeerTCP.STATUS_ERROR:
            push_error("An error occurred while connecting to server...")
            # We try to release if not already done
            _tcp_client.disconnect_from_host()
            _connected = false
            on_disconnection.emit()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func start(host:String = "127.0.0.1", port:int = STHTCPServer.SERVER_PORT) -> bool:
    _tcp_client = StreamPeerTCP.new()
    var error:int = _tcp_client.connect_to_host(host, port)
    if error == OK:
        return true
    else:
        push_error("Unable to connect to %s:%s : %s" % [host, port, error])
        return false

func send_data(data:String) -> void:
    if is_instance_valid(_tcp_client):
        _tcp_client.put_data(("%s%s" % [data, STHTCPServer.MESSAGE_DELIMITER]).to_ascii_buffer())

func stop() -> void:
    if is_instance_valid(_tcp_client):
        _tcp_client.disconnect_from_host()
        if _connected:
            _connected = false
            on_disconnection.emit()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _try_do_read_full_data_from_buffer() -> void:
    var index_of_delimiter:int = _tcp_client_data_buffer.find(STHTCPServer.MESSAGE_DELIMITER)
    while index_of_delimiter != -1:
        var message:String = _tcp_client_data_buffer.substr(0, index_of_delimiter)
        _tcp_client_data_buffer = _tcp_client_data_buffer.substr(index_of_delimiter + STHTCPServer.MESSAGE_DELIMITER.length())
        index_of_delimiter = _tcp_client_data_buffer.find(STHTCPServer.MESSAGE_DELIMITER)

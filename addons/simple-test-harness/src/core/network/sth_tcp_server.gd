class_name STHTCPServer
extends Node

const SERVER_PORT:int = 40774
const MESSAGE_DELIMITER:String = "::end_of_sth_message::"

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
var _tcp_client:StreamPeerTCP
var _tcp_client_data_buffer:String

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _process(delta: float) -> void:
    # Handle server, should be done only once !
    if _tcp_server.is_listening():
        if _tcp_server.is_connection_available():
            if not is_instance_valid(_tcp_client):
                _tcp_client = _tcp_server.take_connection()
                on_client_connected.emit()
            else:
                push_error("A client is already connected to STH server.")

    # Handle client
    if  is_instance_valid(_tcp_client):
        var available_bytes:int = _tcp_client.get_available_bytes()
        if available_bytes > 0:
            # Knock, knock, who is there ?
            # Using get_partial_data since get_data blocks if there are less available (even if should never happen)
            # result is an array : [result_code(int), data(array)]
            var result:Array = _tcp_client.get_partial_data(available_bytes)
            if result[0] == OK:
                _tcp_client_data_buffer += result[1].get_string_from_ascii()
                _try_do_read_full_data_from_buffer()
            else:
                push_error("Error while retrieving data from client : %s" % error_string(result[0]))
#------------------------------------------
# Fonctions publiques
#------------------------------------------

func start() -> bool:
    _tcp_server = TCPServer.new()
    var error:int = _tcp_server.listen(SERVER_PORT, "127.0.0.1")
    if error != OK:
        push_error("Unable to start STH server : %s" % error_string(error))
        return false
    return true

func send_data_to_client(data:String) -> void:
    if is_instance_valid(_tcp_client):
        _tcp_client.put_data(("%s%s" % [data, STHTCPServer.MESSAGE_DELIMITER]).to_ascii_buffer())

func stop() -> void:
    if is_instance_valid(_tcp_client):
        _tcp_client.disconnect_from_host()
        on_client_disconnected.emit()
    if is_instance_valid(_tcp_server):
        _tcp_server.stop()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _try_do_read_full_data_from_buffer() -> void:
    var index_of_delimiter:int = _tcp_client_data_buffer.find(MESSAGE_DELIMITER)
    while index_of_delimiter != -1:
        var message:String = _tcp_client_data_buffer.substr(0, index_of_delimiter)
        _tcp_client_data_buffer = _tcp_client_data_buffer.substr(index_of_delimiter + MESSAGE_DELIMITER.length())
        index_of_delimiter = _tcp_client_data_buffer.find(MESSAGE_DELIMITER)
        on_client_message_received.emit(message)

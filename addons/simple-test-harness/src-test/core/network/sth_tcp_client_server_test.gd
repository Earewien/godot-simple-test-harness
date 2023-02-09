extends TestCase

var _tcp_server:STHTCPServer
var _tcp_client:STHTCPClient

var _client_connected:bool
var _server_has_client_connected:bool
var _server_received_messages:PackedStringArray
var _client_received_messages:PackedStringArray

#------------------------------------------
# Test setup
#------------------------------------------

# Called before each test
func beforeEach() -> void:
    _tcp_server = load("res://addons/simple-test-harness/src/core/network/sth_tcp_server.tscn").instantiate()
    _tcp_client = load("res://addons/simple-test-harness/src/core/network/sth_tcp_client.tscn").instantiate()
    add_child(_tcp_server)
    add_child(_tcp_client)

    _tcp_server.on_client_connected.connect(_on_server_client_connection)
    _tcp_server.on_client_message_received.connect(_on_server_client_message_received)
    _tcp_server.on_client_disconnected.connect(_on_server_client_dicconnection)

    _tcp_client.on_connection.connect(_on_client_connection)
    _tcp_client.on_message_received.connect(_on_client_message_received)
    _tcp_client.on_disconnection.connect(_on_client_disconnection)

    _server_has_client_connected = false
    _client_connected = false
    _server_received_messages = []
    _client_received_messages = []

# Called after each test
func afterEach() -> void:
    if is_instance_valid(_tcp_client):
        _tcp_client.stop()
        _tcp_client.queue_free()
        _tcp_client = null
    if is_instance_valid(_tcp_server):
        _tcp_server.stop()
        _tcp_server.queue_free()
        _tcp_server = null

#------------------------------------------
# Tests
#------------------------------------------

func test_server_and_client_connection_and_disconnection_signals() -> void:
    _tcp_server.start()
    _tcp_client.start()

    await await_until_client_connected()
    await await_until_server_client_connected()

    _tcp_client.stop()

    await await_until_client_disconnected()
    await await_until_server_client_disconnected()

func test_client_can_reconnect_to_server_multiple_times() -> void:
    _tcp_server.start()

    for i in 5:
        _tcp_client.start()

        await await_until_client_connected()
        _tcp_client.stop()
        await await_until_client_disconnected()
        await await_until_server_client_disconnected()

func test_client_can_send_message_to_server() -> void:
    _tcp_server.start()
    _tcp_client.start()

    await await_until_client_connected()
    _tcp_client.send_data("Hello from client !")

    await await_message_received_by_server("Hello from client !")

func test_server_can_send_message_to_client() -> void:
    _tcp_server.start()
    _tcp_client.start()

    await await_until_client_connected()
    _tcp_server.send_data("Hello from server !")

    await await_message_received_by_client("Hello from server !")

func test_client_can_send_lot_of_messages_to_server_in_right_order() -> void:
    _tcp_server.start()
    _tcp_client.start()

    await await_until_client_connected()

    for i in 100:
        _tcp_client.send_data("Message %s" % i)

    await await_for("100 messages received by server").at_most(5_000).until(func(): return _server_received_messages.size() == 100)
    for i in _server_received_messages.size():
        assert_that_string(_server_received_messages[i]).is_equal_to("Message %s" % i)

#------------------------------------------
# Helpers
#------------------------------------------

func await_until_client_connected() -> void:
    await await_for("Client is connected").at_most(1).until(func():return _client_connected)

func await_until_client_disconnected() -> void:
    await await_for("Client is disconnected").at_most(1).until(func():return not _client_connected)

func await_until_server_client_connected() -> void:
    await await_for("Server has a connected client").at_most(1).until(func():return _server_has_client_connected)

func await_until_server_client_disconnected() -> void:
    await await_for("Server saw client disconnection").at_most(1).until(func():return not _server_has_client_connected)

func await_message_received_by_server(msg:String) -> void:
    await await_for("Server has received a message").at_most(1).until(func():return not _server_received_messages.is_empty())
    assert_that_string(_server_received_messages[-1]).is_equal_to(msg)

func await_message_received_by_client(msg:String) -> void:
    await await_for("Client has received a message").at_most(1).until(func():return not _client_received_messages.is_empty())
    assert_that_string(_client_received_messages[-1]).is_equal_to(msg)


func _on_client_connection() -> void:
    _client_connected = true
func _on_client_message_received(msg:String) -> void:
    _client_received_messages.append(msg)
func _on_client_disconnection() -> void:
    _client_connected = false

func _on_server_client_connection() -> void:
    _server_has_client_connected = true
func _on_server_client_message_received(msg:String) -> void:
    _server_received_messages.append(msg)
func _on_server_client_dicconnection() -> void:
    _server_has_client_connected = false

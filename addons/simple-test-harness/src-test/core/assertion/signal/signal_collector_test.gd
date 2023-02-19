extends TestCase

#------------------------------------------
# Test setup
#------------------------------------------

var _emitter:SignalEmitter

func beforeEach() -> void:
    _emitter = SignalEmitter.new()

func afterEach() -> void:
    if is_instance_valid(_emitter):
        _emitter.queue_free()

#------------------------------------------
# Tests
#------------------------------------------

func test_can_connect_to_one_signal() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    assert_true(collector.collect_signal(_emitter.signal_no_args))

func test_can_connect_to_all_signals() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_all_signals()
    # No error !

func test_when_single_signal_no_args_collected() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_no_args)

    _emitter.signal_no_args.emit()

    assert_true(collector.has_received_signal(_emitter.signal_no_args))
    assert_true(collector.has_received_signal_with_args(_emitter.signal_no_args, []))

func test_when_single_signal_1_arg_collected() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit("a")

    assert_true(collector.has_received_signal(_emitter.signal_1_arg))
    assert_true(collector.has_received_signal_with_args(_emitter.signal_1_arg, ["a"]))

func test_when_single_signal_2_args_collected() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_2_arg)

    _emitter.signal_2_arg.emit("a", 4)

    assert_true(collector.has_received_signal(_emitter.signal_2_arg))
    assert_true(collector.has_received_signal_with_args(_emitter.signal_2_arg, ["a", 4]))

func test_when_single_signal_collected_emitted_multiple_times() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit("b")
    _emitter.signal_1_arg.emit("c")

    assert_true(collector.has_received_signal_with_args(_emitter.signal_1_arg, ["a"]))
    assert_true(collector.has_received_signal_with_args(_emitter.signal_1_arg, ["b"]))
    assert_true(collector.has_received_signal_with_args(_emitter.signal_1_arg, ["c"]))

func test_when_single_signal_collected_emitted_multiple_times_in_exact_order() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit("c")
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit("b")

    assert_true(collector.has_received_signal_with_args_in_exact_order(_emitter.signal_1_arg, [["c"], ["a"], ["b"]]))

func test_when_single_signal_collected_emitted_multiple_times_in_exact_order_bad_sequence() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit("c")
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit("b")

    assert_false(collector.has_received_signal_with_args_in_exact_order(_emitter.signal_1_arg, [["c"], ["b"], ["a"]]))


func test_when_single_signal_collected_emitted_multiple_times_in_exact_order_more_invocation() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit("z")
    _emitter.signal_1_arg.emit("y")
    _emitter.signal_1_arg.emit("c")
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit("b")
    _emitter.signal_1_arg.emit("x")

    assert_true(collector.has_received_signal_with_args_in_exact_order(_emitter.signal_1_arg, [["c"], ["a"], ["b"]]))

func test_when_single_signal_collected_emitted_multiple_times_in_exact_order_more_invocation_bad_sequence() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit("z")
    _emitter.signal_1_arg.emit("y")
    _emitter.signal_1_arg.emit("c")
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit("b")
    _emitter.signal_1_arg.emit("x")

    assert_false(collector.has_received_signal_with_args_in_exact_order(_emitter.signal_1_arg, [["c"], ["b"], ["a"]]))

func test_collect_all_signals() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_all_signals()

    _emitter.signal_no_args.emit()
    _emitter.signal_5_arg.emit(1, 2, 3, 4, 5)

    assert_true(collector.has_received_signal_with_args(_emitter.signal_no_args, []))
    assert_true(collector.has_received_signal_with_args(_emitter.signal_5_arg, [1, 2, 3, 4, 5]))

func test_collect_all_signals_builtin_signals() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_all_signals()

    add_child(_emitter)
    await get_tree().process_frame

    remove_child(_emitter)
    await get_tree().process_frame

    assert_true(collector.has_received_signal(_emitter.tree_entered))
    assert_true(collector.has_received_signal(_emitter.tree_exiting))
    assert_true(collector.has_received_signal(_emitter.tree_exited))

func test_signal_not_collected_if_emitted_before() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    _emitter.signal_no_args.emit()

    collector.collect_all_signals()

    assert_false(collector.has_received_signal(_emitter.signal_no_args))

func test_is_collecting() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    assert_false(collector.is_collecting(_emitter.signal_1_arg))

    collector.collect_signal(_emitter.signal_1_arg)
    assert_true(collector.is_collecting(_emitter.signal_1_arg))

    collector.collect_all_signals()
    assert_true(collector.is_collecting(_emitter.tree_entered))

func test_is_collecting_all_signals_for() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)
    assert_false(collector.is_collecting_all_signals_for(_emitter))

    collector.collect_all_signals()
    assert_true(collector.is_collecting_all_signals_for(_emitter))

func test_emitted_signal_arguments() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit(null)

    assert_equals([[3], ["a"], [null]], collector.get_emitted_signal_arguments(_emitter.signal_1_arg))

func test_has_received_signal_with_args_multiple_times() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit(2)

    assert_true(collector.has_received_signal_with_args(_emitter.signal_1_arg, [3]))

func test_has_received_signal_with_args_exactly() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit(2)

    assert_true(collector.has_received_signal_with_args_exactly(_emitter.signal_1_arg, [3], 2))
    assert_false(collector.has_received_signal_with_args_exactly(_emitter.signal_1_arg, [3], 1))
    assert_false(collector.has_received_signal_with_args_exactly(_emitter.signal_1_arg, [3], 3))

func test_has_received_signal_exactly() -> void:
    var collector:SignalCollector = SignalCollector.new(_emitter)
    collector.collect_signal(_emitter.signal_1_arg)

    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit("a")
    _emitter.signal_1_arg.emit(3)
    _emitter.signal_1_arg.emit(2)

    assert_true(collector.has_received_signal_exactly(_emitter.signal_1_arg, 4))
    assert_false(collector.has_received_signal_exactly(_emitter.signal_1_arg, 1))
    assert_false(collector.has_received_signal_exactly(_emitter.signal_1_arg, 5))

#------------------------------------------
# Helpers
#------------------------------------------

class SignalEmitter extends Node:
    signal signal_no_args
    signal signal_1_arg(a1)
    signal signal_2_arg(a1, a2)
    signal signal_3_arg(a1, a2, a3)
    signal signal_4_arg(a1, a2, a3, a4)
    signal signal_5_arg(a1, a2, a3, a4, a5)

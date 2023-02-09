extends TestCase


var _assertion_reporter:AssertionReporter
var _condition:bool

#------------------------------------------
# Test setup
#------------------------------------------

# Called before each test
func beforeEach() -> void:
    _assertion_reporter = AssertionReporter.new("any")
    _condition = false

#------------------------------------------
# Tests
#------------------------------------------

# UNTIL

func test_error_if_await_until_not_used() -> void:
    _local_await_for().until(func():return true)
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_with_immediate_condition() -> void:
    await _local_await_for().until(func():return true)
    assert_false(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_with_timed_condition() -> void:
    get_tree().create_timer(0.2).timeout.connect(func(): _condition = true)
    await _local_await_for().until(func(): return _condition)
    assert_false(_assertion_reporter.has_failures())

func test_at_most_until() -> void:
    get_tree().create_timer(0.2).timeout.connect(func(): _condition = true)
    await _local_await_for().at_most(1).until(func(): return _condition)
    assert_false(_assertion_reporter.has_failures())
    _condition = false

    get_tree().create_timer(0.5).timeout.connect(func(): _condition = true)
    await _local_await_for().at_most(0.4).until(func(): return _condition)
    assert_true(_assertion_reporter.has_failures())

func test_at_least_until() -> void:
    get_tree().create_timer(0.5).timeout.connect(func(): _condition = true)
    await _local_await_for().at_least(0.2).until(func(): return _condition)
    assert_false(_assertion_reporter.has_failures())
    _condition = false

    get_tree().create_timer(0.1).timeout.connect(func(): _condition = true)
    await _local_await_for().at_least(0.2).until(func(): return _condition)
    assert_true(_assertion_reporter.has_failures())

func test_at_least_and_at_most_until() -> void:
    get_tree().create_timer(0.5).timeout.connect(func(): _condition = true)
    await _local_await_for().at_least(0.2).at_most(0.6).until(func(): return _condition)
    assert_false(_assertion_reporter.has_failures())

func test_reuse_await_until() -> void:
    var await_for:AwaitFor = _local_await_for()

    get_tree().create_timer(0.1).timeout.connect(func(): _condition = true)
    await await_for.until(func(): return _condition)
    assert_false(_assertion_reporter.has_failures())
    _condition = false

    get_tree().create_timer(0.1).timeout.connect(func(): _condition = true)
    await await_for.at_most(0.05).until(func(): return _condition)
    assert_true(_assertion_reporter.has_failures())
    _condition = false
    _assertion_reporter.reset()

    get_tree().create_timer(0.1).timeout.connect(func(): _condition = true)
    await await_for.at_most(0.2).until(func(): return _condition)
    assert_false(_assertion_reporter.has_failures())

# UNTIL_SIGNAL

func test_error_if_await_until_signal_not_used() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    _local_await_for().until_signal_emitted(emitter.signal_no_args)
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_no_args() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_no_args.emit())
    await _local_await_for().until_signal_emitted(emitter.signal_no_args)
    assert_false(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_1_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_1_arg.emit("1"))
    await _local_await_for().until_signal_emitted(emitter.signal_1_arg)
    assert_false(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_2_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_2_arg.emit("1", "2"))
    await _local_await_for().until_signal_emitted(emitter.signal_2_arg)
    assert_false(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_3_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_3_arg.emit("1", "2", "3"))
    await _local_await_for().until_signal_emitted(emitter.signal_3_arg)
    assert_false(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_4_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_4_arg.emit("1", "2", "3", "4"))
    await _local_await_for().until_signal_emitted(emitter.signal_4_arg)
    assert_false(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_5_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_5_arg.emit("1", "2", "3", "4", "5"))
    await _local_await_for().until_signal_emitted(emitter.signal_5_arg)
    assert_false(_assertion_reporter.has_failures())

func test_error_if_too_much_arguments() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()
    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_5_arg.emit("1", "2", "3", "4", "a"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_5_arg, ["1", "2", "3", "4", "5", "6"])
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_with_arg_comparison_1_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_1_arg.emit("1"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_1_arg, ["1"])
    assert_false(_assertion_reporter.has_failures())

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_1_arg.emit("a"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_1_arg, ["1"])
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_with_arg_comparison_2_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_2_arg.emit("1", "2"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_2_arg, ["1", "2"])
    assert_false(_assertion_reporter.has_failures())

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_2_arg.emit("1", "a"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_2_arg, ["1", "2"])
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_with_arg_comparison_3_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_3_arg.emit("1", "2", "3"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_3_arg, ["1", "2", "3"])
    assert_false(_assertion_reporter.has_failures())

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_3_arg.emit("1", "2", "a"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_3_arg, ["1", "2", "3"])
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_with_arg_comparison_4_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_4_arg.emit("1", "2", "3", "4"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_4_arg, ["1", "2", "3", "4"])
    assert_false(_assertion_reporter.has_failures())

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_4_arg.emit("1", "2", "3", "a"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_4_arg, ["1", "2", "3", "4"])
    assert_true(_assertion_reporter.has_failures())

func test_default_at_most_and_at_least_until_signal_with_arg_comparison_5_arg() -> void:
    var emitter:SignalEmitter = SignalEmitter.new()

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_5_arg.emit("1", "2", "3", "4", "5"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_5_arg, ["1", "2", "3", "4", "5"])
    assert_false(_assertion_reporter.has_failures())

    get_tree().create_timer(0.1).timeout.connect(func(): emitter.signal_5_arg.emit("1", "2", "3", "4", "a"))
    await _local_await_for().until_signal_emitted_with_args(emitter.signal_5_arg, ["1", "2", "3", "4", "5"])
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Helpers
#------------------------------------------

func _local_await_for() -> AwaitFor:
    return AwaitFor.new(_assertion_reporter, "")

class SignalEmitter :
    signal signal_no_args
    signal signal_1_arg(a1)
    signal signal_2_arg(a1, a2)
    signal signal_3_arg(a1, a2, a3)
    signal signal_4_arg(a1, a2, a3, a4)
    signal signal_5_arg(a1, a2, a3, a4, a5)

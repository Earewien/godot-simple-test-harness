extends TestCase

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

var _assertion_reporter:AssertionReporter
var _emitter:SignalEmitter

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func beforeEach() -> void:
    _assertion_reporter = AssertionReporter.new("any")
    _emitter = SignalEmitter.new()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func test_assert_that_signal_failed_if_not_collected() -> void:
    _local_assert_that_signal(_emitter.signal_no_args).has_never_been_emitted()
    assert_true(_assertion_reporter.has_failures())

func test_signal_never_emitted_no_arg() -> void:
    collect_signal(_emitter.signal_no_args)
    _local_assert_that_signal(_emitter.signal_no_args).has_never_been_emitted()
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_no_args.emit()
    _local_assert_that_signal(_emitter.signal_no_args).has_never_been_emitted()
    assert_true(_assertion_reporter.has_failures())

func test_signal_emitted_once_no_arg() -> void:
    collect_signal(_emitter.signal_no_args)
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted_only_once()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _emitter.signal_no_args.emit()
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted_only_once()
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_no_args.emit()
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted_only_once()
    assert_true(_assertion_reporter.has_failures())

func test_signal_emitted_no_arg() -> void:
    collect_signal(_emitter.signal_no_args)
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted(0)
    assert_false(_assertion_reporter.has_failures())
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _emitter.signal_no_args.emit()
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted(1)
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_no_args.emit()
    _emitter.signal_no_args.emit()
    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted(3)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_signal(_emitter.signal_no_args).has_been_emitted(4)
    assert_true(_assertion_reporter.has_failures())

func test_has_never_been_emitted_with_args() -> void:
    collect_signal(_emitter.signal_1_arg)
    _local_assert_that_signal(_emitter.signal_1_arg).has_never_been_emitted_with_args([1])
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_1_arg.emit(1)
    _local_assert_that_signal(_emitter.signal_1_arg).has_never_been_emitted_with_args([1])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _local_assert_that_signal(_emitter.signal_1_arg).has_never_been_emitted_with_args([2])
    assert_false(_assertion_reporter.has_failures())

func test_has_been_emitted_only_once_with_args() -> void:
    collect_signal(_emitter.signal_1_arg)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_only_once_with_args([1])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _emitter.signal_1_arg.emit(1)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_only_once_with_args([1])
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_1_arg.emit(1)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_only_once_with_args([1])
    assert_true(_assertion_reporter.has_failures())

func test_has_been_emitted_with_args() -> void:
    collect_signal(_emitter.signal_1_arg)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args(0, [1])
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_1_arg.emit(1)
    _emitter.signal_1_arg.emit(1)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args(2, [1])
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args(1, [1])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _emitter.signal_1_arg.emit(2)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args(1, [2])
    assert_false(_assertion_reporter.has_failures())

func test_has_been_emitted_with_args_in_exact_order() -> void:
    collect_signal(_emitter.signal_1_arg)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args_in_exact_order([[1], [2], [3]])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _emitter.signal_1_arg.emit(0)
    _emitter.signal_1_arg.emit(1)
    _emitter.signal_1_arg.emit(2)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args_in_exact_order([[1], [2], [3]])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

    _emitter.signal_1_arg.emit(3)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args_in_exact_order([[1], [2], [3]])
    assert_false(_assertion_reporter.has_failures())

    _emitter.signal_1_arg.emit(4)
    _local_assert_that_signal(_emitter.signal_1_arg).has_been_emitted_with_args_in_exact_order([[1], [2], [3]])
    assert_false(_assertion_reporter.has_failures())


#------------------------------------------
# Fonctions privées
#------------------------------------------

func _local_assert_that_signal(sig:Signal) -> AssertThatSignal:
    return AssertThatSignal.new(sig, _signal_collectors, _assertion_reporter)

class SignalEmitter extends RefCounted:
    signal signal_no_args
    signal signal_1_arg(a1)
    signal signal_2_arg(a1, a2)
    signal signal_3_arg(a1, a2, a3)
    signal signal_4_arg(a1, a2, a3, a4)
    signal signal_5_arg(a1, a2, a3, a4, a5)

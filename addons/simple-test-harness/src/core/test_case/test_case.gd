class_name TestCase
extends Node

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

var _reporter:AssertionReporter
var _signal_collectors:Array[SignalCollector] = []

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func beforeAll() -> void:
    pass

static func afterAll() -> void:
    pass

func beforeEach() -> void:
    pass

func afterEach() -> void:
    pass

# COLLECTORS

func collect_signals_of(object:Object) -> void:
    if _get_signal_collector_matching_object(object) == null:
        var signal_collector:SignalCollector = SignalCollector.new(object)
        signal_collector.collect_all_signals()
        _signal_collectors.append(signal_collector)

func collect_signal(sig:Signal) -> void:
    if _get_signal_collector_matching(sig) == null:
        var signal_collector:SignalCollector = SignalCollector.new(sig.get_object())
        signal_collector.collect_signal(sig)
        _signal_collectors.append(signal_collector)

# ASSERT SHORTCUTS
func assert_true(value:bool) -> void:
    assert_that(value).is_true()

func assert_false(value:bool) -> void:
    assert_that(value).is_false()

func assert_null(value:Variant) -> void:
    assert_that(value).is_null()

func assert_not_null(value:Variant) -> void:
    assert_that(value).is_not_null()

func assert_equals(expected:Variant, value:Variant) -> void:
    assert_that(value).is_equal_to(expected)

func assert_not_equals(expected:Variant, value:Variant) -> void:
    assert_that(value).is_not_equal_to(expected)

# ALL ASSERT
func assert_that(value:Variant) -> AssertThat:
    return AssertThat.new(value, _reporter)

func assert_that_signal(sig:Signal) -> AssertThatSignal:
    return AssertThatSignal.new(sig, _signal_collectors, _reporter)

func assert_that_int(value:int) -> AssertThatInt:
    return AssertThatInt.new(value, _reporter)

# To test null values, we need to stuck to Variant and not String, as String can not be null !
func assert_that_string(value:Variant) -> AssertThatString:
    return AssertThatString.new(value, _reporter)

# AWAIT
func await_for(description:String = "") -> AwaitFor:
    return AwaitFor.new(_reporter, description)

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _set_assertion_reporter(reporter:AssertionReporter) -> void:
    _reporter = reporter

func _finalize() -> void:
    _reporter = null

    for sig_collector in _signal_collectors:
        sig_collector.finalize()
    _signal_collectors.clear()

func _get_signal_collector_matching(sig:Signal) -> SignalCollector:
    for signal_collector in _signal_collectors:
        if signal_collector.is_collecting(sig):
            return signal_collector
    return null

func _get_signal_collector_matching_object(object:Object) -> SignalCollector:
    for signal_collector in _signal_collectors:
        if signal_collector.is_collecting_all_signals_for(object):
            return signal_collector
    return null

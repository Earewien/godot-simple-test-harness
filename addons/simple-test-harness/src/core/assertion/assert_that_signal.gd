class_name AssertThatSignal
extends BaseAssert

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

var _signal_collectors:Array[SignalCollector]

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(sig:Signal, signal_collectors:Array[SignalCollector], reporter:AssertionReporter) -> void:
    super._init(sig, reporter)
    _signal_collectors = signal_collectors

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func has_never_been_emitted() -> AssertThatSignal:
    return has_been_emitted(0)

func has_been_emitted_only_once() -> AssertThatSignal:
    return has_been_emitted(1)

func has_been_emitted(number_of_times:int) -> AssertThatSignal:
    var collector:SignalCollector = _get_matching_signal_collector()
    if collector == null:
        _report_collector_not_found()
    else:
        _do_report( \
            func(): return collector.has_received_signal_exactly(_value, number_of_times), \
            "Signal '%s' has been emitted exactly %s times" % [_value.get_name(), number_of_times], \
            "Expected signal '%s' to be emitted exactly %s times" % [_value.get_name(), number_of_times]
        )
    return self

func has_never_been_emitted_with_args(args:Array) -> AssertThatSignal:
    return has_been_emitted_with_args(0, args)

func has_been_emitted_only_once_with_args(args:Array) -> AssertThatSignal:
    return has_been_emitted_with_args(1, args)

func has_been_emitted_with_args(number_of_times:int, args:Array) -> AssertThatSignal:
    var collector:SignalCollector = _get_matching_signal_collector()
    if collector == null:
        _report_collector_not_found()
    else:
        _do_report( \
            func(): return collector.has_received_signal_with_args_exactly(_value, args, number_of_times), \
            "Signal has been emitted %s times with expected arguments" % number_of_times, \
            "Expected signal '%s' to be emitted %s times with arguments '%s'" % [_value.get_name(), number_of_times, args]
        )
    return self

func has_been_emitted_with_args_in_exact_order(ordered_args:Array[Array]) -> AssertThatSignal:
    var collector:SignalCollector = _get_matching_signal_collector()
    if collector == null:
        _report_collector_not_found()
    else:
        _do_report( \
            func(): return collector.has_received_signal_with_args_in_exact_order(_value, ordered_args), \
            "Signal has been emitted with expected arguments in exact order", \
            "Expected signal '%s' to be emitted with arguments '%s' in this exact order, got '%s'" % [_value.get_name(), ordered_args, ]
        )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _get_matching_signal_collector() -> SignalCollector:
    for signal_collector in _signal_collectors:
        if signal_collector.is_collecting(_value):
            return signal_collector
    return null

func _report_collector_not_found() -> void:
    var report:AssertionReport = AssertionReport.new()
    report.is_success = false
    report.line_number = _get_assertion_line_number()
    report.description = "Signal '%s' is not collected. Cannot check assertion. To use signal assertion, call collect_signal from TestCase" % _value.get_name()
    _reporter.assertion_reports.append(report)

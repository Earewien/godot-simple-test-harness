class_name AwaitFor
extends RefCounted

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
var _description:String

var _at_most_duration_seconds:float = 5 # 5 seconds by default
var _at_least_duration_seconds:float = 0 # 0 seconds by default
var _poll_delay_seconds:float = 0.05

var _current_tested_signal_received:bool = false
var _current_tested_signal_arguments:Array

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(reporter:AssertionReporter, description:String) -> void:
    _reporter = reporter
    _description = description

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func at_least(duration_seconds:float) -> AwaitFor:
    _at_least_duration_seconds = duration_seconds
    return self

func at_most(duration_seconds:float) -> AwaitFor:
    _at_most_duration_seconds = duration_seconds
    return self

func poll_delay(poll_delay_seconds:float) -> AwaitFor:
    _poll_delay_seconds = poll_delay_seconds
    return self

func until(predicate:Callable) -> void:
    # Put failed report into report stack to prevent calling this method without await keyword
    var await_fail_report:AssertionReport = _get_initial_await_failed_report()
    _reporter.assertion_reports.append(await_fail_report)

    var start_tick_ms:int = Time.get_ticks_msec()
    var ellapsed_time_ms:float = 0
    var condition_result:bool = false
    while !condition_result and ellapsed_time_ms / 1000.0 < _at_most_duration_seconds:
        await Engine.get_main_loop().create_timer(_poll_delay_seconds).timeout
        ellapsed_time_ms = Time.get_ticks_msec() - start_tick_ms
        condition_result = predicate.call()

    # Test is done (success of failure, but done) ; we remove await failed assertion
    _reporter.assertion_reports.erase(await_fail_report)

    var ellapsed_time_s:float = ellapsed_time_ms / 1000.0
    var success:bool = condition_result and ellapsed_time_s >= _at_least_duration_seconds and ellapsed_time_s <= _at_most_duration_seconds

    # And proceed to real assertion
    var report:AssertionReport = AssertionReport.new()
    report.line_number = _get_assertion_line_number()
    report.is_success = success
    var message_prefix:String = "Condition" if _description.is_empty() else "'%s'" % _description
    if report.is_success:
        report.description = "%s fulfilled in %ss" % [message_prefix, ellapsed_time_s]
    else:
        if _at_least_duration_seconds > 0:
            report.description = "%s not fulfilled in at least %ss and less than %ss" % [message_prefix, _at_least_duration_seconds, _at_most_duration_seconds]
        else:
            report.description = "%s not fulfilled in less than %ss" % [message_prefix, _at_most_duration_seconds]
    _reporter.assertion_reports.append(report)

    _print_assertion_failed_if_needed(report)

func until_signal_emitted(sig:Signal) -> void:
    await _until_signal_emitted(sig, false)

func until_signal_emitted_with_args(sig:Signal, args:Array = []) -> void:
     await _until_signal_emitted(sig, true, args)

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _until_signal_emitted(sig:Signal, check_arguments:bool = false, args:Array = []) -> void:
    # Too much args
    if args.size() > 5:
        _reporter.assertion_reports.append(_get_await_signal_too_much_arguments_failed_report())
        return

    # Put failed report into report stack to prevent calling this method without await keyword
    var await_fail_report:AssertionReport = _get_initial_await_failed_report()
    _reporter.assertion_reports.append(await_fail_report)

    # Reset state
    _current_tested_signal_received = false

    var start_tick_ms:int = Time.get_ticks_msec()
    var ellapsed_time_ms:float = 0

    var signal_collector:SignalCollector = SignalCollector.new(sig.get_object())
    signal_collector.collect_signal(sig)

    while !_current_tested_signal_received and ellapsed_time_ms / 1000.0 < _at_most_duration_seconds:
        await Engine.get_main_loop().create_timer(_poll_delay_seconds).timeout
        ellapsed_time_ms = Time.get_ticks_msec() - start_tick_ms
        if check_arguments:
            _current_tested_signal_received = signal_collector.has_received_signal_with_args(sig, args)
        else:
            _current_tested_signal_received = signal_collector.has_received_signal(sig)

    var success_signal_received:bool = signal_collector.has_received_signal(sig)
    signal_collector.finilize()

    # Test is done (success of failure, but done) ; we remove await failed assertion
    _reporter.assertion_reports.erase(await_fail_report)

    var ellapsed_time_s:float = ellapsed_time_ms / 1000.0
    var report_description:String
    var message_prefix:String = "Signal '%s'" % sig.get_name() if _description.is_empty() else "'%s'" % _description

    # Compute report
    if _current_tested_signal_received:
        if check_arguments:
            report_description = "%s received in %ss with expected arguments" % [message_prefix, ellapsed_time_s]
        else:
            report_description = "%s received in %ss" % [message_prefix, ellapsed_time_s]
    else:
        # Signal not received
        if not success_signal_received:
            if _at_least_duration_seconds > 0:
                report_description = "%s not received in at least %ss and less than %ss" % [message_prefix, _at_least_duration_seconds, _at_most_duration_seconds]
            else:
                report_description = "%s not received in less than %ss" % [message_prefix, _at_most_duration_seconds]
        # Signal received in time, so arguments mismatch !
        else:
            report_description = "%s received but arguments mismatch. Expected '%s', got '%s'" % [message_prefix, args, _current_tested_signal_arguments.slice(0, args.size())]

    var report:AssertionReport = AssertionReport.new()
    report.line_number = _get_assertion_line_number()
    report.is_success = _current_tested_signal_received
    report.description = report_description
    _reporter.assertion_reports.append(report)

    _print_assertion_failed_if_needed(report)

func _get_assertion_line_number() -> int:
    for stack in get_stack():
        if stack["function"] == _reporter.test_method_name:
            return stack["line"]
    return -1

func _get_initial_await_failed_report() -> AssertionReport:
    var await_fail_report:AssertionReport = AssertionReport.new()
    await_fail_report.line_number = _get_assertion_line_number()
    await_fail_report.is_success = false
    await_fail_report.description = "Await utility called without 'await' keyword. Coroutine must be called within 'await'"
    return await_fail_report

func _get_await_signal_too_much_arguments_failed_report() -> AssertionReport:
    var await_fail_report:AssertionReport = AssertionReport.new()
    await_fail_report.line_number = _get_assertion_line_number()
    await_fail_report.is_success = false
    await_fail_report.description = "Await signal emitted with args supports maximum 5 arguments"
    return await_fail_report

func _print_assertion_failed_if_needed(report:AssertionReport) -> void:
    if not report.is_success:
        var at_line_message:String = "" if report.line_number == -1 else " at line %s" % report.line_number
        printerr("ASSERTION FAILED %s: %s" % [at_line_message, report.description])

class_name AssertThat
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

var _value:Variant
var _reporter:AssertionReporter

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(value:Variant, reporter:AssertionReporter) -> void:
    _value = value
    _reporter = reporter

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_true() -> AssertThat:
    _do_report( \
        func(): return _value is bool and _value == true, \
        "Value is true" % _value, \
        "Expected value to be be true, but is false"
    )
    return self

func is_false() -> AssertThat:
    _do_report( \
        func(): return _value is bool and _value == false, \
        "Value is false" % _value, \
        "Expected value to be be false, but is true"
    )
    return self

func is_equal_to(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return _value == expected, \
        "Value is '%s'" % expected, \
        "Expected value to be equal to '%s', got '%s'" % [expected, _value]
    )
    return self

func is_not_equal_to(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return _value != expected, \
        "Value is not '%s'" % expected, \
        "Expected value must not be equal to '%s'" % [expected]
    )
    return self

func is_same_has(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return is_same(_value, expected), \
        "Value is '%s'" % expected, \
        "Expected value to be '%s', got '%s'" % [expected, _value]
    )
    return self

func is_not_same_has(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return not is_same(_value, expected), \
        "Value is not '%s'" % expected, \
        "Expected value to not be '%s'" % [expected, _value]
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _do_report(predicate:Callable, desc_success:String, desc_failure:String = desc_success) -> void:
    var report:TestCaseAssertionReport = TestCaseAssertionReport.new()
    report.is_success = predicate.call()
    report.line_number = _get_assertion_line_number()
    report.description = desc_success if report.is_success else desc_failure
    _reporter.assertion_reports.append(report)

func _get_assertion_line_number() -> int:
    for stack in get_stack():
        if stack["function"] == _reporter.test_method_name:
            return stack["line"]
    return -1

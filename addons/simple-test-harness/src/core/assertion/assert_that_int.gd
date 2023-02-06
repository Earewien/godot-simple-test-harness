class_name AssertThatInt
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

var _assert_that:AssertThat

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(value:int, reporter:AssertionReporter) -> void:
    super._init(value, reporter)
    _assert_that = AssertThat.new(value, reporter)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_zero() -> AssertThatInt:
    _do_report( \
        func(): return _value == 0, \
        "Value is zero", \
        "Expected value to zero, got '%s'" % _value
    )
    return self

func is_not_zero() -> AssertThatInt:
    _do_report( \
        func(): return _value != 0, \
        "Value is not zero", \
        "Expected value to not be zero"
    )
    return self

func is_strictly_negative() -> AssertThatInt:
    _do_report( \
        func(): return _value < 0, \
        "Value is strictly negative", \
        "Expected value to be strictly negative, got '%s'" % _value
    )
    return self

func is_negative_or_zero() -> AssertThatInt:
    _do_report( \
        func(): return _value <= 0, \
        "Value is negative or zero", \
        "Expected value to be negative or zero, got '%s'" % _value
    )
    return self

func is_strictly_positive() -> AssertThatInt:
    _do_report( \
        func(): return _value > 0, \
        "Value is strictly positive", \
        "Expected value to be strictly positive, got '%s'" % _value
    )
    return self

func is_positive_or_zero() -> AssertThatInt:
    _do_report( \
        func(): return _value >= 0, \
        "Value is positive or zero", \
        "Expected value to be positive or zero, got '%s'" % _value
    )
    return self

func is_odd() -> AssertThatInt:
    _do_report( \
        func(): return _value % 2 == 0, \
        "Value is odd", \
        "Expected value to be odd, got '%s'" % _value
    )
    return self

func is_even() -> AssertThatInt:
    _do_report( \
        func(): return _value % 2 != 0, \
        "Value is even", \
        "Expected value to be even, got '%s'" % _value
    )
    return self

func is_equal_to(expected:int) -> AssertThatInt:
    _assert_that.is_equal_to(expected)
    return self

func is_not_equal_to(expected:int) -> AssertThatInt:
    _assert_that.is_not_equal_to(expected)
    return self

func is_strictly_less_than(expected:int) -> AssertThatInt:
    _do_report( \
        func(): return _value < expected, \
        "Value is less than '%s'" % expected, \
        "Expected value to be less than '%s', got '%s'" % [expected, _value]
    )
    return self

func is_less_than_or_equal_to(expected:int) -> AssertThatInt:
    _do_report( \
        func(): return _value <= expected, \
        "Value is less than or equal to '%s'" % expected, \
        "Expected value to be less than or equal to '%s', got '%s'" % [expected, _value]
    )
    return self

func is_strictly_greater_than(expected:int) -> AssertThatInt:
    _do_report( \
        func(): return _value > expected, \
        "Value is greater than '%s'" % expected, \
        "Expected value to be greater than '%s', got '%s'" % [expected, _value]
    )
    return self

func is_greater_than_or_equal_to(expected:int) -> AssertThatInt:
    _do_report( \
        func(): return _value >= expected, \
        "Value is greater than or equal to '%s'" % expected, \
        "Expected value to be greater than or equal to '%s', got '%s'" % [expected, _value]
    )
    return self

func is_in_range_inclusive(start_inclusive:int, end_inclusive:int) -> AssertThatInt:
    _do_report( \
        func(): return _value >= start_inclusive and _value <= end_inclusive, \
        "Value is in range [%s,%s] (inclusive)" % [start_inclusive, end_inclusive], \
        "Expected value to be in range [%s,%s] (inclusive), got '%s'" % [start_inclusive, end_inclusive, _value]
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


class_name AssertThatVector2
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

func _init(value:Variant, reporter:AssertionReporter) -> void:
    super._init(value, reporter)
    _assert_that = AssertThat.new(value, reporter)

    assert(value == null or value is Vector2, "Expected null or Vector2 value in AssertThatVector2")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatVector2:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatVector2:
    _assert_that.is_not_null()
    return self

func is_exactly_equal_to(expected:Vector2) -> AssertThatVector2:
    _assert_that.is_equal_to(expected)
    return self

func is_not_exactly_equal_to(expected:Vector2) -> AssertThatVector2:
    _assert_that.is_not_equal_to(expected)
    return self

func is_approx_equal_to(expected:Vector2, delta:float = 0.000001) -> AssertThatVector2:
    _do_report( \
        func(): return _value != null \
            and abs(_value.x - expected.x) <= delta \
            and abs(_value.y - expected.y) <= delta,
        "Vector2 is approximatively %s (delta : %s)" % [expected, delta], \
        "Expected Vector2 to be approximatively %s (delta: %s), got %s" % [expected, delta,_value]
    )
    return self

func is_not_approx_exactly_equal_to(expected:Vector2, delta:float = 0.000001) -> AssertThatVector2:
    _do_report( \
        func(): return _value != null \
            and (abs(_value.x - expected.x) > delta \
            or abs(_value.y - expected.y) > delta),
        "Vector2 is not approximatively %s (delta : %s)" % [expected, delta], \
        "Expected Vector2 to not be approximatively %s (delta: %s), got %s" % [expected, delta,_value]
    )
    return self

func has_exactly_x(expected:float) -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and _value.x == expected, \
        "Vector2 has x value %s" % expected, \
        "Expected Vector2 to have x value %s, got %s" % [expected, null if _value == null else _value.x]
    )
    return self

func has_approx_x(expected:float, delta:float = 0.000001) -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and _value.x >= expected - delta and _value.x <= expected + delta, \
        "Vector2 has approximative x value %s (delta : %s)" % [expected, delta], \
        "Expected Vector2 to have approximative x value %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.x]
    )
    return self

func has_exactly_y(expected:float) -> AssertThatVector2:
    _do_report( \
        func(): return _value!= null and _value.y == expected, \
        "Vector2 has y value %s" % expected, \
        "Expected Vector2 to have y value %s, got %s" % [expected, null if _value == null else _value.y]
    )
    return self

func has_approx_y(expected:float, delta:float = 0.000001) -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and _value.y >= expected - delta and _value.y <= expected + delta, \
        "Vector2 has approximative y value %s (delta : %s)" % [expected, delta], \
        "Expected Vector2 to have approximative y value %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.y]
    )
    return self

func has_approx_length(expected:float, delta:float = 0.000001) -> AssertThatVector2:
    _do_report( \
        func():
            if _value == null:
                return false
            var length:float = _value.length()
            return length >= expected - delta and length <= expected + delta, \
        "Vector2 length is %s (delta : %s)" % [expected, delta], \
        "Expected Vector2 length to be approximatively %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.length()]
    )
    return self

func has_approx_angle(expected:float, delta:float = 0.000001) -> AssertThatVector2:
    _do_report( \
        func():
            if _value == null:
                return false
            var angle:float = _value.angle()
            return angle >= expected - delta and angle <= expected + delta, \
        "Vector2 angle is %s (delta : %s)" % [expected, delta], \
        "Expected Vector2 angle to be approximatively %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.angle()]
    )
    return self

func is_finite() -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and _value.is_finite(), \
        "Vector2 is finite", \
        "Expected Vector2 to be finite"
    )
    return self

func is_infinite() -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and not _value.is_finite(), \
        "Vector2 is infinite", \
        "Expected Vector2 to be infinite"
    )
    return self

func is_normalized() -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and _value.is_normalized(), \
        "Vector2 is normalized", \
        "Expected Vector2 to be normalized"
    )
    return self

func is_not_normalized() -> AssertThatVector2:
    _do_report( \
        func(): return _value != null and not _value.is_normalized(), \
        "Vector2 is not normalized", \
        "Expected Vector2 to not be normalized"
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


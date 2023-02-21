class_name AssertThatVector3
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

    assert(value == null or value is Vector3, "Expected null or Vector3 value in AssertThatVector3")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatVector3:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatVector3:
    _assert_that.is_not_null()
    return self

func is_exactly_equal_to(expected:Vector3) -> AssertThatVector3:
    _assert_that.is_equal_to(expected)
    return self

func is_not_exactly_equal_to(expected:Vector3) -> AssertThatVector3:
    _assert_that.is_not_equal_to(expected)
    return self

func is_approx_equal_to(expected:Vector3, delta:float = 0.000001) -> AssertThatVector3:
    _do_report( \
        func(): return _value != null \
            and abs(_value.x - expected.x) <= delta \
            and abs(_value.y - expected.y) <= delta \
            and abs(_value.z - expected.z) <= delta,
        "Vector3 is approximatively %s (delta : %s)" % [expected, delta], \
        "Expected Vector3 to be approximatively %s (delta: %s), got %s" % [expected, delta,_value]
    )
    return self

func is_not_approx_exactly_equal_to(expected:Vector3, delta:float = 0.000001) -> AssertThatVector3:
    _do_report( \
        func(): return _value != null \
            and (abs(_value.x - expected.x) > delta \
            or abs(_value.y - expected.y) > delta \
            or abs(_value.z - expected.z) > delta),
        "Vector3 is not approximatively %s (delta : %s)" % [expected, delta], \
        "Expected Vector3 to not be approximatively %s (delta: %s), got %s" % [expected, delta,_value]
    )
    return self

func has_exactly_x(expected:float) -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and _value.x == expected, \
        "Vector3 has x value %s" % expected, \
        "Expected Vector3 to have x value %s, got %s" % [expected, null if _value == null else _value.x]
    )
    return self

func has_approx_x(expected:float, delta:float = 0.000001) -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and _value.x >= expected - delta and _value.x <= expected + delta, \
        "Vector3 has approximative x value %s (delta : %s)" % [expected, delta], \
        "Expected Vector3 to have approximative x value %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.x]
    )
    return self

func has_exactly_y(expected:float) -> AssertThatVector3:
    _do_report( \
        func(): return _value!= null and _value.y == expected, \
        "Vector3 has y value %s" % expected, \
        "Expected Vector3 to have y value %s, got %s" % [expected, null if _value == null else _value.y]
    )
    return self

func has_approx_y(expected:float, delta:float = 0.000001) -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and _value.y >= expected - delta and _value.y <= expected + delta, \
        "Vector3 has approximative y value %s (delta : %s)" % [expected, delta], \
        "Expected Vector3 to have approximative y value %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.y]
    )
    return self

func has_exactly_z(expected:float) -> AssertThatVector3:
    _do_report( \
        func(): return _value!= null and _value.z == expected, \
        "Vector3 has z value %s" % expected, \
        "Expected Vector3 to have z value %s, got %s" % [expected, null if _value == null else _value.z]
    )
    return self

func has_approx_z(expected:float, delta:float = 0.000001) -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and _value.z >= expected - delta and _value.z <= expected + delta, \
        "Vector3 has approximative z value %s (delta : %s)" % [expected, delta], \
        "Expected Vector3 to have approximative z value %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.z]
    )
    return self

func has_approx_length(expected:float, delta:float = 0.000001) -> AssertThatVector3:
    _do_report( \
        func():
            if _value == null:
                return false
            var length:float = _value.length()
            return length >= expected - delta and length <= expected + delta, \
        "Vector3 length is %s (delta : %s)" % [expected, delta], \
        "Expected Vector3 length to be approximatively %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.length()]
    )
    return self

func is_finite() -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and _value.is_finite(), \
        "Vector3 is finite", \
        "Expected Vector3 to be finite"
    )
    return self

func is_infinite() -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and not _value.is_finite(), \
        "Vector3 is infinite", \
        "Expected Vector3 to be infinite"
    )
    return self

func is_normalized() -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and _value.is_normalized(), \
        "Vector3 is normalized", \
        "Expected Vector3 to be normalized"
    )
    return self

func is_not_normalized() -> AssertThatVector3:
    _do_report( \
        func(): return _value != null and not _value.is_normalized(), \
        "Vector3 is not normalized", \
        "Expected Vector3 to not be normalized"
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


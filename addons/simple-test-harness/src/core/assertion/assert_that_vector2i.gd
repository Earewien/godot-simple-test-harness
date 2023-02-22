class_name AssertThatVector2i
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

    assert(value == null or value is Vector2i, "Expected null or Vector2i value in AssertThatVector2i")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatVector2i:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatVector2i:
    _assert_that.is_not_null()
    return self

func is_equal_to(expected:Vector2i) -> AssertThatVector2i:
    _assert_that.is_equal_to(expected)
    return self

func is_not_equal_to(expected:Vector2i) -> AssertThatVector2i:
    _assert_that.is_not_equal_to(expected)
    return self

func has_x(expected:int) -> AssertThatVector2i:
    _do_report( \
        func(): return _value != null and _value.x == expected, \
        "Vector2i has x value %s" % expected, \
        "Expected Vector2i to have x value %s, got %s" % [expected, null if _value == null else _value.x]
    )
    return self

func has_y(expected:int) -> AssertThatVector2i:
    _do_report( \
        func(): return _value!= null and _value.y == expected, \
        "Vector2i has y value %s" % expected, \
        "Expected Vector2i to have y value %s, got %s" % [expected, null if _value == null else _value.y]
    )
    return self

func has_approx_length(expected:float, delta:float = 0.000001) -> AssertThatVector2i:
    _do_report( \
        func():
            if _value == null:
                return false
            var length:float = _value.length()
            return length >= expected - delta and length <= expected + delta, \
        "Vector2i length is %s (delta : %s)" % [expected, delta], \
        "Expected Vector2i length to be approximatively %s (delta: %s), got %s" % [expected, delta, null if _value == null else _value.length()]
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


class_name AssertThatColor
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

    assert(value == null or value is Color, "Expected null or Color value in AssertThatColor")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatColor:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatColor:
    _assert_that.is_not_null()
    return self

func is_equal_to(expected:Color) -> AssertThatColor:
    _assert_that.is_equal_to(expected)
    return self

func is_not_equal_to(expected:Color) -> AssertThatColor:
    _assert_that.is_not_equal_to(expected)
    return self

func has_red(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.r, expected), \
        "Color has red value '%s'" % expected, \
        "Expected color to have red value '%s', got '%s'" % [expected, null if _value == null else _value.r]
    )
    return self

func has_red_int(expected:int) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and _value.r8 == expected, \
        "Color has red value '%s'" % expected, \
        "Expected color to have red value '%s', got '%s'" % [expected, null if _value == null else _value.r8]
    )
    return self

func has_green(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.g, expected), \
        "Color has green value '%s'" % expected, \
        "Expected color to have green value '%s', got '%s'" % [expected, null if _value == null else _value.g]
    )
    return self

func has_green_int(expected:int) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and _value.g8 == expected, \
        "Color has green value '%s'" % expected, \
        "Expected color to have green value '%s', got '%s'" % [expected, null if _value == null else _value.g8]
    )
    return self

func has_blue(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.b, expected), \
        "Color has blue value '%s'" % expected, \
        "Expected color to have blue value '%s', got '%s'" % [expected, null if _value == null else _value.b]
    )
    return self

func has_blue_int(expected:int) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and _value.b8 == expected, \
        "Color has blue value '%s'" % expected, \
        "Expected color to have blue value '%s', got '%s'" % [expected, null if _value == null else _value.b8]
    )
    return self

func has_alpha(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.a, expected), \
        "Color has alpha value '%s'" % expected, \
        "Expected color to have alpha value '%s', got '%s'" % [expected, null if _value == null else _value.a]
    )
    return self

func has_alpha_int(expected:int) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and _value.a8 == expected, \
        "Color has alpha value '%s'" % expected, \
        "Expected color to have alpha value '%s', got '%s'" % [expected, null if _value == null else _value.a8]
    )
    return self

func has_hue(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.h, expected), \
        "Color has hue value '%s'" % expected, \
        "Expected color to have hue value '%s', got '%s'" % [expected, null if _value == null else _value.h]
    )
    return self

func has_saturation(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.s, expected), \
        "Color has saturation value '%s'" % expected, \
        "Expected color to have saturation value '%s', got '%s'" % [expected, null if _value == null else _value.s]
    )
    return self

func has_brightness(expected:float) -> AssertThatColor:
    _do_report( \
        func(): return _value != null and is_equal_approx(_value.v, expected), \
        "Color has brightness value '%s'" % expected, \
        "Expected color to have brightness value '%s', got '%s'" % [expected, null if _value == null else _value.v]
    )
    return self

func is_fully_opaque() -> AssertThatColor:
    _do_report( \
        func(): return _value != null and _value.a == 1, \
        "Color is opaque'", \
        "Expected color to be fully opaque"
    )
    return self

func is_fully_transparent() -> AssertThatColor:
    _do_report( \
        func(): return _value != null and _value.a == 0, \
        "Color is transparent'", \
        "Expected color to be fully transparent"
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


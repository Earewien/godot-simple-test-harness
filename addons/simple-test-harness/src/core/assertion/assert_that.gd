class_name AssertThat
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

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(value:Variant, reporter:AssertionReporter) -> void:
    super._init(value, reporter)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_true() -> AssertThat:
    _do_report( \
        func(): return _value is bool and _value == true, \
        "Value is true", \
        "Expected value to be be true, but is false"
    )
    return self

func is_false() -> AssertThat:
    _do_report( \
        func(): return _value is bool and _value == false, \
        "Value is false", \
        "Expected value to be be false, but is true"
    )
    return self

func is_null() -> AssertThat:
    _do_report( \
        func(): return _value == null, \
        "Value is null", \
        "Expected value to be not null, got null"
    )
    return self

func is_not_null() -> AssertThat:
    _do_report( \
        func(): return _value != null, \
        "Value is not null", \
        "Expected value to be not null, got null"
    )
    return self

func is_equal_to(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return _value == expected, \
        "Value is '%s'" % [expected], \
        "Expected value to be equal to '%s', got '%s'" % [expected, _value]
    )
    return self

func is_not_equal_to(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return _value != expected, \
        "Value is not '%s'" % [expected], \
        "Expected value must not be equal to '%s'" % [expected]
    )
    return self

func is_same_has(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return is_same(_value, expected), \
        "Value is '%s'" % [expected], \
        "Expected value to be '%s', got '%s'" % [expected, _value]
    )
    return self

func is_not_same_has(expected:Variant) -> AssertThat:
    _do_report( \
        func(): return not is_same(_value, expected), \
        "Value is not '%s'" % [expected], \
        "Expected value to not be '%s'" % [expected, _value]
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


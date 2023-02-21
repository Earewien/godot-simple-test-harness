class_name AssertThatDictionary
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

    assert(value == null or value is Dictionary, "Expected null or Color value in AssertThatDictionary")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatDictionary:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatDictionary:
    _assert_that.is_not_null()
    return self

func is_equal_to(expected:Dictionary) -> AssertThatDictionary:
    _assert_that.is_equal_to(expected)
    return self

func is_not_equal_to(expected:Dictionary) -> AssertThatDictionary:
    _assert_that.is_not_equal_to(expected)
    return self

func is_read_only() -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.is_read_only(), \
        "Dictionary is read-only", \
        "Expected dictionary to be read-only"
    )
    return self

func is_empty() -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.is_empty(), \
        "Dictionary is empty", \
        "Expected dictionary to be empty"
    )
    return self

func is_not_empty() -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and not _value.is_empty(), \
        "Dictionary is not empty", \
        "Expected dictionary to not be empty"
    )
    return self

func has_size(expected:int) -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.size() == expected, \
        "Dictionary has %s element(s)" % expected, \
        "Expected dictionary to have %s element(s), got %s" % [expected, 0 if _value == null else _value.size()]
    )
    return self

func has_null_key() -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.has(null), \
        "Dictionary has null key", \
        "Expected dictionary to have null key"
    )
    return self

func has_key(expected:Variant) -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.has(expected), \
        "Dictionary has key '%s'" % [expected], \
        "Expected dictionary to have key '%s'" % [expected]
    )
    return self

func has_all_keys(expected:Array[Variant]) -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.has_all(expected), \
        "Dictionary has keys '%s'" % [expected], \
        "Expected dictionary to have keys '%s'" % [expected]
    )
    return self

func has_value(expected:Variant) -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.values().has(expected), \
        "Dictionary has value '%s'" % [expected], \
        "Expected dictionary to have value '%s'" % [expected]
    )
    return self

func has_association(expected_key:Variant, expected_value:Variant) -> AssertThatDictionary:
    _do_report( \
        func(): return _value != null and _value.has(expected_key) and _value[expected_key] == expected_value, \
        "Dictionary has association '%s' = '%s'" % [expected_key, expected_value], \
        "Expected dictionary to have association '%s' = '%s'" % [expected_key, expected_value]
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


class_name AssertThatString
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

    assert(value == null or value is String, "Expected null or String value in AssertThatString")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatString:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatString:
    _assert_that.is_not_null()
    return self

func is_empty() -> AssertThatString:
    _do_report( \
        func(): return _value != null and _value.is_empty(), \
        "Value is empty", \
        "Expected value to be empty, got '%s'" % _value
    )
    return self

func is_empty_or_null() -> AssertThatString:
    _do_report( \
        func(): return _value == null or _value.is_empty(), \
        "Value is null or empty", \
        "Expected value to be null or empty, got '%s'" % _value
    )
    return self

func is_not_empty() -> AssertThatString:
    _do_report( \
        func(): return _value != null and not _value.is_empty(), \
        "Value is not empty", \
        "Expected value to be not empty"
    )
    return self

func has_length(expected:int) -> AssertThatString:
    _do_report( \
        func(): return _value != null and _value.length() == expected, \
        "Value of length %s" % expected, \
        "Expected value to have length of %s, got '%s'" % [expected, _value]
    )
    return self

func is_equal_to(expected:Variant) -> AssertThatString:
    _assert_that.is_equal_to(expected)
    return self

func is_equal_ignore_case_to(expected:Variant) -> AssertThatString:
    _do_report( \
        func(): return \
        (_value == null and expected == null) \
        or (_value != null and expected != null and _value.to_lower() == expected.to_lower()), \
        "Value is equal to '%s' (ignore case)" % expected, \
        "Expected value to be equal to '%s' (ignore case), got '%s'" % [expected, _value]
    )
    return self

func is_not_equal_to(expected:Variant) -> AssertThatString:
    _assert_that.is_not_equal_to(expected)
    return self

func is_not_equal_ignore_case_to(expected:Variant) -> AssertThatString:
    _do_report( \
        func(): return \
        (_value == null and expected != null) \
        or (_value != null and expected == null) \
        or (_value != null and expected != null and _value.to_lower() != expected.to_lower()), \
        "Value is not equal to '%s' (ignore case)" % expected, \
        "Expected value to not be equal to '%s' (ignore case)" % expected
    )
    return self

func begins_with(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value != null and _value.begins_with(expected), \
        "Value begins with '%s'" % expected, \
        "Expected value to begin with '%s', got '%s'" % [expected, _value]
    )
    return self

func does_not_begin_with(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value == null or not _value.begins_with(expected), \
        "Value does not begin with '%s'" % expected, \
        "Expected value to not begin with '%s'" % expected
    )
    return self

func ends_with(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value != null and _value.ends_with(expected), \
        "Value ends with '%s'" % expected, \
        "Expected value to end with '%s', got '%s'" % [expected, _value]
    )
    return self

func does_not_end_with(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value == null or not _value.ends_with(expected), \
        "Value does not end with '%s'" % expected, \
        "Expected value to not end with '%s'" % expected
    )
    return self

func contains(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value != null and _value.contains(expected), \
        "Value contains '%s'" % expected, \
        "Expected value to contain '%s', got '%s'" % [expected, _value]
    )
    return self

func contains_ignore_case(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value != null and _value.to_lower().contains(expected.to_lower()), \
        "Value contains '%s' (ignore case)" % expected, \
        "Expected value to contain '%s' (ignore case), got '%s'" % [expected, _value]
    )
    return self

func does_not_contain(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value == null or not _value.contains(expected), \
        "Value does not contain '%s'" % expected, \
        "Expected value to not contain '%s'" % expected
    )
    return self

func does_not_contain_ignore_case(expected:String) -> AssertThatString:
    _do_report( \
        func(): return _value == null or not _value.to_lower().contains(expected.to_lower()), \
        "Value does not contain '%s' (ignore case)" % expected, \
        "Expected value to not contain '%s' (ignore case)" % expected
    )
    return self

func matches_regex(pattern:String) -> AssertThatString:
    var regex:RegEx = RegEx.new()
    regex.compile(pattern)
    _do_report( \
        func(): return _value != null and regex.search(_value) != null, \
        "Value matches regex '%s'" % pattern, \
        "Expected value to match regex '%s', got '%s'" % [pattern, _value]
    )
    return self

func does_not_match_regex(pattern:String) -> AssertThatString:
    var regex:RegEx = RegEx.new()
    regex.compile(pattern)
    _do_report( \
        func(): return _value == null or regex.search(_value) == null, \
        "Value does not match regex '%s'" % pattern, \
        "Expected value to not match regex '%s'" % pattern
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------

class_name AssertThatArray
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

    assert(value == null or value is Array, "Expected null or Array value in AssertThatArray")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_null() -> AssertThatArray:
    _assert_that.is_null()
    return self

func is_not_null() -> AssertThatArray:
    _assert_that.is_not_null()
    return self

func is_equal_to(expected:Array) -> AssertThatArray:
    _assert_that.is_equal_to(expected)
    return self

func is_not_equal_to(expected:Array) -> AssertThatArray:
    _assert_that.is_not_equal_to(expected)
    return self

func is_empty() -> AssertThatArray:
    _do_report( \
        func(): return _value != null and _value.is_empty(), \
        "Array is empty", \
        "Expected array to be empty"
    )
    return self

func is_not_empty() -> AssertThatArray:
    _do_report( \
        func(): return _value != null and not _value.is_empty(), \
        "Array is not empty", \
        "Expected array to not be empty"
    )
    return self

func has_size(expected:int) -> AssertThatArray:
    _do_report( \
        func(): return _value != null and _value.size() == expected, \
        "Array has %s element(s)" % expected, \
        "Expected array to have %s element(s), got %s" % [expected, 0 if _value == null else _value.size()]
    )
    return self

func contains(expected:Variant) -> AssertThatArray:
    _do_report( \
        func(): return _value != null and _value.has(expected), \
        "Array contains '%s' element" % [expected], \
        "Expected array to contain element '%s'" % [expected]
    )
    return self

func contains_in_exact_order(expected:Array[Variant]) -> AssertThatArray:
    _do_report( \
        func():
            if _value == null:
                return false
            if expected.is_empty():
                return true
            # Find first index of first expected value in tested array
            # Slice it, and compare it to expected result
            # Repeat until first value of expected array is not found
            var last_search_index:int = 0
            var index_of_first_expected_value:int = _value.find(expected[0], last_search_index)
            while index_of_first_expected_value != -1:
                var sliced_array:Array = _value.slice(index_of_first_expected_value, index_of_first_expected_value + expected.size())
                if expected == sliced_array:
                    return true
                last_search_index = index_of_first_expected_value + 1
                index_of_first_expected_value = _value.find(expected[0], last_search_index)
            # Not found !
            return false
            return _value != null and expected.all(func(e): _value.has(e)), \
        "Array contains elements '%s' in exact order" % [expected], \
        "Expected array to contain elements '%s' in exact order, got '%s'" % [expected, _value]
    )
    return self

func contains_in_any_order(expected:Array[Variant]) -> AssertThatArray:
    _do_report( \
        func(): return _value != null and expected.all(func(e): return _value.has(e)), \
        "Array contains elements '%s' in any order" % [expected], \
        "Expected array to contain elements '%s' in any order, got '%s'" % [expected, _value]
    )
    return self

func all_match(predicate:Callable) -> AssertThatArray:
    _do_report( \
        func(): return _value != null and _value.all(predicate), \
        "Array elements all match given predicate", \
        "Expected array elements to all match given predicate"
    )
    return self

func any_match(predicate:Callable) -> AssertThatArray:
    _do_report( \
        func(): return _value != null and _value.any(predicate), \
        "At least one array element matches given predicate", \
        "Expected at least one array element to match given predicate"
    )
    return self

func none_match(predicate:Callable) -> AssertThatArray:
    _do_report( \
        func(): return _value != null and (_value.is_empty() or _value.all(func(e) : return not predicate.call(e))), \
        "Array elements does not match given predicate", \
        "Expected array elements to not match given predicate"
    )
    return self

#------------------------------------------
# Fonctions privées
#------------------------------------------


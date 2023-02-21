extends TestCase

#------------------------------------------
# Test setup
#------------------------------------------

var _assertion_reporter:AssertionReporter

# Called before each test
func beforeEach() -> void:
    _assertion_reporter = AssertionReporter.new("any")

#------------------------------------------
# Tests
#------------------------------------------

func test_is_null() -> void:
    _local_assert_that_dictionary(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary({}).is_null()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary(Dictionary()).is_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
    _local_assert_that_dictionary({}).is_not_null()
    _local_assert_that_dictionary(Dictionary()).is_not_null()
    _local_assert_that_dictionary({"key" : 1}).is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_equal_to() -> void:
    _local_assert_that_dictionary({}).is_equal_to({})
    _local_assert_that_dictionary({}).is_equal_to(Dictionary())
    _local_assert_that_dictionary({"key" : "value"}).is_equal_to({"key" : "value"})
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).is_equal_to({})
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({"key" : "value"}).is_equal_to({"key" : "value1"})
    assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_to() -> void:
    _local_assert_that_dictionary(null).is_not_equal_to({})
    _local_assert_that_dictionary({}).is_not_equal_to({"key" : "value"})
    _local_assert_that_dictionary({"key" : "value1"}).is_not_equal_to({"key" : "value"})
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary({}).is_not_equal_to({})
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({"key" : "value"}).is_not_equal_to({"key" : "value"})
    assert_true(_assertion_reporter.has_failures())

func test_is_read_only() -> void:
    const ro_dict: = { "key" : "value" }
    _local_assert_that_dictionary(ro_dict).is_read_only()
    assert_false(_assertion_reporter.has_failures())

    var ro_dict2: = { "key" : "value" }
    ro_dict2["key2"] = 2
    ro_dict2.make_read_only()
    _local_assert_that_dictionary(ro_dict2).is_read_only()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary({}).is_read_only()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({"key" : "value"}).is_read_only()
    assert_true(_assertion_reporter.has_failures())

func test_is_empty() -> void:
    _local_assert_that_dictionary({}).is_empty()
    _local_assert_that_dictionary(Dictionary()).is_empty()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).is_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({1 : 2}).is_empty()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_empty() -> void:
    _local_assert_that_dictionary({1 : 2}).is_not_empty()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).is_not_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({}).is_not_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary(Dictionary()).is_not_empty()
    assert_true(_assertion_reporter.has_failures())

func test_has_size() -> void:
    _local_assert_that_dictionary({}).has_size(0)
    _local_assert_that_dictionary({1 : 2}).has_size(1)
    _local_assert_that_dictionary({1 : 2, 3 : 4, 5 : 6}).has_size(3)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).has_size(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({}).has_size(1)
    assert_true(_assertion_reporter.has_failures())

func test_has_null_key() -> void:
    _local_assert_that_dictionary({null : 4}).has_null_key()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).has_null_key()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({}).has_null_key()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({1 : 2}).has_null_key()
    assert_true(_assertion_reporter.has_failures())

func test_has_key() -> void:
    _local_assert_that_dictionary({1 : 2}).has_key(1)
    _local_assert_that_dictionary({null : 4}).has_key(null)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).has_key(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary(null).has_key(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({}).has_key(4)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({5 : 4}).has_key(4)
    assert_true(_assertion_reporter.has_failures())

func test_has_all_keys() -> void:
    _local_assert_that_dictionary({1 : 2}).has_all_keys([1])
    _local_assert_that_dictionary({1 : 2, 3 : 4, 5 : 6}).has_all_keys([5,1,3])
    _local_assert_that_dictionary({1 : 2, "key" : "thing"}).has_all_keys([1, "key"])
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).has_all_keys([])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary(null).has_all_keys([null])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({1 : 2}).has_all_keys([2])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_has_value() -> void:
    _local_assert_that_dictionary({1 : null}).has_value(null)
    _local_assert_that_dictionary({1 : 2}).has_value(2)
    _local_assert_that_dictionary({1 : "val", "key" : "value"}).has_value("value")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).has_value(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({}).has_value(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({1 : 2}).has_value(1)
    assert_true(_assertion_reporter.has_failures())

func test_has_association() -> void:
    _local_assert_that_dictionary({1 : null}).has_association(1, null)
    _local_assert_that_dictionary({1 : 2}).has_association(1, 2)
    _local_assert_that_dictionary({1 : "val", "key" : "value"}).has_association("key", "value")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_dictionary(null).has_association(null, null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({}).has_association(1, 2)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({1 : 2}).has_association(2, 1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_dictionary({1 : "val", "key" : "value"}).has_association("key", "val")
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_dictionary(value) -> AssertThatDictionary:
    return AssertThatDictionary.new(value, _assertion_reporter)

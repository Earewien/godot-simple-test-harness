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
    _local_assert_that_array(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array([]).is_null()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array(Array()).is_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
    _local_assert_that_array([]).is_not_null()
    _local_assert_that_array(Array()).is_not_null()
    _local_assert_that_array([1]).is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_equal_to() -> void:
    _local_assert_that_array([]).is_equal_to([])
    _local_assert_that_array([]).is_equal_to(Array())
    _local_assert_that_array(["a", 1]).is_equal_to(["a", 1])
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).is_equal_to([])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1, 2]).is_equal_to([2, 1])
    assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_to() -> void:
    _local_assert_that_array(null).is_not_equal_to([])
    _local_assert_that_array([]).is_not_equal_to([1, 2])
    _local_assert_that_array(["", "b"]).is_not_equal_to(["b", ""])
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array([]).is_not_equal_to([])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array(["b"]).is_not_equal_to(["b"])
    assert_true(_assertion_reporter.has_failures())

func test_is_empty() -> void:
    _local_assert_that_array([]).is_empty()
    _local_assert_that_array(Array()).is_empty()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).is_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([4, 5]).is_empty()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_empty() -> void:
    _local_assert_that_array([1, 2]).is_not_empty()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).is_not_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([]).is_not_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array(Array()).is_not_empty()
    assert_true(_assertion_reporter.has_failures())

func test_has_size() -> void:
    _local_assert_that_array([]).has_size(0)
    _local_assert_that_array([1]).has_size(1)
    _local_assert_that_array([1, 2, 3]).has_size(3)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).has_size(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([]).has_size(1)
    assert_true(_assertion_reporter.has_failures())

func test_contains() -> void:
    _local_assert_that_array([1]).contains(1)
    _local_assert_that_array([1, 2, 3]).contains(2)
    _local_assert_that_array(["a", 5, Vector3()]).contains(Vector3())
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).contains(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1]).contains(2)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_contains_in_exact_order() -> void:
    _local_assert_that_array([]).contains_in_exact_order([])
    _local_assert_that_array([1, 2, 3]).contains_in_exact_order([])
    _local_assert_that_array([1]).contains_in_exact_order([1])
    _local_assert_that_array([1, 2, 3]).contains_in_exact_order([2, 3])
    _local_assert_that_array(["a", 5, Vector3()]).contains_in_exact_order(["a", 5])
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).contains_in_exact_order([])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([]).contains_in_exact_order([1])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1,2,3,4,5]).contains_in_exact_order([3,2])
    assert_true(_assertion_reporter.has_failures())

func test_contains_in_any_order() -> void:
    _local_assert_that_array([]).contains_in_any_order([])
    _local_assert_that_array([1, 2, 3]).contains_in_any_order([])
    _local_assert_that_array([1]).contains_in_any_order([1])
    _local_assert_that_array([1, 2, 3]).contains_in_any_order([2, 3])
    _local_assert_that_array([1, 2, 3]).contains_in_any_order([3, 2])
    _local_assert_that_array(["a", 5, Vector3()]).contains_in_any_order([Vector3(), "a", 5])
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).contains_in_any_order([])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([]).contains_in_any_order([1])
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1,2,3,4,5]).contains_in_any_order([2,5,6])
    assert_true(_assertion_reporter.has_failures())

func test_all_match() -> void:
    _local_assert_that_array([]).all_match(func(e): return false)
    _local_assert_that_array([2, 4, 6]).all_match(func(e): return e % 2 == 0)
    _local_assert_that_array([2, "a", Vector2(5, 6)]).all_match(func(e): return not str(e).is_empty())
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).all_match(func(e): return false)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1, 2, 3]).all_match(func(e): return e % 2 == 0)
    assert_true(_assertion_reporter.has_failures())

func test_any_match() -> void:
    _local_assert_that_array([2, 4, 6]).any_match(func(e): return e % 2 == 0)
    _local_assert_that_array([2, "", Vector2(5, 6)]).any_match(func(e): return str(e).is_empty())
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array([]).any_match(func(e): return true)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array(null).any_match(func(e): return false)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1, 2, 3]).any_match(func(e): return e % 5 == 0)
    assert_true(_assertion_reporter.has_failures())

func test_none_match() -> void:
    _local_assert_that_array([]).none_match(func(e): return false)
    _local_assert_that_array([]).none_match(func(e): return true)
    _local_assert_that_array([2, 4, 6]).none_match(func(e): return e % 2 == 1)
    _local_assert_that_array([2, "", Vector2(5, 6)]).none_match(func(e): return str(e).length() > 50)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_array(null).none_match(func(e): return false)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1]).none_match(func(e): return true)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_array([1, 2, 3]).none_match(func(e): return e % 2 == 0)
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_array(value) -> AssertThatArray:
    return AssertThatArray.new(value, _assertion_reporter)

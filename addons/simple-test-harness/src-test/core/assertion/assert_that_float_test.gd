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

func test_is_exactly_zero() -> void:
    _local_assert_that_float(0).is_exactly_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(0.001).is_exactly_zero()
    assert_true(_assertion_reporter.has_failures())

func test_is_approx_zero() -> void:
    _local_assert_that_float(0).is_approx_zero()
    _local_assert_that_float(0.1).is_approx_zero(0.1)
    _local_assert_that_float(0.000001).is_approx_zero(0.001)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(0.001).is_approx_zero(0.00001)
    assert_true(_assertion_reporter.has_failures())

func test_is_not_exactly_zero() -> void:
    _local_assert_that_float(0.001).is_not_exactly_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(0).is_not_exactly_zero()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_approx_zero() -> void:
    _local_assert_that_float(0.1).is_not_approx_zero()
    _local_assert_that_float(0.1).is_not_approx_zero(0.01)
    _local_assert_that_float(0.001).is_not_approx_zero(0.0001)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(0).is_not_approx_zero()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(0.001).is_not_approx_zero(0.01)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(1).is_not_approx_zero(5)
    assert_true(_assertion_reporter.has_failures())

func test_is_strictly_negative() -> void:
    _local_assert_that_float(-1.5).is_strictly_negative()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(0.1).is_strictly_negative()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(6.6).is_strictly_negative()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_negative_or_exactly_zero() -> void:
    _local_assert_that_float(-1).is_negative_or_exactly_zero()
    _local_assert_that_float(0).is_negative_or_exactly_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(6).is_negative_or_exactly_zero()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()


func test_is_strictly_positive() -> void:
    _local_assert_that_float(1.6).is_strictly_positive()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(0).is_strictly_positive()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(-3.1).is_strictly_positive()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_positive_or_exactly_zero() -> void:
    _local_assert_that_float(5).is_positive_or_exactly_zero()
    _local_assert_that_float(0).is_positive_or_exactly_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(-3).is_positive_or_exactly_zero()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_equal_to() -> void:
    _local_assert_that_float(1.1).is_equal_to(1.1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(6).is_equal_to(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_not_equal_to() -> void:
    _local_assert_that_float(5).is_not_equal_to(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(1.7).is_not_equal_to(1.7)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_approx_equal_to() -> void:
    _local_assert_that_float(1.1).is_approx_equal_to(1.1)
    _local_assert_that_float(1.1).is_approx_equal_to(1.2, 0.1)
    _local_assert_that_float(1.111111).is_approx_equal_to(1.111, 0.001)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(6.1).is_approx_equal_to(6, 0.01)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_not_approx_equal_to() -> void:
    _local_assert_that_float(5).is_not_approx_equal_to(1)
    _local_assert_that_float(5.1).is_not_approx_equal_to(5.05, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(1.7).is_not_approx_equal_to(1.7)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(1.75).is_not_approx_equal_to(1.7, 0.1)
    assert_true(_assertion_reporter.has_failures())

func test_is_strictly_less_than() -> void:
    _local_assert_that_float(1).is_strictly_less_than(2)
    _local_assert_that_float(-7).is_strictly_less_than(-5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(9).is_strictly_less_than(5)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(1).is_strictly_less_than(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_less_than_or_equal_to() -> void:
    _local_assert_that_float(1).is_less_than_or_equal_to(2)
    _local_assert_that_float(-7).is_less_than_or_equal_to(-5)
    _local_assert_that_float(5).is_less_than_or_equal_to(5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(7).is_less_than_or_equal_to(5)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_strictly_greater_than() -> void:
    _local_assert_that_float(2).is_strictly_greater_than(1)
    _local_assert_that_float(-3).is_strictly_greater_than(-5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(5).is_strictly_greater_than(9)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_float(1).is_strictly_greater_than(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_greater_than_or_equal_to() -> void:
    _local_assert_that_float(2).is_greater_than_or_equal_to(1)
    _local_assert_that_float(-2).is_greater_than_or_equal_to(-5)
    _local_assert_that_float(5).is_greater_than_or_equal_to(5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(17).is_greater_than_or_equal_to(22)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_in_range_inclusive() -> void:
    _local_assert_that_float(2).is_in_range_inclusive(1.9,2.1)
    _local_assert_that_float(0).is_in_range_inclusive(0, 0)
    _local_assert_that_float(1).is_in_range_inclusive(1, 1)
    _local_assert_that_float(5).is_in_range_inclusive(-7, 7)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_float(20).is_in_range_inclusive(21, 25)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_float(value:float) -> AssertThatFloat:
    return AssertThatFloat.new(value, _assertion_reporter)

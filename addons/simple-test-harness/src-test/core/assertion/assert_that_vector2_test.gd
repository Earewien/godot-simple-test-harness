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
    _local_assert_that_vector2(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(Vector2()).is_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
    _local_assert_that_vector2(Vector2()).is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_exactly_equal_to() -> void:
    _local_assert_that_vector2(Vector2()).is_exactly_equal_to(Vector2())
    _local_assert_that_vector2(Vector2(1, 1)).is_exactly_equal_to(Vector2(1, 1))
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_exactly_equal_to(Vector2())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 2)).is_exactly_equal_to(Vector2(2, 1))
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1.0001, 2)).is_exactly_equal_to(Vector2(1.0002, 2))
    assert_true(_assertion_reporter.has_failures())

func test_is_not_exactly_equal_to() -> void:
    _local_assert_that_vector2(Vector2()).is_not_exactly_equal_to(Vector2(0.001, 0))
    _local_assert_that_vector2(Vector2(1, 1)).is_not_exactly_equal_to(Vector2(1.0001, 1))
    _local_assert_that_vector2(null).is_not_exactly_equal_to(Vector2())
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(Vector2()).is_not_exactly_equal_to(Vector2())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 2)).is_not_exactly_equal_to(Vector2(1, 2))
    assert_true(_assertion_reporter.has_failures())

func test_is_approx_equal_to() -> void:
    _local_assert_that_vector2(Vector2()).is_approx_equal_to(Vector2(0.001, 0), 0.01)
    _local_assert_that_vector2(Vector2(1, 1)).is_approx_equal_to(Vector2(1.0001, 1), 0.001)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_approx_equal_to(Vector2())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(0.99, 0)).is_approx_equal_to(Vector2(0.98, 0), 0.001)
    assert_true(_assertion_reporter.has_failures())

func test_is_not_approx_exactly_equal_to() -> void:
    _local_assert_that_vector2(Vector2()).is_not_approx_exactly_equal_to(Vector2(0.001, 0))
    _local_assert_that_vector2(Vector2(1, 1)).is_not_approx_exactly_equal_to(Vector2(1.0001, 1), 0.0000001)
    _local_assert_that_vector2(Vector2(1, 3)).is_not_approx_exactly_equal_to(Vector2(1, 2))
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_not_approx_exactly_equal_to(Vector2())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1.0001, 1)).is_not_approx_exactly_equal_to(Vector2(1, 1), 0.01)
    assert_true(_assertion_reporter.has_failures())

func test_has_exactly_x() -> void:
    _local_assert_that_vector2(Vector2()).has_exactly_x(0)
    _local_assert_that_vector2(Vector2(1, 2)).has_exactly_x(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).has_exactly_x(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 2)).has_exactly_x(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1.98763849, 2)).has_exactly_x(1.98763848)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_x() -> void:
    _local_assert_that_vector2(Vector2()).has_approx_x(0)
    _local_assert_that_vector2(Vector2(1, 2)).has_approx_x(1)
    _local_assert_that_vector2(Vector2(1, 2)).has_approx_x(1.001, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).has_approx_x(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 2)).has_approx_x(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1.98763849, 2)).has_approx_x(1.98763849, 0.00000001)
    assert_true(_assertion_reporter.has_failures())

func test_has_exactly_y() -> void:
    _local_assert_that_vector2(Vector2()).has_exactly_y(0)
    _local_assert_that_vector2(Vector2(2, 1)).has_exactly_y(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).has_exactly_y(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(2, 1)).has_exactly_y(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(2, 1.98763849)).has_exactly_y(1.98763848)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_y() -> void:
    _local_assert_that_vector2(Vector2()).has_approx_y(0)
    _local_assert_that_vector2(Vector2(2, 1)).has_approx_y(1)
    _local_assert_that_vector2(Vector2(2, 1)).has_approx_y(1.001, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).has_approx_y(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(2, 1)).has_approx_y(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(2, 1.98763849)).has_approx_y(1.98763849, 0.00000001)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_length() -> void:
    _local_assert_that_vector2(Vector2()).has_approx_length(0)
    _local_assert_that_vector2(Vector2(5, 19).normalized()).has_approx_length(1)
    _local_assert_that_vector2(Vector2(1.1, 7)).has_approx_length(7.08, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).has_approx_length(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 1).normalized()).has_approx_length(1.1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 1.1)).has_approx_length(1.486, 0.00001)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_has_approx_angle() -> void:
    _local_assert_that_vector2(Vector2()).has_approx_angle(0)
    _local_assert_that_vector2(Vector2(1, 0)).has_approx_angle(0)
    _local_assert_that_vector2(Vector2(1, 1)).has_approx_angle(PI/4)
    _local_assert_that_vector2(Vector2(-1, 0)).has_approx_angle(PI)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).has_approx_angle(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 0)).has_approx_angle(PI/2)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 0)).has_approx_angle(PI/2 - 0.01, 0.001)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_finite() -> void:
    _local_assert_that_vector2(Vector2()).is_finite()
    _local_assert_that_vector2(Vector2(5, 1)).is_finite()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_finite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(INF, 7)).is_finite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(7, INF)).is_finite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(INF, INF)).is_finite()
    assert_true(_assertion_reporter.has_failures())

func test_is_infinite() -> void:
    _local_assert_that_vector2(Vector2(INF, 7)).is_infinite()
    _local_assert_that_vector2(Vector2(7, INF)).is_infinite()
    _local_assert_that_vector2(Vector2(INF, INF)).is_infinite()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_infinite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(6, 7)).is_infinite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2()).is_infinite()
    assert_true(_assertion_reporter.has_failures())

func test_is_normalized() -> void:
    _local_assert_that_vector2(Vector2(0.6, 8.1).normalized()).is_normalized()
    _local_assert_that_vector2(Vector2(1, 5).normalized()).is_normalized()
    _local_assert_that_vector2(Vector2(1, 1).normalized()).is_normalized()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(6, 7)).is_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 1)).is_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(INF, INF)).is_normalized()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_normalized() -> void:
    _local_assert_that_vector2(Vector2(0.6, 8.1)).is_not_normalized()
    _local_assert_that_vector2(Vector2(1, 5)).is_not_normalized()
    _local_assert_that_vector2(Vector2(1, 1)).is_not_normalized()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector2(null).is_not_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(6, 7).normalized()).is_not_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector2(Vector2(1, 1).normalized()).is_not_normalized()
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_vector2(value) -> AssertThatVector2:
    return AssertThatVector2.new(value, _assertion_reporter)

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
    _local_assert_that_vector3(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(Vector3()).is_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
    _local_assert_that_vector3(Vector3()).is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_exactly_equal_to() -> void:
    _local_assert_that_vector3(Vector3()).is_exactly_equal_to(Vector3())
    _local_assert_that_vector3(Vector3(1, 1, 1)).is_exactly_equal_to(Vector3(1, 1, 1))
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_exactly_equal_to(Vector3())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 2, 3)).is_exactly_equal_to(Vector3(2, 1, 3))
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1.0001, 2, 1)).is_exactly_equal_to(Vector3(1.0002, 2, 1))
    assert_true(_assertion_reporter.has_failures())

func test_is_not_exactly_equal_to() -> void:
    _local_assert_that_vector3(Vector3()).is_not_exactly_equal_to(Vector3(0.001, 0, 0))
    _local_assert_that_vector3(Vector3(1, 1, 1)).is_not_exactly_equal_to(Vector3(1.0001, 1, 1))
    _local_assert_that_vector3(null).is_not_exactly_equal_to(Vector3())
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(Vector3()).is_not_exactly_equal_to(Vector3())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 2, 3)).is_not_exactly_equal_to(Vector3(1, 2, 3))
    assert_true(_assertion_reporter.has_failures())

func test_is_approx_equal_to() -> void:
    _local_assert_that_vector3(Vector3()).is_approx_equal_to(Vector3(0.001, 0, 0), 0.01)
    _local_assert_that_vector3(Vector3(1, 1, 1)).is_approx_equal_to(Vector3(1.0001, 1, 1), 0.001)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_approx_equal_to(Vector3())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(0.99, 0, 0)).is_approx_equal_to(Vector3(0.98, 0, 0), 0.001)
    assert_true(_assertion_reporter.has_failures())

func test_is_not_approx_exactly_equal_to() -> void:
    _local_assert_that_vector3(Vector3()).is_not_approx_exactly_equal_to(Vector3(0.001, 0, 0))
    _local_assert_that_vector3(Vector3(1, 1, 1)).is_not_approx_exactly_equal_to(Vector3(1.0001, 1, 1), 0.0000001)
    _local_assert_that_vector3(Vector3(1, 3, 2)).is_not_approx_exactly_equal_to(Vector3(1, 2, 3))
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_not_approx_exactly_equal_to(Vector3())
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1.0001, 1, 1)).is_not_approx_exactly_equal_to(Vector3(1, 1, 1), 0.01)
    assert_true(_assertion_reporter.has_failures())

func test_has_exactly_x() -> void:
    _local_assert_that_vector3(Vector3()).has_exactly_x(0)
    _local_assert_that_vector3(Vector3(1, 2, 3)).has_exactly_x(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_exactly_x(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 2, 3)).has_exactly_x(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1.98763849, 2, 3)).has_exactly_x(1.98763848)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_x() -> void:
    _local_assert_that_vector3(Vector3()).has_approx_x(0)
    _local_assert_that_vector3(Vector3(1, 2, 3)).has_approx_x(1)
    _local_assert_that_vector3(Vector3(1, 2, 3)).has_approx_x(1.001, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_approx_x(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 2, 3)).has_approx_x(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1.98763849, 2, 3)).has_approx_x(1.98763849, 0.00000001)
    assert_true(_assertion_reporter.has_failures())

func test_has_exactly_y() -> void:
    _local_assert_that_vector3(Vector3()).has_exactly_y(0)
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_exactly_y(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_exactly_y(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_exactly_y(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 1.98763849, 3)).has_exactly_y(1.98763848)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_y() -> void:
    _local_assert_that_vector3(Vector3()).has_approx_y(0)
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_approx_y(1)
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_approx_y(1.001, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_approx_y(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_approx_y(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 1.98763849, 3)).has_approx_y(1.98763849, 0.00000001)
    assert_true(_assertion_reporter.has_failures())

func test_has_exactly_z() -> void:
    _local_assert_that_vector3(Vector3()).has_exactly_z(0)
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_exactly_z(3)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_exactly_z(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_exactly_z(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 3, 1.98763849)).has_exactly_z(1.98763848)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_z() -> void:
    _local_assert_that_vector3(Vector3()).has_approx_z(0)
    _local_assert_that_vector3(Vector3(2, 1, 3)).has_approx_z(3)
    _local_assert_that_vector3(Vector3(2, 3, 1)).has_approx_z(1.001, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_approx_z(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 3, 1)).has_approx_z(3)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(2, 3, 1.98763849)).has_approx_z(1.98763849, 0.00000001)
    assert_true(_assertion_reporter.has_failures())

func test_has_approx_length() -> void:
    _local_assert_that_vector3(Vector3()).has_approx_length(0)
    _local_assert_that_vector3(Vector3(5, 19, 0).normalized()).has_approx_length(1)
    _local_assert_that_vector3(Vector3(1.1, 7, 0)).has_approx_length(7.08, 0.01)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).has_approx_length(0)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 1, 1).normalized()).has_approx_length(1.1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 1.1, 1)).has_approx_length(1.486, 0.00001)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_finite() -> void:
    _local_assert_that_vector3(Vector3()).is_finite()
    _local_assert_that_vector3(Vector3(5, 1, 5)).is_finite()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_finite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(INF, 7, 0)).is_finite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(7, INF, 0)).is_finite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(INF, INF, INF)).is_finite()
    assert_true(_assertion_reporter.has_failures())

func test_is_infinite() -> void:
    _local_assert_that_vector3(Vector3(INF, 7, 0)).is_infinite()
    _local_assert_that_vector3(Vector3(7, INF, 0)).is_infinite()
    _local_assert_that_vector3(Vector3(INF, INF, INF)).is_infinite()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_infinite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(6, 7, 1)).is_infinite()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3()).is_infinite()
    assert_true(_assertion_reporter.has_failures())

func test_is_normalized() -> void:
    _local_assert_that_vector3(Vector3(0.6, 8.1, 9.1).normalized()).is_normalized()
    _local_assert_that_vector3(Vector3(1, 5, 9.2).normalized()).is_normalized()
    _local_assert_that_vector3(Vector3(1, 1, 1).normalized()).is_normalized()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(6, 7, 9)).is_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 1, 1)).is_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(INF, INF, INF)).is_normalized()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_normalized() -> void:
    _local_assert_that_vector3(Vector3(0.6, 8.1, 1.2)).is_not_normalized()
    _local_assert_that_vector3(Vector3(1, 5, 3.3)).is_not_normalized()
    _local_assert_that_vector3(Vector3(1, 1, 3.2)).is_not_normalized()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_vector3(null).is_not_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(6, 7, 2).normalized()).is_not_normalized()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_vector3(Vector3(1, 1, 1).normalized()).is_not_normalized()
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_vector3(value) -> AssertThatVector3:
    return AssertThatVector3.new(value, _assertion_reporter)

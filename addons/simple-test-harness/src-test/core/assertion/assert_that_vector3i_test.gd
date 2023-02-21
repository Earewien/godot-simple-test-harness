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
	_local_assert_that_vector3i(null).is_null()
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(Vector3i()).is_null()
	assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
	_local_assert_that_vector3i(Vector3i()).is_not_null()
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(null).is_not_null()
	assert_true(_assertion_reporter.has_failures())

func test_is_equal_to() -> void:
	_local_assert_that_vector3i(Vector3i()).is_equal_to(Vector3i())
	_local_assert_that_vector3i(Vector3i(1, 1, 1)).is_equal_to(Vector3i(1, 1, 1))
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(null).is_equal_to(Vector3i())
	assert_true(_assertion_reporter.has_failures())
	_assertion_reporter.reset()
	_local_assert_that_vector3i(Vector3i(1, 2, 3)).is_equal_to(Vector3i(2, 1, 3))
	assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_to() -> void:
	_local_assert_that_vector3i(Vector3i()).is_not_equal_to(Vector3i(1, 0, 0))
	_local_assert_that_vector3i(Vector3i(1, 1, 1)).is_not_equal_to(Vector3i(2, 1, 1))
	_local_assert_that_vector3i(null).is_not_equal_to(Vector3i())
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(Vector3i()).is_not_equal_to(Vector3i())
	assert_true(_assertion_reporter.has_failures())
	_assertion_reporter.reset()
	_local_assert_that_vector3i(Vector3i(1, 2, 3)).is_not_equal_to(Vector3i(1, 2, 3))
	assert_true(_assertion_reporter.has_failures())

func test_has_x() -> void:
	_local_assert_that_vector3i(Vector3i()).has_x(0)
	_local_assert_that_vector3i(Vector3i(1, 2, 3)).has_x(1)
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(null).has_x(0)
	assert_true(_assertion_reporter.has_failures())
	_assertion_reporter.reset()
	_local_assert_that_vector3i(Vector3i(1, 2, 3)).has_x(3)
	assert_true(_assertion_reporter.has_failures())

func test_has_y() -> void:
	_local_assert_that_vector3i(Vector3i()).has_y(0)
	_local_assert_that_vector3i(Vector3i(2, 1, 3)).has_y(1)
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(null).has_y(0)
	assert_true(_assertion_reporter.has_failures())
	_assertion_reporter.reset()
	_local_assert_that_vector3i(Vector3i(2, 1, 3)).has_y(3)
	assert_true(_assertion_reporter.has_failures())

func test_has_z() -> void:
	_local_assert_that_vector3i(Vector3i()).has_z(0)
	_local_assert_that_vector3i(Vector3i(2, 1, 3)).has_z(3)
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(null).has_z(0)
	assert_true(_assertion_reporter.has_failures())
	_assertion_reporter.reset()
	_local_assert_that_vector3i(Vector3i(2, 1, 3)).has_z(1)
	assert_true(_assertion_reporter.has_failures())

func test_has_approx_length() -> void:
	_local_assert_that_vector3i(Vector3i()).has_approx_length(0)
	_local_assert_that_vector3i(Vector3i(1, 0, 1)).has_approx_length(sqrt(2))
	assert_false(_assertion_reporter.has_failures())

	_local_assert_that_vector3i(null).has_approx_length(0)
	assert_true(_assertion_reporter.has_failures())
	_assertion_reporter.reset()
	_local_assert_that_vector3i(Vector3i(1, 1, 1)).has_approx_length(2)
	assert_true(_assertion_reporter.has_failures())


#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_vector3i(value) -> AssertThatVector3i:
	return AssertThatVector3i.new(value, _assertion_reporter)

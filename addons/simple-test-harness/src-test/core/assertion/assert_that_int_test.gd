extends TestCase

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

var _assertion_reporter:AssertionReporter

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func beforeEach() -> void:
    _assertion_reporter = AssertionReporter.new("any")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func test_is_zero() -> void:
    _local_assert_that_int(0).is_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(1).is_zero()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_zero() -> void:
    _local_assert_that_int(1).is_not_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(0).is_not_zero()
    assert_true(_assertion_reporter.has_failures())

func test_is_strictly_negative() -> void:
    _local_assert_that_int(-1).is_strictly_negative()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(0).is_strictly_negative()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_int(6).is_strictly_negative()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_negative_or_zero() -> void:
    _local_assert_that_int(-1).is_negative_or_zero()
    _local_assert_that_int(0).is_negative_or_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(6).is_negative_or_zero()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()


func test_is_strictly_positive() -> void:
    _local_assert_that_int(1).is_strictly_positive()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(0).is_strictly_positive()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_int(-3).is_strictly_positive()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_positive_or_zero() -> void:
    _local_assert_that_int(5).is_positive_or_zero()
    _local_assert_that_int(0).is_positive_or_zero()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(-3).is_positive_or_zero()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_odd() -> void:
    _local_assert_that_int(2).is_odd()
    _local_assert_that_int(4).is_odd()
    _local_assert_that_int(-4).is_odd()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(-3).is_odd()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_even() -> void:
    _local_assert_that_int(1).is_even()
    _local_assert_that_int(3).is_even()
    _local_assert_that_int(-1).is_even()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(6).is_even()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_equal_to() -> void:
    _local_assert_that_int(1).is_equal_to(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(6).is_equal_to(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_not_equal_to() -> void:
    _local_assert_that_int(5).is_not_equal_to(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(1).is_not_equal_to(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_strictly_less_than() -> void:
    _local_assert_that_int(1).is_strictly_less_than(2)
    _local_assert_that_int(-7).is_strictly_less_than(-5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(9).is_strictly_less_than(5)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_int(1).is_strictly_less_than(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_less_than_or_equal_to() -> void:
    _local_assert_that_int(1).is_less_than_or_equal_to(2)
    _local_assert_that_int(-7).is_less_than_or_equal_to(-5)
    _local_assert_that_int(5).is_less_than_or_equal_to(5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(7).is_less_than_or_equal_to(5)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_strictly_greater_than() -> void:
    _local_assert_that_int(2).is_strictly_greater_than(1)
    _local_assert_that_int(-3).is_strictly_greater_than(-5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(5).is_strictly_greater_than(9)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_int(1).is_strictly_greater_than(1)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_greater_than_or_equal_to() -> void:
    _local_assert_that_int(2).is_greater_than_or_equal_to(1)
    _local_assert_that_int(-2).is_greater_than_or_equal_to(-5)
    _local_assert_that_int(5).is_greater_than_or_equal_to(5)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(17).is_greater_than_or_equal_to(22)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_in_range_inclusive() -> void:
    _local_assert_that_int(2).is_in_range_inclusive(1,3)
    _local_assert_that_int(0).is_in_range_inclusive(0, 0)
    _local_assert_that_int(1).is_in_range_inclusive(1, 1)
    _local_assert_that_int(5).is_in_range_inclusive(-7, 7)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_int(20).is_in_range_inclusive(21, 25)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _local_assert_that_int(value:int) -> AssertThatInt:
    return AssertThatInt.new(value, _assertion_reporter)

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

func test_is_true() -> void:
    _local_assert_that(true).is_true()
    assert_false(_assertion_reporter.has_failures())

    _assertion_reporter.reset()
    _local_assert_that(false).is_true()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that("").is_true()
    assert_true(_assertion_reporter.has_failures())

func test_is_false() -> void:
    _local_assert_that(false).is_false()
    assert_false(_assertion_reporter.has_failures())

    _assertion_reporter.reset()
    _local_assert_that(true).is_false()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that("").is_false()
    assert_true(_assertion_reporter.has_failures())

func test_is_null() -> void:
    _local_assert_that(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _assertion_reporter.reset()
    _local_assert_that("").is_null()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that(1).is_null()
    assert_true(_assertion_reporter.has_failures())
    _local_assert_that(Vector2()).is_null()
    assert_true(_assertion_reporter.has_failures())
    _local_assert_that(_assertion_reporter).is_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
    _local_assert_that("Not Null").is_not_null()
    _local_assert_that(42).is_not_null()
    _local_assert_that(Vector3()).is_not_null()
    _local_assert_that(_assertion_reporter).is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _assertion_reporter.reset()
    _local_assert_that(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_equal_to() -> void:
    _local_assert_that("").is_equal_to("")
    _local_assert_that(true).is_equal_to(true)
    _local_assert_that(Vector2(50, 60)).is_equal_to(Vector2(50, 60))
    assert_false(_assertion_reporter.has_failures())

    _assertion_reporter.reset()
    _local_assert_that(null).is_equal_to("null")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that(5).is_equal_to(6)
    assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_to() -> void:
    _local_assert_that(null).is_not_equal_to("null")
    _local_assert_that(Vector2()).is_not_equal_to(Vector2(1, 1))
    _local_assert_that("Hi").is_not_equal_to("hi")
    assert_false(_assertion_reporter.has_failures())

    _assertion_reporter.reset()
    _local_assert_that(null).is_not_equal_to(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that(5).is_not_equal_to(5)
    assert_true(_assertion_reporter.has_failures())

func test_is_same_as() -> void:
    _local_assert_that(null).is_same_has(null)
    _local_assert_that(Vector2.ZERO).is_same_has(Vector2.ZERO)
    assert_false(_assertion_reporter.has_failures())

    var temp_file_1:TempFile = TempFile.new("a")
    var temp_file_2:TempFile = TempFile.new("a")
    _assertion_reporter.reset()
    _local_assert_that(temp_file_1).is_same_has(temp_file_2)
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _local_assert_that(value:Variant) -> AssertThat:
    return AssertThat.new(value, _assertion_reporter)

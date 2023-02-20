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
    _local_assert_that_color(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.RED).is_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_null() -> void:
    _local_assert_that_color(Color.BLACK).is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_equal_to() -> void:
    _local_assert_that_color(Color.RED).is_equal_to(Color.RED)
    _local_assert_that_color(Color.BLUE).is_equal_to(Color(0,0,1,1))
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(null).is_equal_to(Color.GREEN)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_color(Color.PURPLE).is_equal_to(Color.GREEN)
    assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_to() -> void:
    _local_assert_that_color(Color.RED).is_not_equal_to(Color.GREEN)
    _local_assert_that_color(null).is_not_equal_to(Color(0,0,1,1))
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.BLACK).is_not_equal_to(Color.BLACK)
    assert_true(_assertion_reporter.has_failures())

func test_has_red_and_red_int() -> void:
    _local_assert_that_color(Color.RED).has_red(0.999999)
    _local_assert_that_color(Color.RED).has_red(1)
    _local_assert_that_color(Color.RED).has_red_int(255)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.RED).has_red(0.9)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_color(Color.RED).has_red_int(254)
    assert_true(_assertion_reporter.has_failures())

func test_has_green_and_red_green() -> void:
    _local_assert_that_color(Color.GREEN).has_green(0.999999)
    _local_assert_that_color(Color.GREEN).has_green(1)
    _local_assert_that_color(Color.GREEN).has_green_int(255)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.GREEN).has_green(0.9)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_color(Color.GREEN).has_green_int(254)
    assert_true(_assertion_reporter.has_failures())

func test_has_blue_and_blue_green() -> void:
    _local_assert_that_color(Color.BLUE).has_blue(0.999999)
    _local_assert_that_color(Color.BLUE).has_blue(1)
    _local_assert_that_color(Color.BLUE).has_blue_int(255)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.BLUE).has_blue(0.9)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_color(Color.BLUE).has_blue_int(254)
    assert_true(_assertion_reporter.has_failures())

func test_has_alpha_and_alpha_green() -> void:
    _local_assert_that_color(Color.BLUE).has_alpha(0.999999)
    _local_assert_that_color(Color.BLUE).has_alpha(1)
    _local_assert_that_color(Color.BLUE).has_alpha_int(255)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.BLUE).has_alpha(0.9)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_color(Color.BLUE).has_alpha_int(254)
    assert_true(_assertion_reporter.has_failures())

func test_has_hue() -> void:
    _local_assert_that_color(Color.BLUE).has_hue(0.66666)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.BLUE).has_hue(0.55)
    assert_true(_assertion_reporter.has_failures())

func test_has_saturation() -> void:
    _local_assert_that_color(Color.BLUE).has_saturation(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.BLUE).has_saturation(0.55)
    assert_true(_assertion_reporter.has_failures())

func test_has_brightness() -> void:
    _local_assert_that_color(Color.BLUE).has_brightness(1)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color.BLUE).has_brightness(0.55)
    assert_true(_assertion_reporter.has_failures())

func test_is_fully_opaque() -> void:
    _local_assert_that_color(Color.BLUE).is_fully_opaque()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color(0, 1, 0, 0.55)).is_fully_opaque()
    assert_true(_assertion_reporter.has_failures())

func test_is_fully_transparent() -> void:
    _local_assert_that_color(Color(1, 1, 1, 0)).is_fully_transparent()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_color(Color(0, 1, 0, 0.55)).is_fully_transparent()
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Helpers
#------------------------------------------

func _local_assert_that_color(value) -> AssertThatColor:
    return AssertThatColor.new(value, _assertion_reporter)

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

func test_is_null() -> void:
    _local_assert_that_string(null).is_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("").is_null()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()

func test_is_not_null() -> void:
    _local_assert_that_string("aa").is_not_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).is_not_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_empty() -> void:
    _local_assert_that_string("").is_empty()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).is_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_empty()
    assert_true(_assertion_reporter.has_failures())

func test_is_empty_or_null() -> void:
    _local_assert_that_string("").is_empty_or_null()
    _local_assert_that_string(null).is_empty_or_null()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("a").is_empty_or_null()
    assert_true(_assertion_reporter.has_failures())

func test_is_not_empty() -> void:
    _local_assert_that_string("aaa").is_not_empty()
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("").is_not_empty()
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string(null).is_not_empty()
    assert_true(_assertion_reporter.has_failures())

func test_is_has_length() -> void:
    _local_assert_that_string("").has_length(0)
    _local_assert_that_string("aaa").has_length(3)
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).has_length(0)
    assert_true(_assertion_reporter.has_failures())

func test_is_equal_to() -> void:
    _local_assert_that_string(null).is_equal_to(null)
    _local_assert_that_string("").is_equal_to("")
    _local_assert_that_string("azerty").is_equal_to("azerty")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("").is_equal_to(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string(null).is_equal_to("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_equal_to("b")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_equal_to("A")
    assert_true(_assertion_reporter.has_failures())

func test_is_equal_ignore_case_to() -> void:
    _local_assert_that_string(null).is_equal_ignore_case_to(null)
    _local_assert_that_string("").is_equal_ignore_case_to("")
    _local_assert_that_string("azerty").is_equal_ignore_case_to("azerty")
    _local_assert_that_string("A").is_equal_ignore_case_to("a")
    _local_assert_that_string("a").is_equal_ignore_case_to("A")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("").is_equal_ignore_case_to(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string(null).is_equal_ignore_case_to("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_equal_ignore_case_to("b")
    assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_to() -> void:
    _local_assert_that_string(null).is_not_equal_to("")
    _local_assert_that_string("").is_not_equal_to(null)
    _local_assert_that_string("a").is_not_equal_to("A")
    _local_assert_that_string("azerty").is_not_equal_to("qwerty")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).is_not_equal_to(null)
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("").is_not_equal_to("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_not_equal_to("a")
    assert_true(_assertion_reporter.has_failures())

func test_is_not_equal_ignore_case_to() -> void:
    _local_assert_that_string(null).is_not_equal_ignore_case_to("")
    _local_assert_that_string("").is_not_equal_ignore_case_to(null)
    _local_assert_that_string("a").is_not_equal_ignore_case_to("b")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("").is_not_equal_ignore_case_to("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_not_equal_ignore_case_to("A")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("a").is_not_equal_ignore_case_to("a")
    assert_true(_assertion_reporter.has_failures())

func test_begins_with() -> void:
    _local_assert_that_string("").begins_with("")
    _local_assert_that_string("a").begins_with("a")
    _local_assert_that_string("This is a sentence").begins_with("This")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).begins_with("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("AA").begins_with("aa")
    assert_true(_assertion_reporter.has_failures())

func test_does_not_begin_with() -> void:
    _local_assert_that_string("").does_not_begin_with("a")
    _local_assert_that_string(null).does_not_begin_with("a")
    _local_assert_that_string("This is a sentence").does_not_begin_with("That")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("AA").does_not_begin_with("AA")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("").does_not_begin_with("")
    assert_true(_assertion_reporter.has_failures())

func test_ends_with() -> void:
    _local_assert_that_string("").ends_with("")
    _local_assert_that_string("a").ends_with("a")
    _local_assert_that_string("This is a sentence").ends_with("sentence")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).ends_with("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("AA").ends_with("aa")
    assert_true(_assertion_reporter.has_failures())

func test_does_not_end_with() -> void:
    _local_assert_that_string("").does_not_end_with("a")
    _local_assert_that_string(null).does_not_end_with("a")
    _local_assert_that_string("This is a sentence").does_not_end_with("xxx")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("AA").does_not_end_with("AA")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("").does_not_end_with("")
    assert_true(_assertion_reporter.has_failures())

func test_contains() -> void:
    _local_assert_that_string("  ").contains(" ")
    _local_assert_that_string("a a").contains("a")
    _local_assert_that_string("This is a sentence").contains("is")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).contains("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("AA").contains("a")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("This is a sentence").contains("xx")
    assert_true(_assertion_reporter.has_failures())

func test_contains_ignore_case() -> void:
    _local_assert_that_string("  ").contains_ignore_case(" ")
    _local_assert_that_string("a a").contains_ignore_case("a")
    _local_assert_that_string("AA").contains_ignore_case("a")
    _local_assert_that_string("This is a sentence").contains_ignore_case("IS")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).contains_ignore_case("")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("AA").contains_ignore_case("b")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("This is a sentence").contains_ignore_case("xx")
    assert_true(_assertion_reporter.has_failures())

func test_does_not_contain() -> void:
    _local_assert_that_string(null).does_not_contain("")
    _local_assert_that_string("  ").does_not_contain("x")
    _local_assert_that_string("a a").does_not_contain("A")
    _local_assert_that_string("This is a sentence").does_not_contain("tt")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("AA").does_not_contain("A")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("This is a sentence").does_not_contain("a")
    assert_true(_assertion_reporter.has_failures())

func test_does_not_contain_ignore_case() -> void:
    _local_assert_that_string(null).does_not_contain_ignore_case("")
    _local_assert_that_string("  ").does_not_contain_ignore_case(" y")
    _local_assert_that_string("a a").does_not_contain_ignore_case("b")
    _local_assert_that_string("AA").does_not_contain_ignore_case("c")
    _local_assert_that_string("This is a sentence").does_not_contain_ignore_case("truc")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("AA").does_not_contain_ignore_case("a")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("This is a sentence").does_not_contain_ignore_case(" IS")
    assert_true(_assertion_reporter.has_failures())

func test_matches_regex() -> void:
    _local_assert_that_string("").matches_regex("\\s*")
    _local_assert_that_string("123456789").matches_regex("\\d+")
    _local_assert_that_string("I am Groot").matches_regex("[\\w+] [\\w]+ [\\w+]")
    _local_assert_that_string("This is a full sentence !").matches_regex(".*")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string(null).matches_regex("\\s*")
    assert_true(_assertion_reporter.has_failures())
    _assertion_reporter.reset()
    _local_assert_that_string("123456789").matches_regex("[a-z]+")
    assert_true(_assertion_reporter.has_failures())

func test_does_not_match_regex() -> void:
    _local_assert_that_string(null).does_not_match_regex(".*")
    _local_assert_that_string("").does_not_match_regex("\\s+")
    _local_assert_that_string("123456789").does_not_match_regex("[a-z]+")
    _local_assert_that_string("I am Groot").does_not_match_regex("^[a-zA-Z]+$")
    _local_assert_that_string("This is a full sentence !").does_not_match_regex("^\\w{1,6}$")
    assert_false(_assertion_reporter.has_failures())

    _local_assert_that_string("123456789").does_not_match_regex("\\d+")
    assert_true(_assertion_reporter.has_failures())

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _local_assert_that_string(value:Variant) -> AssertThatString:
    return AssertThatString.new(value, _assertion_reporter)

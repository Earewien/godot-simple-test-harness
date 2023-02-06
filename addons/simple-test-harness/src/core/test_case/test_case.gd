class_name TestCase
extends Node

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

var _reporter:AssertionReporter
var _scene_tree:SceneTree

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func beforeAll() -> void:
    pass

static func afterAll() -> void:
    pass

func beforeEach() -> void:
    pass

func afterEach() -> void:
    pass

# ASSERT SHORTCUTS
func assert_true(value:bool) -> void:
    assert_that(value).is_true()

func assert_false(value:bool) -> void:
    assert_that(value).is_false()

func assert_null(value:Variant) -> void:
    assert_that(value).is_null()

func assert_not_null(value:Variant) -> void:
    assert_that(value).is_not_null()

# ALL ASSERT
func assert_that(value:Variant) -> AssertThat:
    return AssertThat.new(value, _reporter)

func assert_that_int(value:int) -> AssertThatInt:
    return AssertThatInt.new(value, _reporter)

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _set_assertion_reporter(reporter:AssertionReporter) -> void:
    _reporter = reporter

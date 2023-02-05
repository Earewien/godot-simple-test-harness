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

func assert_that(value:Variant) -> AssertThat:
    return AssertThat.new(value, _reporter)

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _set_assertion_reporter(reporter:AssertionReporter) -> void:
    _reporter = reporter

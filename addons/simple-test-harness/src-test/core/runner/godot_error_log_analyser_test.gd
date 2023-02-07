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

var _analyzer:GogotErrorLogAnalyzer

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func beforeEach() -> void:
    _analyzer = GogotErrorLogAnalyzer.new()

func test_no_error_with_empty_logs() -> void:
    var logs:PackedStringArray = []
    var descriptor:GodotErrorLogDescriptor = _analyzer.analyze(logs)

    assert_null(descriptor)

func test_no_error_with_simple_logs() -> void:
    var logs:PackedStringArray = [
        "Godot Engine v4.0.beta17.official.c40020513 - https://godotengine.org",
        "",
        "OpenGL Renderer: AMD Radeon(TM) Graphics"
    ]
    var descriptor:GodotErrorLogDescriptor = _analyzer.analyze(logs)

    assert_null(descriptor)

func test_error_descriptor_on_script_error() -> void:
    var logs:PackedStringArray = [
        "Godot Engine v4.0.beta17.official.c40020513 - https://godotengine.org",
        "",
        "OpenGL Renderer: AMD Radeon(TM) Graphics",
        "",
        "SCRIPT ERROR: Invalid operands 'Array' and 'String' in operator '+'.",
        "  at: test_syntax_error (res://addons/simple-test-harness/src-test/sample_test.gd:30)"
    ]
    var descriptor:GodotErrorLogDescriptor = _analyzer.analyze(logs)
    assert_not_null(descriptor)
    assert_equals("Script error: Invalid operands 'Array' and 'String' in operator '+'.", descriptor.error_description)
    assert_equals(30, descriptor.error_line_number)

func test_error_descriptor_on_user_script_error() -> void:
    var logs:PackedStringArray = [
        "Godot Engine v4.0.beta17.official.c40020513 - https://godotengine.org",
        "",
        "OpenGL Renderer: AMD Radeon(TM) Graphics",
        "",
        "USER SCRIPT ERROR: Invalid operands 'Array' and 'String' in operator '+'.",
        "  at: test_syntax_error (res://addons/simple-test-harness/src-test/sample_test.gd:2)"
    ]
    var descriptor:GodotErrorLogDescriptor = _analyzer.analyze(logs)
    assert_not_null(descriptor)
    assert_equals("User script error: Invalid operands 'Array' and 'String' in operator '+'.", descriptor.error_description)
    assert_equals(2, descriptor.error_line_number)

func test_error_descriptor_on_push_error() -> void:
    var logs:PackedStringArray = [
        "ERROR: This message is displayed as this when using 'push_error'",
        "   at: push_error (core/variant/variant_utility.cpp:880)"
    ]
    var descriptor:GodotErrorLogDescriptor = _analyzer.analyze(logs)
    assert_not_null(descriptor)
    assert_equals("push_error: This message is displayed as this when using 'push_error'", descriptor.error_description)
    assert_equals(-1, descriptor.error_line_number)

func test_error_descriptor_on_assert() -> void:
    var logs:PackedStringArray = [
        "SCRIPT ERROR: Assertion failed: this is an assertion description",
        "          at: test_assert (res://addons/simple-test-harness/src-test/core/runner/godot_error_log_analyser_test.gd:66)"
    ]
    var descriptor:GodotErrorLogDescriptor = _analyzer.analyze(logs)
    assert_not_null(descriptor)
    assert_equals("Godot assert failed: this is an assertion description", descriptor.error_description)
    assert_equals(66, descriptor.error_line_number)
#------------------------------------------
# Fonctions privées
#------------------------------------------


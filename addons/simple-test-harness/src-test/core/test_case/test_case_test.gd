extends TestCase

#------------------------------------------
# Test setup
#------------------------------------------

#------------------------------------------
# Tests
#------------------------------------------

# https://github.com/AdrienQuillet/godot-simple-test-harness/issues/15
func test_collect_signal_then_finalize_collectors() -> void:
    var test_case:TestCase = TestCase.new()
    var emitter:SignalEmitter = SignalEmitter.new()

    test_case.collect_signal(emitter.test_signal)

    test_case._finalize()
    test_case.queue_free()
    # No Error !


#------------------------------------------
# Helpers
#------------------------------------------

class SignalEmitter extends RefCounted:
    signal test_signal()

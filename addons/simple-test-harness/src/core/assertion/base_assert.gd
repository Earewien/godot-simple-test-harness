class_name BaseAssert
extends RefCounted

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

var _value:Variant
var _reporter:AssertionReporter

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(value:Variant, reporter:AssertionReporter) -> void:
    _value = value
    _reporter = reporter

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _do_report(predicate:Callable, desc_success:String, desc_failure:String = desc_success) -> void:
    var report:AssertionReport = AssertionReport.new()
    report.is_success = predicate.call()
    report.line_number = _get_assertion_line_number()
    report.description = desc_success if report.is_success else desc_failure
    _reporter.assertion_reports.append(report)

func _get_assertion_line_number() -> int:
    for stack in get_stack():
        if stack["function"] == _reporter.test_method_name:
            return stack["line"]
    return -1

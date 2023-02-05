class_name TestCaseAssertionReport
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

var is_success:bool
var line_number:int = -1
var description:String

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

static func from() -> TestCaseAssertionReport:
    var assertion_report:TestCaseAssertionReport = TestCaseAssertionReport.new()
    return assertion_report

static func deserialize(data:Dictionary) -> TestCaseAssertionReport:
    var assertion_report:TestCaseAssertionReport = TestCaseAssertionReport.new()
    assertion_report.is_success = data["is_success"]
    assertion_report.line_number = data["line_number"]
    assertion_report.description = data["description"]
    return assertion_report

func serialize() -> Dictionary:
    return {
        "is_success" : is_success,
        "line_number" : line_number,
        "description" : description
    }

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


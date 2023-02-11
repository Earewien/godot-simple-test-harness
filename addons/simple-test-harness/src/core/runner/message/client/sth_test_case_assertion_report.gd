class_name STHTestCaseAssertionReport
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

static func deserialize(data:Dictionary) -> STHTestCaseAssertionReport:
    var report:STHTestCaseAssertionReport = STHTestCaseAssertionReport.new()
    report.is_success = data["is_success"]
    report.line_number = data["line_number"]
    report.description = data["description"]
    return report

func serialize() -> Dictionary:
    return {
        "is_success" : is_success,
        "line_number" : line_number,
        "description" : description
    }

func get_type() -> String:
    return "STHTestCaseAssertionReport"

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------


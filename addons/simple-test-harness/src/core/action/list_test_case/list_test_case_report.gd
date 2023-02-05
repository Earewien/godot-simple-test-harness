class_name ListTestCaseReport
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

var test_cases:Array[ParsedGDScript] = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func deserialize(data:Dictionary) -> ListTestCaseReport:
    var report:ListTestCaseReport = ListTestCaseReport.new()
    for stc in data["test_cases"]:
        report.test_cases.append(ParsedGDScript.deserialize(stc))
    return report

func serialize() -> Dictionary:
    return {
        "test_cases" : test_cases.map(func(tc):return tc.serialize())
    }

#------------------------------------------
# Fonctions privées
#------------------------------------------


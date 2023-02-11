class_name TestCaseFinder
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

## Where to look for test cases. Can be directories or file paths. All directories will be scanned recursively
var lookup_paths:PackedStringArray = []

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> Array[STHTestCasePlan]:
    # First find all scripts in lookup paths
    var gdscripts_finder:GDScriptFinder = GDScriptFinder.new()
    gdscripts_finder.lookup_paths = lookup_paths
    var gdscripts:Array[GDScript] = gdscripts_finder.execute()

    # Then, check if scripts correspond to TestCase
    var test_cases:Array[STHTestCasePlan] = []
    for script in gdscripts:
        var parsed_script:ParsedGDScript = ParsedGDScript.new()
        parsed_script.script_parent_class_name_filter = "TestCase"
        parsed_script.parse(script)
        if parsed_script.script_parent_class_name == "TestCase":
            test_cases.append(STHTestCasePlan.from_parsed_script(parsed_script))
    return test_cases

#------------------------------------------
# Fonctions privées
#------------------------------------------


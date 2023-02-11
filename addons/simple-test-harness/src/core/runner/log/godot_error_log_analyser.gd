class_name GogotErrorLogAnalyzer
extends RefCounted

const PATTERN_ASSERTION_ERROR:String = "SCRIPT ERROR: Assertion failed: "
const PATTERN_USER_SCRIPT_ERROR:String = "USER SCRIPT ERROR: "
const PATTERN_SCRIPT_ERROR:String = "SCRIPT ERROR: "
const PATTERN_PUSH_ERROR:String = "ERROR: "

const PATTERNS_AND_DESC:Dictionary = {
    PATTERN_ASSERTION_ERROR : { "desc": "Godot assert failed", "has_line_number": true },
    PATTERN_USER_SCRIPT_ERROR : { "desc": "User script error", "has_line_number": true },
    PATTERN_SCRIPT_ERROR : { "desc": "Script error", "has_line_number": true },
    PATTERN_PUSH_ERROR : { "desc": "push_error", "has_line_number": false }
}

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

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func analyze(log_content:PackedStringArray) -> GodotErrorLogDescriptor:
    for line_n in log_content.size():
        var line:String = log_content[line_n]
        for pattern in PATTERNS_AND_DESC.keys():
            if line.begins_with(pattern):
                var descriptor:GodotErrorLogDescriptor = GodotErrorLogDescriptor.new()
                descriptor.error_description = "%s: %s" % [PATTERNS_AND_DESC[pattern]["desc"], line.substr(pattern.length())]
                if PATTERNS_AND_DESC[pattern]["has_line_number"]:
                    var line_regex:RegEx = RegEx.new()
                    line_regex.compile(".*\\:(\\d+)\\)$")
                    var regex_result:RegExMatch = line_regex.search(log_content[line_n + 1])
                    if regex_result:
                        descriptor.error_line_number = int(regex_result.get_string(1))
                return descriptor
    return null

#------------------------------------------
# Fonctions privées
#------------------------------------------


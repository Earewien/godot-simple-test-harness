class_name ListTestCaseCommand
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

var _base_list_paths:PackedStringArray

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(joinded_paths:String) -> void:
    _base_list_paths = joinded_paths.split(";")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> ListTestCaseReport:
    var report:ListTestCaseReport = ListTestCaseReport.new()
    for path in _base_list_paths:
        _fill_report_with_test_cases(path, report)
    return report

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _fill_report_with_test_cases(path:String, report:ListTestCaseReport) -> void:
    var scripts:Array[GDScript] = _get_test_case_scripts_in_path(path)
    for script in scripts:
        var parsed_script:ParsedGDScript = ParsedGDScript.new()
        parsed_script.script_parent_class_name_filter = "TestCase"
        if parsed_script.parse(script):
            report.test_cases.append(parsed_script)

func _get_test_case_scripts_in_path(path:String) -> Array[GDScript]:
    # Recursive search in directory
    if DirAccess.dir_exists_absolute(path):
        var test_case_scripts:Array[GDScript] = []
        var res_dir:DirAccess = DirAccess.open(path)
        res_dir.list_dir_begin()
        var file_name = res_dir.get_next()
        while file_name != "":
            test_case_scripts.append_array(_get_test_case_scripts_in_path("%s/%s" % [path, file_name]))
            file_name = res_dir.get_next()
        return test_case_scripts
    elif FileAccess.file_exists(path):
        # A file, maybe a GDScript ?
        if path.get_extension() == "gd":
            var loaded_file = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)
            if loaded_file is GDScript:
                return [loaded_file]
        return []
    else:
        # Not a folder, not a file, nothing
        return []


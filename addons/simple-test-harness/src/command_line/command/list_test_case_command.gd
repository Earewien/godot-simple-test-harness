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

var _base_list_directory:String

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(dir:String) -> void:
    _base_list_directory = dir

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> ListTestCaseReport:
    var report:ListTestCaseReport = ListTestCaseReport.new()
    _fill_report_with_test_cases(_base_list_directory, report)
    return report

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _fill_report_with_test_cases(dir:String, report:ListTestCaseReport) -> void:
    var scripts:Array[GDScript] = _get_test_case_scripts_in_dir(dir)
    for script in scripts:
        var parsed_script:ParsedGDScript = ParsedGDScript.new()
        parsed_script.script_parent_class_name_filter = "TestCase"
        if parsed_script.parse(script):
            report.test_cases.append(parsed_script)

func _get_test_case_scripts_in_dir(dir:String) -> Array[GDScript]:
    var test_case_scripts:Array[GDScript] = []
    var res_dir:DirAccess = DirAccess.open(dir)
    res_dir.list_dir_begin()
    var file_name = res_dir.get_next()
    while file_name != "":
        if res_dir.current_is_dir():
            test_case_scripts.append_array(_get_test_case_scripts_in_dir("%s/%s" % [dir, file_name]))
        else:
            if file_name.get_extension() == "gd":
                var file_path:String = "%s/%s" % [dir, file_name]
                var loaded_file = load(file_path)
                if loaded_file is GDScript:
                    test_case_scripts.append(loaded_file)
        file_name = res_dir.get_next()
    return test_case_scripts

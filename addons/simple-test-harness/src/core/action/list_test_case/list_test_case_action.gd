class_name ListTestCaseAction
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

var _headless_runner:HeadlessGodotRunner

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> ListTestCaseReport:
    var output_file:TempFile = TempFile.new("ltc")
    var arguments:PackedStringArray = [
        "--list-testcases",
        ProjectSettings.globalize_path("res://"),
        "--output",
        output_file.get_file_path()
    ]
    _headless_runner = HeadlessGodotRunner.new(arguments)
    _headless_runner.start()
    await _headless_runner.on_process_terminated
    if _headless_runner.get_exit_code() == 0:
        var output_content:String = output_file.get_file_content()
        output_file.delete()
        return ListTestCaseReport.deserialize(str_to_var(output_content))
    else:
        push_error("Fail to list test cases in project.")
        return null

#------------------------------------------
# Fonctions privées
#------------------------------------------


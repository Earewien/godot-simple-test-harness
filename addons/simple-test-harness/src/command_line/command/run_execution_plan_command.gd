class_name RunExecutionPlanCommand
extends Node

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

var _execution_plan:BuildExecutionPlanReport

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(execution_plan_path:String) -> void:
    _execution_plan = BuildExecutionPlanReport.deserialize(str_to_var(FileAccess.get_file_as_string(execution_plan_path)))

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func execute() -> RunExecutionPlanReport:
    var report:RunExecutionPlanReport = RunExecutionPlanReport.new()

    report.execution_date_time = Time.get_datetime_string_from_system(false, true)

    var plan_start_time_ms:int = Time.get_ticks_msec()

    for test_case in _execution_plan.test_case_plan:
        var runner:TestCaseRunner = TestCaseRunner.new(_create_runner_descriptor(test_case))
        var scene_tree:SceneTree = Engine.get_main_loop()
        add_child(runner)
        await Engine.get_main_loop().process_frame
        runner.call_deferred("execute")
        await runner.completed
        var test_case_report:TestCaseReport = runner.test_case_report
        remove_child(runner)
        await Engine.get_main_loop().process_frame
        report.test_case_reports.append(test_case_report)

    var plan_stop_time_ms:int = Time.get_ticks_msec()
    report.execution_time_ms = plan_stop_time_ms - plan_start_time_ms

    return report

func _create_runner_descriptor(test_case:TestCasePlan) -> TestCaseRunnerDescriptor:
    var descriptor:TestCaseRunnerDescriptor = TestCaseRunnerDescriptor.new()
    descriptor.test_case_name = test_case.test_case_name
    descriptor.test_case_path = test_case.test_case_path
    descriptor.test_case_has_default_constructor = test_case.has_default_constructor
    for method_plan in test_case.test_case_methods:
        descriptor.test_case_test_methods.append({
            "name" : method_plan.test_method_name,
            "line_number" : method_plan.test_method_line_number,
            "arg_count" : method_plan.test_method_arguments_count
        })
    return descriptor

#------------------------------------------
# Fonctions privées
#------------------------------------------


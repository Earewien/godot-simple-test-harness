@tool
extends Control

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

@onready var _tree:Tree = $%ReportTree
var _plan_items:Dictionary = {}

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func clear_report() -> void:
    _tree.clear()
    _plan_items.clear()

func initialize_with_build_plan(plan:BuildExecutionPlanReport) -> void:
    var root_item:TreeItem = _tree.create_item(null)
    for test_case in plan.test_case_plan:
        var tc_item:TreeItem = _tree.create_item(root_item)
        tc_item.set_tooltip_text(0, test_case.test_case_path)
        tc_item.set_text(0, test_case.test_case_name)
        _plan_items[test_case.test_case_path] = tc_item
        for test_method in test_case.test_case_methods:
            var tm_item:TreeItem = _tree.create_item(tc_item)
            tm_item.set_text(0, test_method.test_method_name)
            _plan_items[test_case.test_case_path + test_method.test_method_name] = tm_item

func show_execution_report(report:RunExecutionPlanReport) -> void:
    for test_case_report in report.test_case_reports:
        var test_case_item:TreeItem = _plan_items[test_case_report.test_case_path]
        test_case_item.set_text(0, "%s (%sms)" % [test_case_report.test_case_name, test_case_report.execution_time_ms])
        var color:Color
        match test_case_report.get_state():
            TestCaseReport.TEST_CASE_REPORT_STATE_SUCCESS:
                color = Color.FOREST_GREEN
            TestCaseReport.TEST_CASE_REPORT_STATE_SKIPPED:
                color = Color.YELLOW
            TestCaseReport.TEST_CASE_REPORT_STATE_UNSTABLE:
                color = Color.DARK_ORANGE
            TestCaseReport.TEST_CASE_REPORT_STATE_FAILURE:
                color = Color.RED
        test_case_item.set_custom_color(0, color)

        for method_report in test_case_report.method_reports:
            var method_item:TreeItem = _plan_items[test_case_report.test_case_path + method_report.method_name]
            method_item.set_text(0, "%s (%sms)" % [method_report.method_name, method_report.execution_time_ms])
            var method_color:Color
            if method_report.is_successful():
                method_color = Color.FOREST_GREEN
            elif method_report.is_skipped():
                method_color = Color.YELLOW
            elif method_report.is_failed():
                method_color = Color.RED
            method_item.set_custom_color(0, method_color)

            if method_report.is_skipped():
                var desc_item:TreeItem = _tree.create_item(method_item)
                desc_item.set_text(0, method_report.result_description)
                desc_item.set_custom_color(0, method_color)
            else:
                for assert_report in method_report.assertion_reports:
                    var assert_item:TreeItem = _tree.create_item(method_item)
                    assert_item.set_text(0, assert_report.description)
                    assert_item.set_custom_color(0, Color.FOREST_GREEN if assert_report.is_success else Color.RED)

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_clear_button_pressed() -> void:
    clear_report()


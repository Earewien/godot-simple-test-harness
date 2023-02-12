@tool
extends Control

const TAB_NAME:String = "Simple Test Harness"

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
var _tab_container:TabContainer

var _plan_items:Dictionary = {}

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        push_error("Unable to get orchestrator")
        return

    var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
    orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)
    orchestrator.on_runner_message_received.connect(_on_orchestrator_runner_message_received)

func _ready() -> void:
    _tab_container = _get_parent_tab_container()
    if not is_instance_valid(_tab_container):
        push_error("Unable to find parent tab container")
    else:
        # Parent tab container is not yet updated with our tab, so index will be -1. Wait next frame !
        await Engine.get_main_loop().process_frame
        _tab_container.set_tab_icon(_get_current_index_in_tab_container(), IconRegistry.ICON_DOCK)

func _notification(what: int) -> void:
    if  what == NOTIFICATION_PREDELETE:
        _tab_container = null
        if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
            var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
            orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)
            orchestrator.on_runner_message_received.disconnect(_on_orchestrator_runner_message_received)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func clear_report() -> void:
    _tree.clear()
    _plan_items.clear()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _get_parent_tab_container() -> TabContainer:
    var parent_node:Node = get_parent()
    while is_instance_valid(parent_node):
        if parent_node is TabContainer:
            return parent_node
        parent_node = parent_node.get_parent()
    return null

# Tab index can change since user can drag the tab left/right. So we need to request it each time we use it
func _get_current_index_in_tab_container() -> int:
    if is_instance_valid(_tab_container):
        for i in _tab_container.get_tab_count():
            if _tab_container.get_tab_title(i) == TAB_NAME:
                return i
    return -1

# Pop this tab as active tab
func _show_tab() -> void:
    var tab_index:int = _get_current_index_in_tab_container()
    if tab_index != -1:
        _tab_container.current_tab = tab_index

func _on_clear_button_pressed() -> void:
    clear_report()

func _on_orchestrator_state_changed(state:int) -> void:
    match state:
        STHOrchestrator.ORCHESTRATOR_STATE_IDLE:
            pass
        STHOrchestrator.ORCHESTRATOR_STATE_PREPARING_TESTSUITE:
            clear_report()
            _show_tab()
        STHOrchestrator.ORCHESTRATOR_STATE_RUNNING_TESTSUITE:
            pass

func _on_orchestrator_runner_message_received(message) -> void:
    if message is STHTestsuitePlanReady:
        _handle_testsuite_plan(message)
    elif message is STHTestCaseMethodReport:
        _handle_test_case_method_report(message)
    elif message is STHTestCaseFinished:
        _handle_test_case_finished(message)

func _handle_testsuite_plan(plan:STHTestsuitePlanReady) -> void:
    var root_item:TreeItem = _tree.create_item(null)

    for test_case in plan.plan.test_case_plans:
        var tc_item:TreeItem = _tree.create_item(root_item)
        tc_item.set_tooltip_text(0, test_case.test_case_path)
        tc_item.set_text(0, test_case.test_case_name)
        _plan_items[test_case.test_case_path] = tc_item

        for test_method in test_case.test_case_methods:
            var tm_item:TreeItem = _tree.create_item(tc_item)
            tm_item.set_text(0, test_method.test_method_name)
            _plan_items[test_case.test_case_path + test_method.test_method_name] = tm_item

func _handle_test_case_method_report(report:STHTestCaseMethodReport) -> void:
    var success_count:int = 0
    var skip_count:int = 0
    var failed_count:int = 0
    var item:TreeItem = _plan_items[report.test_case_path + report.method_name]
    if item:
        var method_color:Color
        if report.is_successful():
            method_color = Color.FOREST_GREEN
            success_count += 1
        elif report.is_skipped():
            method_color = Color.YELLOW
            skip_count += 1
        elif report.is_failed():
            method_color = Color.RED
            failed_count += 1
        item.set_custom_color(0, method_color)

        if report.is_skipped():
            var desc_item:TreeItem = _tree.create_item(item)
            desc_item.set_text(0, report.result_description)
            desc_item.set_custom_color(0, method_color)
        else:
            for assert_report in report.assertion_reports:
                var assert_item:TreeItem = _tree.create_item(item)
                assert_item.set_text(0, assert_report.description)
                assert_item.set_custom_color(0, Color.FOREST_GREEN if assert_report.is_success else Color.RED)

    if report.is_successful():
        item.set_collapsed_recursive(true)

    _tree.scroll_to_item(item)

func _handle_test_case_finished(message:STHTestCaseFinished) -> void:
    var item:TreeItem = _plan_items[message.test_case_path]

    var color:Color
    match message.test_case_status:
        STHTestCaseFinished.TEST_CASE_STATUS_SUCCESSFUL:
            color = Color.FOREST_GREEN
        STHTestCaseFinished.TEST_CASE_STATUS_SKIPPED:
            color = Color.YELLOW
        STHTestCaseFinished.TEST_CASE_STATUS_UNSTABLE:
            color = Color.DARK_ORANGE
        STHTestCaseFinished.TEST_CASE_STATUS_FAILED:
            color = Color.RED
    item.set_custom_color(0, color)

    if message.test_case_status == STHTestCaseFinished.TEST_CASE_STATUS_SUCCESSFUL:
        item.set_collapsed_recursive(true)

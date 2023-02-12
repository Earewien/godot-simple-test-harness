@tool
class_name STHDockView
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



func _ready() -> void:
    _tree.set_column_title(0, "Test Cases")
    _tree.set_column_title(1, "Time")
    _tree.set_column_clip_content(0, true)
    _tree.set_column_expand(0, true)
    _tree.set_column_expand(1, false)
    _tree.set_column_custom_minimum_width(0, 100)
    _tree.set_column_custom_minimum_width(1, 100)
    get_tree().create_timer(0.1).timeout.connect(_after_ready)

func _notification(what: int) -> void:
    if  what == NOTIFICATION_PREDELETE:
        if is_instance_valid(_tab_container):
            _tab_container = null
            if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
                var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
                orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)
                orchestrator.on_runner_message_received.disconnect(_on_orchestrator_runner_message_received)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

# -------------
# UI Tab Related
# -------------
func _after_ready() -> void:
    _tab_container = _get_parent_tab_container()

    # Has to check : in production it's always ok, but when I develop the addon, if I opened this scene, I'm not in a tab container !
    if is_instance_valid(_tab_container):
        _tab_container.set_tab_icon(_get_current_index_in_tab_container(), IconRegistry.ICON_DOCK)
        if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
            var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
            orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)
            orchestrator.on_runner_message_received.connect(_on_orchestrator_runner_message_received)

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

# -------------
# UI
# -------------

func _on_clear_button_pressed() -> void:
    _clear_report()

# -------------
# Orchestrator
# -------------

func _on_orchestrator_state_changed(state:int) -> void:
    match state:
        STHOrchestrator.ORCHESTRATOR_STATE_IDLE:
            pass
        STHOrchestrator.ORCHESTRATOR_STATE_PREPARING_TESTSUITE:
            _clear_report()
            _show_tab()
        STHOrchestrator.ORCHESTRATOR_STATE_RUNNING_TESTSUITE:
            pass

func _on_orchestrator_runner_message_received(message) -> void:
    if message is STHTestsuitePlanReady:
        _handle_testsuite_plan(message)
    elif message is STHTestCaseStarted:
        _handle_test_case_started(message)
    elif message is STHTestCaseMethodStarted:
        _handle_test_case_method_started(message)
    elif message is STHTestCaseMethodReport:
        _handle_test_case_method_report(message)
    elif message is STHTestCaseFinished:
        _handle_test_case_finished(message)

# -------------
# Logic
# -------------

func _clear_report() -> void:
    _tree.clear()
    for item_key in _plan_items.keys():
        _plan_items[item_key]

# Here, we receive plan from orchestrator. Plan contains test case that are to be run,
# and each test case contains methods that will be run too.
# All are pending !
func _handle_testsuite_plan(plan:STHTestsuitePlanReady) -> void:
    var root_item:TreeItem = _tree.create_item(null)

    for test_case in plan.plan.test_case_plans:
        var tc_item:TreeItem = _tree.create_item(root_item)
        tc_item.set_text(0, test_case.test_case_name)
        tc_item.set_tooltip_text(0, test_case.test_case_path)
        _plan_items[test_case.test_case_path] = tc_item

        for test_method in test_case.test_case_methods:
            var tm_item:TreeItem = _tree.create_item(tc_item)
            tm_item.set_text(0, test_method.test_method_name)
            tm_item.set_tooltip_text(0, test_method.test_method_name)
            _plan_items[test_case.test_case_path + test_method.test_method_name] = tm_item

# Here, a test case is starting. Pass its state to started
func _handle_test_case_started(message:STHTestCaseStarted) -> void:
    var test_case_item:TreeItem = _plan_items[message.test_case_path]

    if test_case_item:
        test_case_item.set_icon(0, IconRegistry.ICON_TEST_IN_PROGRESS)

# Here, a test case method is starting. Pass its state to started
func _handle_test_case_method_started(message:STHTestCaseMethodStarted) -> void:
    var method_item:TreeItem = _plan_items[message.test_case_path + message.test_case_method_name]

    if method_item:
        method_item.set_icon(0, IconRegistry.ICON_TEST_IN_PROGRESS)

# Here, we start receiving test reports. A report is about a method in a test case
# Each report contains assertions reports. We had them as child of method item
func _handle_test_case_method_report(report:STHTestCaseMethodReport) -> void:
    var method_item:TreeItem = _plan_items[report.test_case_path + report.method_name]

    if method_item:
        method_item.set_text(1, str(report.execution_time_ms))
        method_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
        method_item.set_suffix(1, "ms")

        if report.is_successful():
            method_item.set_icon(0, IconRegistry.ICON_TEST_SUCCESS)
        elif report.is_skipped():
            method_item.set_icon(0, IconRegistry.ICON_TEST_SKIPPED)
        elif report.is_failed():
            method_item.set_icon(0, IconRegistry.ICON_TEST_FAILED)

        if report.is_skipped():
            var desc_item:TreeItem = _tree.create_item(method_item)
            desc_item.set_icon(0, IconRegistry.ICON_TEST_SKIPPED)
            desc_item.set_text(0, report.result_description)
        else:
            for assert_report in report.assertion_reports:
                var assert_item:TreeItem = _tree.create_item(method_item)
                assert_item.set_text(0, assert_report.description)
                assert_item.set_tooltip_text(0, assert_report.description)
                if assert_report.is_success:
                    assert_item.set_icon(0, IconRegistry.ICON_TEST_SUCCESS)
                else:
                    assert_item.set_icon(0, IconRegistry.ICON_TEST_FAILED)

    if report.is_successful():
        method_item.set_collapsed_recursive(true)

    _tree.scroll_to_item(method_item)

func _handle_test_case_finished(message:STHTestCaseFinished) -> void:
    var test_case_item:TreeItem = _plan_items[message.test_case_path]

    if test_case_item:
        test_case_item.set_text(1, str(message.test_case_execution_time_ms))
        test_case_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
        test_case_item.set_suffix(1, "ms")

        match message.test_case_status:
            STHTestCaseFinished.TEST_CASE_STATUS_SUCCESSFUL:
                test_case_item.set_icon(0, IconRegistry.ICON_TEST_SUCCESS)
            STHTestCaseFinished.TEST_CASE_STATUS_SKIPPED:
                test_case_item.set_icon(0, IconRegistry.ICON_TEST_SKIPPED)
            STHTestCaseFinished.TEST_CASE_STATUS_UNSTABLE:
                test_case_item.set_icon(0, IconRegistry.ICON_TEST_FAILED)
            STHTestCaseFinished.TEST_CASE_STATUS_FAILED:
                test_case_item.set_icon(0, IconRegistry.ICON_TEST_FAILED)

        if message.test_case_status == STHTestCaseFinished.TEST_CASE_STATUS_SUCCESSFUL:
            test_case_item.set_collapsed_recursive(true)

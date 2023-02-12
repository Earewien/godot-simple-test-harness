@tool
class_name STHDockView
extends Control

const TAB_NAME:String = "Simple Test Harness"
const ITEM_METADATA_NAME:String = "sth_meta"

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

var _plugin:SimpleTestHarnessPlugin

@onready var _tree:Tree = $%ReportTree
@onready var _clear_button:TextureButton = %ClearButton
@onready var _run_all_button:TextureButton = %RunAllButton
@onready var _run_failed_button:TextureButton = %RunFailedButton
@onready var _logs_text_edit:TextEdit = %LogsTextEdit

var _tab_container:TabContainer

var _indexed_tree_items:Dictionary = {}

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META):
        return
    _plugin = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META)

func _ready() -> void:
    _tree.set_column_title(0, "Test Cases")
    _tree.set_column_title(1, "Time")
    _tree.set_column_clip_content(0, true)
    _tree.set_column_expand(0, true)
    _tree.set_column_expand(1, false)
    _tree.set_column_custom_minimum_width(0, 100)
    _tree.set_column_custom_minimum_width(1, 100)
    get_tree().create_timer(0.1).timeout.connect(_after_ready)

    # Init button states
    _run_all_button.disabled = true
    _run_failed_button.disabled = true

    # Init logs state
    _logs_text_edit.visible = false

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

func _on_run_all_button_pressed() -> void:
    _run_all_test_cases()

func _on_run_failed_button_pressed() -> void:
     _run_failed_test_cases()

func _on_expand_button_pressed() -> void:
    if is_instance_valid(_tree.get_root()):
        for child in _tree.get_root().get_children():
            child.set_collapsed_recursive(false)

func _on_collapse_button_pressed() -> void:
    if is_instance_valid(_tree.get_root()):
        for child in _tree.get_root().get_children():
            child.set_collapsed_recursive(true)

func _on_report_tree_nothing_selected() -> void:
    _logs_text_edit.visible = false

func _on_report_tree_item_selected() -> void:
    _update_logs_view(_tree.get_selected())

func _on_report_tree_item_activated() -> void:
    _open_selected_item_related_script()

func _update_logs_view(item:TreeItem) -> void:
    if item.has_meta(ITEM_METADATA_NAME):
        var meta = item.get_meta(ITEM_METADATA_NAME)
        if meta is TestCaseMethodMetadata:
            _logs_text_edit.visible = true
            _logs_text_edit.text = ""
            for line in meta.test_case_method_logs:
                _logs_text_edit.text += line + "\n"
            _logs_text_edit.text = _logs_text_edit.text.strip_edges()
        else:
            _logs_text_edit.visible = false

# -------------
# Orchestrator
# -------------

func _on_orchestrator_state_changed(state:int) -> void:
    match state:
        STHOrchestrator.ORCHESTRATOR_STATE_IDLE:
            _on_orchestrator_idle()
        STHOrchestrator.ORCHESTRATOR_STATE_PREPARING_TESTSUITE:
            _on_orchestrator_preparing_testsuite()
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
    # Explicitly free Tree Items
    for item_key in _indexed_tree_items.keys():
        var item = _indexed_tree_items[item_key]
        if is_instance_valid(item):
            print(item)
            item.free()
    _indexed_tree_items.clear()

    # No items, no run !
    _run_all_button.disabled = true
    _run_failed_button.disabled = true

    # And no logs
    _logs_text_edit.visible = false

func _on_orchestrator_idle() -> void:
    _clear_button.disabled = false
    _run_all_button.disabled = _indexed_tree_items.is_empty()
    _run_failed_button.disabled = _indexed_tree_items.is_empty()

func _on_orchestrator_preparing_testsuite() -> void:
    _clear_report()
    _show_tab()
    _clear_button.disabled = true
    _run_all_button.disabled = true
    _run_failed_button.disabled = true

func _run_all_test_cases() -> void:
    # Collect all test case paths, and ask plugin to run them
    var paths:PackedStringArray = []
    if is_instance_valid(_tree.get_root()):
        for test_case_item in _tree.get_root().get_children():
            paths.append(test_case_item.get_meta(ITEM_METADATA_NAME).test_case_path)
    _plugin.execute_test_cases_from_path(paths, false)

func _run_failed_test_cases() -> void:
    # Collect all test case paths of unsuccessful test cases, and ask plugin to run them
    var paths:PackedStringArray = []
    if is_instance_valid(_tree.get_root()):
        for test_case_item in _tree.get_root().get_children():
            var meta:TestCaseMetadata = test_case_item.get_meta(ITEM_METADATA_NAME)
            if meta.test_case_result != STHTestCaseFinished.TEST_CASE_STATUS_SUCCESSFUL:
                paths.append(meta.test_case_path)
    _plugin.execute_test_cases_from_path(paths, false)

func _open_selected_item_related_script() -> void:
    var selected_item:TreeItem = _tree.get_selected()
    if is_instance_valid(selected_item):
        if selected_item.has_meta(ITEM_METADATA_NAME):
            var meta = selected_item.get_meta(ITEM_METADATA_NAME)
            var script_path:String = meta.test_case_path
            var line_number:int = -1
            if meta is TestCaseMethodMetadata:
                line_number = meta.test_case_method_line_number
            elif meta is TestCaseMethodAssertionMetadata:
                if meta.test_case_method_assertion_line_number != -1:
                    line_number = meta.test_case_method_line_number
                else:
                    line_number = selected_item.get_parent().get_meta(ITEM_METADATA_NAME).test_case_method_line_number

            line_number += 1 # Maybe an index that is different ?
            if FileAccess.file_exists(script_path):
                var script:= ResourceLoader.load(script_path, "", ResourceLoader.CACHE_MODE_REUSE)
                _plugin.get_editor_interface().get_file_system_dock().navigate_to_path(script_path)
                _plugin.get_editor_interface().select_file(script_path)
                _plugin.get_editor_interface().edit_script(script, line_number, 0)
                _plugin.get_editor_interface().set_main_screen_editor("Script")

# Here, we receive plan from orchestrator. Plan contains test case that are to be run,
# and each test case contains methods that will be run too.
# All are pending !
func _handle_testsuite_plan(plan:STHTestsuitePlanReady) -> void:
    var root_item:TreeItem = _tree.create_item(null)

    for test_case in plan.plan.test_case_plans:
        var tc_item:TreeItem = _tree.create_item(root_item)
        tc_item.set_text(0, test_case.test_case_name)
        tc_item.set_tooltip_text(0, test_case.test_case_path)
        var tc_metadata:TestCaseMetadata = TestCaseMetadata.new()
        tc_metadata.test_case_path = test_case.test_case_path
        tc_item.set_meta(ITEM_METADATA_NAME, tc_metadata)
        _indexed_tree_items[test_case.test_case_path] = tc_item

        for test_method in test_case.test_case_methods:
            var tm_item:TreeItem = _tree.create_item(tc_item)
            tm_item.set_text(0, test_method.test_method_name)
            tm_item.set_tooltip_text(0, test_method.test_method_name)
            var m_metadata:TestCaseMethodMetadata = TestCaseMethodMetadata.new()
            m_metadata.test_case_path = test_case.test_case_path
            m_metadata.test_case_method_name = test_method.test_method_name
            m_metadata.test_case_method_line_number = test_method.test_method_line_number
            tm_item.set_meta(ITEM_METADATA_NAME, m_metadata)
            _indexed_tree_items[test_case.test_case_path + test_method.test_method_name] = tm_item

# Here, a test case is starting. Pass its state to started
func _handle_test_case_started(message:STHTestCaseStarted) -> void:
    var test_case_item:TreeItem = _indexed_tree_items[message.test_case_path]

    if test_case_item:
        test_case_item.set_icon(0, IconRegistry.ICON_TEST_IN_PROGRESS)

# Here, a test case method is starting. Pass its state to started
func _handle_test_case_method_started(message:STHTestCaseMethodStarted) -> void:
    var method_item:TreeItem = _indexed_tree_items[message.test_case_path + message.test_case_method_name]

    if method_item:
        method_item.set_icon(0, IconRegistry.ICON_TEST_IN_PROGRESS)

# Here, we start receiving test reports. A report is about a method in a test case
# Each report contains assertions reports. We had them as child of method item
func _handle_test_case_method_report(report:STHTestCaseMethodReport) -> void:
    var method_item:TreeItem = _indexed_tree_items[report.test_case_path + report.method_name]

    if method_item:
        method_item.set_text(1, str(report.execution_time_ms))
        method_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
        method_item.set_suffix(1, "ms")
        method_item.get_meta(ITEM_METADATA_NAME).test_case_method_result = report.result
        method_item.get_meta(ITEM_METADATA_NAME).test_case_method_logs = report.logs

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
                var metadata:TestCaseMethodAssertionMetadata = TestCaseMethodAssertionMetadata.new()
                metadata.test_case_path = report.test_case_path
                metadata.test_case_method_assertion_line_number = assert_report.line_number
                assert_item.set_meta(ITEM_METADATA_NAME, metadata)
                if assert_report.is_success:
                    assert_item.set_icon(0, IconRegistry.ICON_TEST_SUCCESS)
                else:
                    assert_item.set_icon(0, IconRegistry.ICON_TEST_FAILED)

    if report.is_successful():
        if _can_collaspe_item(method_item):
            method_item.set_collapsed_recursive(true)

    # Do not scroll to item if an item is selected : if user is ready something, it's a real pain !
    if _tree.get_selected() == null:
        _tree.scroll_to_item(method_item)

    # If item is selected, refresh logs
    if method_item == _tree.get_selected():
        _update_logs_view(method_item)

func _handle_test_case_finished(message:STHTestCaseFinished) -> void:
    var test_case_item:TreeItem = _indexed_tree_items[message.test_case_path]

    if test_case_item:
        test_case_item.set_text(1, str(message.test_case_execution_time_ms))
        test_case_item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_RIGHT)
        test_case_item.set_suffix(1, "ms")
        test_case_item.get_meta(ITEM_METADATA_NAME).test_case_result = message.test_case_status

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
            if _can_collaspe_item(test_case_item):
                test_case_item.set_collapsed_recursive(true)

func _can_collaspe_item(item:TreeItem) -> bool:
    # Collapse only if user is not selecting something in test case report (test case or any method)
    var can_collapse:bool = true
    var selected_item:TreeItem = _tree.get_selected()
    if is_instance_valid(selected_item):
        var test_case_item:TreeItem
        if not item.has_meta(ITEM_METADATA_NAME):
            # Whattttt
            push_error("Item should have metadata")
        else:
            if item.get_meta(ITEM_METADATA_NAME) is STHTestCaseAssertionReport:
                # Assertion, two step up
                test_case_item = item.get_parent().get_parent()
            if item.get_meta(ITEM_METADATA_NAME) is TestCaseMethodMetadata:
                # Method, one step up
                test_case_item = item.get_parent()
            else:
                # Already test case
                test_case_item = item
        var tmp_item_parent:TreeItem = selected_item
        while is_instance_valid(tmp_item_parent):
            if test_case_item == tmp_item_parent:
                can_collapse = false
                break
            tmp_item_parent = tmp_item_parent.get_parent()
    return can_collapse
# -------------
# Metadata classes
# -------------

class TestCaseMetadata extends RefCounted:
    var test_case_path:String
    var test_case_result:int

class TestCaseMethodMetadata extends RefCounted:
    var test_case_path:String
    var test_case_method_name:String
    var test_case_method_line_number:int
    var test_case_method_result:int
    var test_case_method_logs:PackedStringArray

class TestCaseMethodAssertionMetadata extends RefCounted:
    var test_case_path:String
    var test_case_method_assertion_line_number:int


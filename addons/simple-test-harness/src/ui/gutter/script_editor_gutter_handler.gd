class_name ScriptEditorGutterHandler
extends RefCounted

const GUTTER_NAME:String = "STHGutter"

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

var _cached_script_editors:Dictionary = { }

var _can_run_tests:bool = true

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func initialize() -> void:
    if not Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META):
        return
    _plugin = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ENGINE_META)

    # To disable run actions when testsuite is already running
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.connect(_on_orchestrator_state_changed)

    # When a resource is saved, if its a GDScript currently in edition, gutter must be reload
    if not _plugin.resource_saved.is_connected(_on_resource_saved):
        _plugin.resource_saved.connect(_on_resource_saved)

    # When script editor changed edited file, gutter must be reload
    var script_editor:ScriptEditor = _plugin.get_editor_interface().get_script_editor()
    if not script_editor.editor_script_changed.is_connected(_on_editor_script_changed):
        script_editor.editor_script_changed.connect(_on_editor_script_changed)
    if not script_editor.script_close.is_connected(_on_editor_script_closed):
        script_editor.script_close.connect(_on_editor_script_closed)

func finalize() -> void:
    # To disable run actions when testsuite is already running
    if Engine.has_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META):
        var orchestrator:STHOrchestrator = Engine.get_meta(SimpleTestHarnessPlugin.PLUGIN_ORCHESTRATOR_META)
        orchestrator.on_state_changed.disconnect(_on_orchestrator_state_changed)

    var script_editor:ScriptEditor = _plugin.get_editor_interface().get_script_editor()
    if script_editor.editor_script_changed.is_connected(_on_editor_script_changed):
        script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
    if script_editor.script_close.is_connected(_on_editor_script_closed):
        script_editor.script_close.disconnect(_on_editor_script_closed)

    if _plugin.resource_saved.is_connected(_on_resource_saved):
        _plugin.resource_saved.disconnect(_on_resource_saved)

    for script_path in _cached_script_editors:
        _remove_script_from_cache(script_path)
    _cached_script_editors.clear()

    _plugin = null

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_orchestrator_state_changed(state:int) -> void:
    _can_run_tests = state == STHOrchestrator.ORCHESTRATOR_STATE_IDLE
    # Reload gutters if necessary
    var edited_script = _plugin.get_editor_interface().get_script_editor().get_current_script()
    if edited_script:
        _reload_gutter_for_script(edited_script)

func _on_resource_saved(resource:Resource) -> void:
    if not resource is GDScript:
        return

    var script:GDScript = resource as GDScript

    # Only reload for current editor, when script is changed, another signal callback will handle the new editor
    if _plugin.get_editor_interface().get_script_editor().get_current_script() == script:
        _reload_gutter_for_script(script)

func _on_editor_script_changed(script) -> void:
    if not script is GDScript:
        return

    if script != _plugin.get_editor_interface().get_script_editor().get_current_script():
        return

    if _cached_script_editors.has(script.resource_path) and not _cached_script_editors[script.resource_path]["closing"]:
        # Resource already processed, editor has the gutter, juste continue
        pass
    else:
        # After closing a script, the script_changed signal can be triggere on clising script.
        # Prevent from doing anything with a closing script !
        if _cached_script_editors.has(script.resource_path) and _cached_script_editors[script.resource_path]["closing"]:
            _cached_script_editors.erase(script.resource_path)
        else:
            var script_editor:ScriptEditorBase = _plugin.get_editor_interface().get_script_editor().get_current_editor()
            var editor_gutter_clicked_callable:Callable = _on_gutter_clicked.bind(script)
            if not script_editor.get_base_editor().gutter_clicked.is_connected(_on_gutter_clicked):
                script_editor.get_base_editor().gutter_clicked.connect(editor_gutter_clicked_callable)

            var sth_gutter_id:int = _get_script_editor_sth_gutter_id(script_editor)
            _cached_script_editors[script.resource_path] = {
                "editor" : script_editor,
                "gutter_id" : sth_gutter_id,
                "editor_gutter_click_callable" : editor_gutter_clicked_callable,
                "closing" : false,
                "gutters" : { }
            }

    _reload_gutter_for_script(script)

func _on_editor_script_closed(script:Script) -> void:
    if not script is GDScript:
        return
    _remove_script_from_cache(script.resource_path)

func _get_script_editor_sth_gutter_id(script_editor:ScriptEditorBase) -> int:
    var code_edit:CodeEdit = script_editor.get_base_editor() as CodeEdit
    var sth_gutter_id:int = -1
    for g in code_edit.get_gutter_count():
        if code_edit.get_gutter_name(g) == GUTTER_NAME:
            sth_gutter_id = g
            break

    # No gutter, create it
    if sth_gutter_id == -1:
        sth_gutter_id = code_edit.get_gutter_count() # Last gutter index
        code_edit.add_gutter()
        code_edit.set_gutter_name(sth_gutter_id, GUTTER_NAME)
        code_edit.set_gutter_type(sth_gutter_id, CodeEdit.GUTTER_TYPE_ICON)
        code_edit.set_gutter_width(sth_gutter_id, code_edit.get_line_height())

    return sth_gutter_id

func _reload_gutter_for_script(script:GDScript) -> void:
    if not _cached_script_editors.has(script.resource_path):
        return

    var script_editor:ScriptEditorBase = _cached_script_editors[script.resource_path]["editor"]
    var code_edit:CodeEdit = script_editor.get_base_editor() as CodeEdit
    var sth_gutter_id:int = _cached_script_editors[script.resource_path]["gutter_id"]

    # Clear gutters
    _cached_script_editors[script.resource_path]["gutters"].clear()
    for l in code_edit.get_line_count():
        code_edit.set_line_gutter_icon(l, sth_gutter_id, null)

    # If its a TestCase, replace new gutters
    var parsed_script:ParsedGDScript = ParsedGDScript.new()
    parsed_script.parse(script)
    if parsed_script.script_parent_class_name == "TestCase":
        for function in parsed_script.script_functions:
            if _is_valid_test_function(function):
                if _can_run_tests:
                    code_edit.set_line_gutter_icon(function.function_line_number, sth_gutter_id, IconRegistry.ICON_RUN_TEST)
                    code_edit.set_line_gutter_clickable(function.function_line_number, sth_gutter_id, true)
                else:
                    code_edit.set_line_gutter_icon(function.function_line_number, sth_gutter_id, IconRegistry.ICON_RUN_TEST_DISABLED)
                    code_edit.set_line_gutter_clickable(function.function_line_number, sth_gutter_id, false)
                _cached_script_editors[script.resource_path]["gutters"][function.function_line_number] = function.function_name

func _on_gutter_clicked(line:int, gutter_id:int, script:GDScript) -> void:
    if _cached_script_editors.has(script.resource_path):
        # Ok it's a GD script testcase !
        # Force save, because if there is any unsaved changed, lines will not be properly computed
        var error:int = ResourceSaver.save(script, script.resource_path)
        if error != 0:
            push_error("Unable to save %s ! %s" % [script.resource_path, error_string(error)])
        else:
            # Refresh gutters in case of saved changes
            _reload_gutter_for_script(script)
            _cached_script_editors[script.resource_path]["editor"].get_base_editor().tag_saved_version()

            # Then run test case
            var sth_gutter_id:int=  _cached_script_editors[script.resource_path]["gutter_id"]
            if sth_gutter_id == gutter_id:
                if _cached_script_editors[script.resource_path]["gutters"].has(line):
                    var test_function_name:String = _cached_script_editors[script.resource_path]["gutters"][line]
                    _plugin.execute_test_case_method(script.resource_path, test_function_name)

func _remove_script_from_cache(script_path:String) -> void:
    if _cached_script_editors.has(script_path):
        var script_editor:ScriptEditorBase = _cached_script_editors[script_path]["editor"]
        script_editor.get_base_editor().gutter_clicked.disconnect(_cached_script_editors[script_path]["editor_gutter_click_callable"])
        var sth_gutter_id:int = _cached_script_editors[script_path]["gutter_id"]
        _cached_script_editors[script_path]["closing"] = true
        _cached_script_editors[script_path]["gutters"].clear()
        script_editor.get_base_editor().remove_gutter(sth_gutter_id)

func _is_valid_test_function(function:ParsedGDScriptFunction) -> bool:
    return function.function_line_number != -1 \
        and not function.is_static \
        and not function.is_virtual \
        and not function.is_editor \
        and function.function_name.begins_with("test") \
        and function.function_arguments.is_empty()

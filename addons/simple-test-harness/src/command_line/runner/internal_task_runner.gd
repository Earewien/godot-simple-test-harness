class_name InternalTaskRunner2
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

var CMD_ARG_LIST_TESTCASES: = CommandLineArgument.new("-ltc", "--list-testcases", "Search for test cases in a directory", TYPE_STRING)
var CMD_ARG_RUN_EXEC_PLAN: = CommandLineArgument.new("ep", "--execute-plan", "Run an execution plan", TYPE_STRING)
var CMD_ARG_OUTPUT_FILE: = CommandLineArgument.new("-o", "--output", "Result output file", TYPE_STRING)

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------
#
#
#func _process(delta: float) -> void:
#    var command_line_arguments:PackedStringArray = OS.get_cmdline_args()
#
#    # Commun
#    var option_output_file:CommandLineOption = CMD_ARG_OUTPUT_FILE.parse_args(command_line_arguments)
#
#    # Les commandes haut niveau
#    var option_list_testcases:CommandLineOption = CMD_ARG_LIST_TESTCASES.parse_args(command_line_arguments)
#    var option_exec_plan:CommandLineOption = CMD_ARG_RUN_EXEC_PLAN.parse_args(command_line_arguments)
#
#    # LISTER LES TEST CASES
#    if option_list_testcases != null and option_list_testcases.valid:
#        if option_output_file != null and option_output_file.valid:
#            var report:ListTestCaseReport = ListTestCaseCommand.new(option_list_testcases.value).execute()
#            _write_value_into_file(report, option_output_file.value)
#            get_tree().quit(0)
#    # EXECUTER UNE TESTSUITE (EXEC PLAN)
#    elif option_exec_plan != null and option_exec_plan.valid:
#        if option_output_file != null and option_output_file.valid:
#            var plan:RunExecutionPlanCommand = RunExecutionPlanCommand.new(option_exec_plan.value)
#
#            Engine.get_main_loop().root.add_child(plan)
#            set_process(false)
#            var report:RunExecutionPlanReport = await plan.execute()
#            set_process(true)
#            Engine.get_main_loop().root.remove_child(plan)
#
#            _write_value_into_file(report, option_output_file.value)
#            get_tree().quit(0)
#    else:
#        push_error("Missing command : %s" % command_line_arguments)
#        # Aucune option valide !
#        get_tree().quit(1)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _write_value_into_file(value:Variant, output_file_path:String) -> void:
    var output_file:FileAccess = FileAccess.open(output_file_path, FileAccess.WRITE)
    output_file.store_string(var_to_str(value.serialize()))
    output_file.flush()


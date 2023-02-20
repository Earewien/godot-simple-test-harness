class_name SignalCollector
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

var _object:WeakRef
var _connected_signals:Array[Signal] = []
var received_signals:Dictionary = {}
var _collecting_all_signals:bool = false

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(object:Object) -> void:
    _object = weakref(object)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func collect_signal(sig:Signal) -> bool:
    if not sig.is_null():
        if is_instance_valid(_object.get_ref()):
            if sig.get_object() == _object.get_ref():
                var all_signals:Array[Dictionary] = _object.get_ref().get_signal_list()
                for object_sig in all_signals:
                    if object_sig["name"] == sig.get_name():
                        _connect_signal(sig, object_sig["args"].size())
                        return true
    return false

func collect_all_signals() -> void:
    _connect_to_object_signals()

func is_collecting(sig:Signal) -> bool:
    return _connected_signals.has(sig)

func is_collecting_all_signals_for(object:Object) -> bool:
    return _collecting_all_signals and _object.get_ref() == object

func get_emitted_signal_arguments(sig:Signal) -> Array:
    if not _connected_signals.has(sig):
        return []
    if not received_signals.has(sig.get_name()):
        return []

    return received_signals[sig.get_name()]

func reset_signal_received() -> void:
    received_signals.clear()

func has_received_signal(sig:Signal) -> bool:
    if not _connected_signals.has(sig):
        return false

    if not received_signals.has(sig.get_name()):
        return false

    return not received_signals[sig.get_name()].is_empty()

func has_received_signal_exactly(sig:Signal, number_of_times:int) -> bool:
    if not _connected_signals.has(sig):
        return false

    if not received_signals.has(sig.get_name()) and number_of_times == 0:
        return true

    if not received_signals.has(sig.get_name()):
        return false

    return received_signals[sig.get_name()].size() == number_of_times

func has_received_signal_with_args(sig:Signal, args:Array) -> bool:
    if not _connected_signals.has(sig):
        return false

    if not received_signals.has(sig.get_name()):
        return false

    var received_sig_args:Array = received_signals[sig.get_name()]
    for received_sig_arg in received_sig_args:
        if args == received_sig_arg:
            return true

    return false

func has_received_signal_with_args_exactly(sig:Signal, args:Array, number_of_times:int = 1) -> bool:
    if not _connected_signals.has(sig):
        return false

    if not received_signals.has(sig.get_name()) and number_of_times == 0:
        return true

    if not received_signals.has(sig.get_name()):
        return false

    var received_sig_args:Array = received_signals[sig.get_name()]
    var count:int = 0
    for received_sig_arg in received_sig_args:
        if args == received_sig_arg:
            count += 1

    return count == number_of_times

func has_received_signal_with_args_in_exact_order(sig:Signal, args_array:Array[Array]) -> bool:
    if not _connected_signals.has(sig):
        return false

    if not received_signals.has(sig.get_name()):
        return false

    var received_sig_args:Array = received_signals[sig.get_name()]
    for i in received_sig_args.size():
        if i + args_array.size() - 1 <= received_sig_args.size() - 1:
            for j in args_array.size():
                if received_sig_args[i + j] == args_array[j]:
                    if j == args_array.size() - 1:
                        return true
                else:
                    break

    return false

func finalize() -> void:
    for sig in _connected_signals:
        if not sig.is_null():
            sig.disconnect(_on_signal_received)
    _object = null
    _connected_signals.clear()
    received_signals.clear()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _connect_to_object_signals() -> void:
    if not _collecting_all_signals:
        if is_instance_valid(_object.get_ref()):
            _collecting_all_signals = true
            var all_signals:Array[Dictionary] = _object.get_ref().get_signal_list()
            for sig in all_signals:
                var object_signal:Signal = Signal(_object.get_ref(), sig["name"])
                if not object_signal.is_null():
                    _connect_signal(object_signal, sig["args"].size())

func _connect_signal(object_signal:Signal, arg_count:int) -> void:
    if not _connected_signals.has(object_signal) and not object_signal.is_connected(_on_signal_received):
        object_signal.connect(_on_signal_received.bind(object_signal, arg_count))
        _connected_signals.append(object_signal)

func _on_signal_received(arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null, arg10 = null, \
    arg11 = null, arg12 = null, arg13 = null, arg14 = null, arg15 = null, arg16 = null, arg17 = null, arg18 = null, arg19 = null, arg20 = null, \
    arg21 = null, arg22 = null, arg23 = null, arg24 = null, arg25 = null, arg26 = null, arg27 = null, arg28 = null, arg29 = null, arg30 = null):
    var all_args_as_array:Array = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30]
    var sig:Signal
    var arg_count:int
    for i in range(all_args_as_array.size() - 1, -1, -1):
        if all_args_as_array[i] is Signal:
            sig = all_args_as_array[i]
            arg_count = all_args_as_array[i+1]
            break
    var signal_args:Array = all_args_as_array.slice(0, arg_count)

    if not received_signals.has(sig.get_name()):
        received_signals[sig.get_name()] = []
    received_signals[sig.get_name()].append(signal_args)

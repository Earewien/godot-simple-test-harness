@tool
class_name STHShortcutHandler
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

var _shortcuts:Dictionary = {}

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if not event.echo and not event.pressed:
            for shortcut in _shortcuts.keys():
                if shortcut.matches_event(event):
                    var condition_result = _shortcuts[shortcut]["enable_condition"].call()
                    if condition_result == true:
                        accept_event()
                        _shortcuts[shortcut]["action"].call()

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func add_shortcut(shortcut:Shortcut, enable_condition:Callable, action:Callable) -> void:
    _shortcuts[shortcut] = {
        "enable_condition" : enable_condition,
        "action" : action
    }

#------------------------------------------
# Fonctions privées
#------------------------------------------


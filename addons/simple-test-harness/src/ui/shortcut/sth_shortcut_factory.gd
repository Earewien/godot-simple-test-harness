class_name STHShortcutFactory
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

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func get_shortcut(menu_entry:Dictionary) -> Shortcut:
    var key_com:PackedInt32Array = menu_entry["shortcut"]
    var key_input:InputEventKey = InputEventKey.new()
    for key in key_com:
        if key == KEY_ALT:
            key_input.alt_pressed = true
        elif key == KEY_SHIFT:
            key_input.shift_pressed = true
        elif key == KEY_CTRL:
            key_input.ctrl_pressed = true
        else:
            key_input.keycode = key
    var shortcut: = Shortcut.new()
    shortcut.events = [key_input]
    shortcut.resource_name = menu_entry["name"]
    return shortcut


#------------------------------------------
# Fonctions privées
#------------------------------------------


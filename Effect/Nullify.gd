extends Effects

# Blocks all damage

func _init():
    event_type = "minify_damage"
    name = "Nullify"

# Override the on_event to react to damage event
func on_event(event_type: String, data: Dictionary) -> void:
    if event_type == "minify_damage":
        data["damage"] *= 0  # Apply the damage multiplier
        if(get_triggers() != -1):
            update_trigger(attached_user)
    .on_event(event_type, data)

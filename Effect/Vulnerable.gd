extends Effects

# Applies 1.5x increase damage in damage received

func _init():
    event_type = "minify_damage"
    name = "Vulnerable"
    
# Override the on_event to react to damage event
func on_event(event_type: String, data: Dictionary) -> void:
    if event_type == "minify_damage":
        data.damage = round(data.damage * 1.5)  # Increase damage taken by 50%
        if(get_triggers() != -1):
            update_trigger(attached_user)
    .on_event(event_type, data)
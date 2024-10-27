extends Effects

# Applies double damage for the next attack

func _init():
    event_type = "magnify_damage"
    name = "Double Damage"

# Override the on_event to react to damage event
func on_event(event_type: String, data: Dictionary) -> void:
    if event_type == "magnify_damage":
        print("Double Damage is magnifying damage from", data["damage"], "to", data["damage"] * 2)
        data["damage"] *= 2  # Apply the damage multiplier
        if(get_triggers() != -1):
            update_trigger(attached_user)
    .on_event(event_type, data)

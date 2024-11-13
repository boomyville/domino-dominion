extends Effects

# Increases damage by X
# Reduces by 1 per turn

func _init():
    event_type = "modify_damage"
    name = "Fury"

# Override the on_event to react to damage event
func on_event(event_type: String, data: Dictionary) -> void:
    if event_type == "modify_damage":
        data["damage"] += get_duration() 
    .on_event(event_type, data)

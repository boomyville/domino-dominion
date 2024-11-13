extends Effects

# Prevents domino swapping numbers (flipping)

func _init():
	event_type = "draw_to_hand"
	name = "Petrification"

# React to the shield block event
func on_event(event_type: String, data: Dictionary) -> void:
	if event_type == "draw_to_hand":
		data.domino.set_petrification(1)
		if(get_triggers() != -1):
			update_trigger(attached_user)
	.on_event(event_type, data)

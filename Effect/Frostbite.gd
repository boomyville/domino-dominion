extends Effects

# Prevents domino swapping numbers (flipping)

func _init():
	event_type = "draw_domino"
	name = "Frostbite"

# React to the shield block event
func on_event(event_type: String, data: Dictionary) -> void:
	if event_type == "draw_domino" && data.draw > 0:
		data.draw -= 1
	.on_event(event_type, data)

extends Effects

# Prevents domino swapping numbers (flipping)

func _init():
	event_type = "after_swap"
	name = "Paralysis"

# React to the shield block event
func on_event(event_type: String, data: Dictionary) -> void:
	if event_type == "after_swap" && data.result == "swap":
		data.result = "unplayable"
	.on_event(event_type, data)

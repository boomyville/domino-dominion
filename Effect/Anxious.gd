extends Effects

# Only allows attacks to be played

func _init():
	event_type = "domino_check"
	effect_name = "Anxious"
	bb_code = BBCode.bb_code_anxious()
	opposite_effects = ["Berserk"]

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false):
	if new_event_type == "domino_requirements":
		if("Attack" in data.domino_played.filename):
			return false
	.on_event(new_event_type, data)

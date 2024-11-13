extends Effects

# Apply damage equal to burrn stack when user attacks. Ticks down per attack. Blockable with shields

func _init():
	event_type = "on_turn_end"
	name = "Burn"

# React to the shield block event
func on_event(event_type: String, data: Dictionary) -> void:
	if(get_triggers() <= -1):
		# No unlimited or negative burns
		attached_user.effects.erase(self)
	if event_type == "play_domino":
		if("Attack" in data.domino_played.filename):
			data.user.self_damage(get_triggers(), true)
			print("Burn! ", get_triggers(), " damage")
			if(get_triggers() != -1):
				update_trigger(attached_user)
	.on_event(event_type, data)

extends Effects

# Applies a vulnerable debuff to the attacker if defender (user) fully blocks an attack

func _init():
	event_type = "take_damage"
	effect_name = "Auto Revive"
	bb_code = BBCode.bb_code_blessing()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "receive_damage":
		if data.defender.hp <= 0:
			data.defender.set_hp(1)
			data.defender.effects.erase(self)
			
			var animation = preload("res://Battlers/Animations/AutoRevive.tscn")
			var animation_instance = animation.instance()
			data.defender.get_node("AnimationLayer").add_child(animation_instance)
			animation_instance.play_animation(data.defender)

			Game.get_node("Game").show_popup("Lucky!", data.defender, "White", "PopupRiseAnimation")

	.on_event(new_event_type, data)


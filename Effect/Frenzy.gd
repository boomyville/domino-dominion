extends Effects

# Gain 1+ action point per turn but increase skill costs by 1 AP

func _init():
	event_type = "action_points_per_turn"
	effect_name = "Frenzy"
	bb_code = BBCode.bb_code_frenzy()

func modify_action_points_cost() -> Dictionary:
	return {"all": 0, "attack": 0, "skill": 1}
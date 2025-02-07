extends "res://Battlers/Battler.gd"

# Enemy difficult criteria:
# - very_easy
# - easy
# - intermediate
# - tough
# - hard
# - very_hard
# - brutal
# - diabolical
# - impossible


func _ready():
	# Idle animation
	if has_node("AnimatedSprite"):
		$AnimatedSprite.play("idle")
		#$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
	
	update()

# Animation related functions
func _on_animation_finished():
	if $AnimatedSprite.animation == "attack":
		$AnimatedSprite.play("idle")  # Return to idle after attacking

func initialize_deck():
	.initialize_deck()

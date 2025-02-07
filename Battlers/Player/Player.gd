extends "res://Battlers/Battler.gd"

func _ready():
	
	# Idle animation
	if has_node("AnimatedSprite"):
		$AnimatedSprite.play("idle")
	
	update()

# Animation related functions
func _on_animation_finished():
	if $AnimatedSprite.animation == "attack":
		$AnimatedSprite.play("idle")  # Return to idle after attacking
	
func initialize_deck():
	# Create the player's deck of dominosino, "player")
	for _i in range(5):
		var domino = load("res://Domino/Attack/Strike.tscn").instance()
		add_to_deck(domino, "player")
	for _i in range(5):
		var domino = load("res://Domino/Skill/Block.tscn").instance()
		add_to_deck(domino, "player")

	.initialize_deck()

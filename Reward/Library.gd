extends CanvasLayer

func _on_ExitButton_pressed():
	queue_free()

func clear():
	for child in $ScrollContainer/GridContainer.get_children():
		$ScrollContainer/GridContainer.remove_child(child)

func populate_deck():
	var deck = Game.get_node("Game").player.get_deck()
	deck.sort_custom(self, "_sort_by_name")
	for domino in deck:
		
		var domino_container = preload("res://Reward/RewardDomino.tscn").instance()
		domino_container.active = false
		domino_container.type = domino_container.reward_type.DOMINO
		domino_container.set_domino(domino)
		$ScrollContainer/GridContainer.add_child(domino_container)

# Sorting function
func _sort_by_name(a, b):
	# First, compare names
	if a.domino_name.to_lower() != b.domino_name.to_lower():
		return a.domino_name.to_lower() < b.domino_name.to_lower()

	# Compare the first number
	if a.get_numbers()[0] != b.get_numbers()[0]:
		return a.get_numbers()[0] < b.get_numbers()[0]

	# If the first numbers are the same, compare the second number
	return a.get_numbers()[1] < b.get_numbers()[1]

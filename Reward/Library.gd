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



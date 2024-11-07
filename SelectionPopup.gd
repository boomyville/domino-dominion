extends CanvasLayer

var minimum_selections = 1
var maximum_selections = 1
var selected_dominos = []
var dominos_to_display # Array of dominos available for selection
var origin_domino = null
var target = "PLAYER"  # Can also be ENEMY and BOARD
var collection = "HAND"  # can also be PILE, DISCARD or VOID. For BOARD, collection is ignored
var destination_collection = "HAND" # can also be PILE, DISCARD or VOID (cannot be BOARD)
var game = Game.get_node("Game")

onready var confirmButton = $PopupPanel/VBoxContainer/HBoxContainer/ConfirmButton
onready var background_dimmer = $BackgroundDimmer # Assuming this is a semi-transparent ColorRect to dim background

func _ready():
	confirmButton.connect("pressed", self, "_on_ConfirmButton_pressed")
	background_dimmer.visible = false  # Ensure dimmer is hidden initially

# Called to initialize the popup with dominos from the player's hand
func setup_selection_popup(dominos_to_display, minimum_selections: int, maximum_selections: int, origin_domino: DominoContainer, target: String, collection: String, destination_collection: String, method: String):
	self.maximum_selections = maximum_selections
	self.minimum_selections = minimum_selections
	self.dominos_to_display = dominos_to_display
	self.origin_domino = origin_domino
	self.target = target
	self.collection = collection
	self.destination_collection = destination_collection
	selected_dominos.clear()
	display_dominos()
	background_dimmer.visible = true
	self.visible = true  # Show CanvasLayer popup

# Show draw pile / discar pile / void space
func setup_collection_popup(dominos_to_display: Array, type: String):
	self.dominos_to_display = dominos_to_display
	Game.get_node("Game").game_state = Game.get_node("Game").GameState.DOMINO_CHECK
	display_collection(type)
	background_dimmer.visible = true
	self.visible = true  # Show CanvasLayer popup

func display_collection(type: String):
	var message = $PopupPanel/VBoxContainer/InfoMessage
	match type.to_upper():
		"DRAW":
			message.text = "Draw pile"
		"DISCARD":
			message.text = "Discard Pile"
		"VOID":
			message.text = "Void space"
	
	var container = $PopupPanel/VBoxContainer/GridContainer
	
	for child in container.get_children():
		container.remove_child(child)  # Clear any existing UI elements in the popup

	# Create clones for display purposes only
	for domino in dominos_to_display:
		var domino_clone = domino.shadow_copy()

		var right_tile = domino_clone.get_node("HBoxContainer/RightTile")
		var left_tile = domino_clone.get_node("HBoxContainer/LeftTile")
		
		left_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])
		right_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])

		domino_clone.visible = true
		domino_clone.modulate = Color(1, 1, 1, 1)
		container.add_child(domino_clone)
	

func display_dominos():
	var message = $PopupPanel/VBoxContainer/InfoMessage
	var msg = ""
	if minimum_selections == maximum_selections:
		if minimum_selections > 1:
			msg += "Select " + str(minimum_selections) + " dominos"
		else:
			msg += "Select a domino"
	else:
		msg += "Select " + str(minimum_selections) + " to " + str(maximum_selections) + " dominos"

	msg += " to "
	match destination_collection.to_lower():
		"hand":
			msg += " place into your hand"
		"pile":
			msg += " place into your draw pile"
		"discard":
			msg += " discard"
		"void":
			msg += " remove from the game"
		"board":
			msg += " place on the board"

	message.text = msg

	var container = $PopupPanel/VBoxContainer/GridContainer
	for child in container.get_children():
		container.remove_child(child)  # Clear any existing UI elements in the popup

	# Create clones for display purposes only
	for domino in dominos_to_display:
		if domino != origin_domino and domino != null:
			var domino_clone = domino.shadow_copy()
			var left_tile = domino_clone.get_node("HBoxContainer/LeftTile")
			left_tile.mouse_filter = Control.MOUSE_FILTER_PASS
			left_tile.visible = true
			var right_tile = domino_clone.get_node("HBoxContainer/RightTile")
			right_tile.mouse_filter = Control.MOUSE_FILTER_PASS
			right_tile.visible = true
			left_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])
			right_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])
			container.add_child(domino_clone)

	update_confirm_button()

func _on_domino_clicked(original_domino):
	
	if game.game_state != game.GameState.DOMINO_CHECK:
		original_domino.set_clicked(!original_domino.selected)
		if original_domino.selected:
			selected_dominos.append(original_domino)
		else:
			selected_dominos.erase(original_domino)
	else:
		original_domino.show_domino_description(original_domino)
	
	update_confirm_button()

func update_confirm_button():
	
	confirmButton.disabled = !((game.game_state == game.GameState.DOMINO_CHECK) || selected_dominos.size() >= minimum_selections && selected_dominos.size() <= maximum_selections)

# Confirm selection and trigger discard
func _on_ConfirmButton_pressed():
	match game.game_state:
		game.GameState.DOMINO_CHECK:
			hide_popup()
			game.game_state = game.GameState.DEFAULT
		_:
			game.process_selection(selected_dominos, target, collection, destination_collection)
			origin_domino.emit_signal("pre_effect_complete")
			hide_popup()

func hide_popup():
	self.visible = false
	background_dimmer.visible = false
	game.unselect_dominos()

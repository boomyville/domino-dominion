extends PopupPanel

var minimum_discards = 1
var maximum_discards = 1
var selected_dominos = []
var dominos_to_display # Array of dominos available for discard
var origin_domino = null
var target = "PLAYER"	# Can also be ENEMY and BOARD
var collection = "HAND"	# can also be PILE, DISCARD or VOID. For BOARD, collection is ignored

onready var confirmButton = get_node("VBoxContainer/HBoxContainer/ConfirmButton")

func _ready():
	confirmButton.connect("pressed", self, "_on_ConfirmButton_pressed")

# Called to initialize the popup with dominos from the player's hand
func setup_discard_popup(dominos_to_display, minimum_discards: int, maximum_discards: int, origin_domino: DominoContainer, target: String, collection: String):
	self.maximum_discards = maximum_discards
	self.minimum_discards = minimum_discards
	self.dominos_to_display = dominos_to_display
	self.origin_domino = origin_domino
	self.target = target
	self.collection = collection
	selected_dominos.clear()
	display_dominos()

# Display buttons for each domino in the player's hand
func display_dominos():
	var container = $VBoxContainer/GridContainer
	for child in container.get_children():
		child.queue_free() # Clear any existing UI elements
	
	for domino in dominos_to_display.get_children():
		if(domino != origin_domino):
			# Clone the domino to display in the popup
			var domino_clone = domino.shadow_copy()

			# Ensure the tiles are interactive and visible
			var left_tile = domino_clone.get_node("HBoxContainer/LeftTile")
			left_tile.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow mouse events to pass to buttons
			left_tile.visible = true

			var right_tile = domino_clone.get_node("HBoxContainer/RightTile")
			right_tile.mouse_filter = Control.MOUSE_FILTER_PASS
			right_tile.visible = true

			# Connect the buttons to the click handler
			left_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])
			right_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])

			$VBoxContainer/GridContainer.add_child(domino_clone)
	
	update_confirm_button()

# Toggle selection on domino click
func _on_domino_clicked(clicked_domino):
	clicked_domino.set_clicked(!clicked_domino.selected)
	if(clicked_domino.selected):
		selected_dominos.append(clicked_domino)
	else:
		selected_dominos.erase(clicked_domino)
	var msg = ""
	for domino in selected_dominos:
		msg += domino.domino_name + " "
	Game.get_node("Game").debug_text.text = msg 
	update_confirm_button()

# Enable confirm button only if enough dominos are selected
func update_confirm_button():
	confirmButton.disabled = !(selected_dominos.size() >= minimum_discards && selected_dominos.size() <= maximum_discards)

# Confirm selection and trigger discard
func _on_ConfirmButton_pressed():
	# Call the function in the main game to process the discard
	Game.get_node("Game").process_discard(selected_dominos)
	origin_domino.emit_signal("pre_effect_complete")
	queue_free()  # Close the popup after confirming

extends PopupPanel

var minimum_selections = 1
var maximum_selections = 1
var selected_dominos = []
var dominos_to_display # Array of dominos available for discard
var origin_domino = null
var target = "PLAYER"	# Can also be ENEMY and BOARD
var collection = "HAND"	# can also be PILE, DISCARD or VOID. For BOARD, collection is ignored
var method

onready var confirmButton = get_node("VBoxContainer/HBoxContainer/ConfirmButton")

func _ready():
	confirmButton.connect("pressed", self, "_on_ConfirmButton_pressed")

# Called to initialize the popup with dominos from the player's hand
func setup_selection_popup(dominos_to_display, minimum_selections: int, maximum_selections: int, origin_domino: DominoContainer, target: String, collection: String, method: String):
	self.maximum_selections = maximum_selections
	self.minimum_selections = minimum_selections
	self.dominos_to_display = dominos_to_display
	self.origin_domino = origin_domino
	self.target = target
	self.collection = collection
	self.method = method
	selected_dominos.clear()
	display_dominos()

# Display buttons for each domino in the player's hand
func display_dominos():
	var container = $VBoxContainer/GridContainer
	for child in container.get_children():
		child.queue_free() # Clear any existing UI elements
	
	for domino in dominos_to_display:
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
	confirmButton.disabled = !(selected_dominos.size() >= minimum_selections && selected_dominos.size() <= maximum_selections)

# Confirm selection and trigger discard
func _on_ConfirmButton_pressed():
	# Call the function in the main game to process the discard
	Game.get_node("Game").call(self.method, selected_dominos)
	origin_domino.emit_signal("pre_effect_complete")
	queue_free()  # Close the popup after confirming

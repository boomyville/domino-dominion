extends PopupPanel

var minimum_selections = 1
var maximum_selections = 1
var selected_dominos = []
var dominos_to_display # Array of dominos available for selection
var origin_domino = null
var target = "PLAYER"	# Can also be ENEMY and BOARD
var collection = "HAND"	# can also be PILE, DISCARD or VOID. For BOARD, collection is ignored
var destination_collection = "HAND" # can also be PILE, DISCARD or VOID (cannot be BOARD)

onready var confirmButton = get_node("VBoxContainer/HBoxContainer/ConfirmButton")

func _ready():
	confirmButton.connect("pressed", self, "_on_ConfirmButton_pressed")

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

func display_dominos():
	var message = $VBoxContainer/InfoMessage
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

	var container = $VBoxContainer/GridContainer
	for child in container.get_children():
		child.queue_free()  # Clear any existing UI elements in the popup

	# Create clones for display purposes only
	for domino in dominos_to_display:
		if domino != origin_domino and domino != null:
			# Use shadow_copy() to create a temporary duplicate
			var domino_clone = domino.shadow_copy()

			# Ensure the tiles are interactive and visible
			var left_tile = domino_clone.get_node("HBoxContainer/LeftTile")
			left_tile.mouse_filter = Control.MOUSE_FILTER_PASS
			left_tile.visible = true

			var right_tile = domino_clone.get_node("HBoxContainer/RightTile")
			right_tile.mouse_filter = Control.MOUSE_FILTER_PASS
			right_tile.visible = true

			# Connect buttons to click handler and pass reference to the original domino
			left_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])
			right_tile.connect("pressed", self, "_on_domino_clicked", [domino_clone])

			# Add the clone to the GridContainer (for temporary display only)
			container.add_child(domino_clone)

	update_confirm_button()

# Toggle selection on domino click
func _on_domino_clicked(original_domino):
	# Flip selection state for the original domino
	original_domino.set_clicked(!original_domino.selected)
	
	if original_domino.selected:
		selected_dominos.append(original_domino)  # Add the original domino to selections
	else:
		selected_dominos.erase(original_domino)

	# Debugging info
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
	#Game.get_node("Game").call(self.method, selected_dominos)
	Game.get_node("Game").process_selection(selected_dominos, target, collection, destination_collection)
	origin_domino.emit_signal("pre_effect_complete")
	self.hide()  # Close the popup after confirming
	Game.get_node("Game").unselect_dominos()


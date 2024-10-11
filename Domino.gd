# DominoContainer.gd
extends HBoxContainer

var number1: int = 0
var number2: int = 0

export var clickable = false;
export var type = "neutral";

# Define a custom signal to notify the parent node when the domino is pressed
signal domino_pressed(domino_container)

# Called when the node enters the scene tree
func _ready():
	update_domino()
	# Connect the button press signals to a custom function to handle player moves
	$LeftTile.connect("pressed", self, "_on_domino_pressed")
	$RightTile.connect("pressed", self, "_on_domino_pressed")

# Set the numbers for the domino and update the buttons
func set_numbers(n1: int, n2: int):
	number1 = n1
	number2 = n2
	update_domino()

func set_clickable(clickable: bool):
	self.clickable = clickable
	update_domino()

# Update the buttons to show the numbers
func update_domino():
	$LeftTile.set_text(str(number1))
	$RightTile.set_text(str(number2))
	$LeftTile.disabled = !clickable;
	$RightTile.disabled = !clickable;
	
# Function called when the domino is pressed
func _on_domino_pressed():
	emit_signal("domino_pressed", self)  # Emit the signal, passing itself as an argument

extends ProgressBar

# Declare the variables
var gauge_value = 100
var max_gauge_value = 100
# Called when the node enters the scene tree

func _ready():
	# Set the initial value of the HP gauge
	self.max_value = max_gauge_value
	self.value = gauge_value

# Method to update health
func new_value(new_value: int):
	gauge_value = clamp(new_value, 0, max_gauge_value) # Clamp to avoid exceeding limits
	self.value = gauge_value

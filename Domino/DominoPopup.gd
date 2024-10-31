extends PopupPanel

# A label to show the description
onready var description_label = $Label

# Function to set the description text
func set_description(text: String):
	description_label.bbcode_text  = text

func _on_Popup_outer_click():
	queue_free()

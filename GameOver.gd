extends CanvasLayer

func _ready():
	$Node2D.modulate = Color(1, 1, 1, 0)

func show_scene():
	$Node2D/AnimationPlayer.play("fade_in")
	
func remove_scene():
	$Node2D/AnimationPlayer.play("fade_out")

func set_reason_message(reason: String):
	$Node2D/Reason.text = reason

func set_statistics(statistics: String):
	$Node2D/StatLabel.text = statistics

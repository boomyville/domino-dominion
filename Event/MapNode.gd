extends Node2D

var property = "Empty" # Default property
var volumn = 0 # Stores which column this node is in

func set_property(type: String = "random"):
	self.property = type
	update_property()

func set_column(column: int):
	self.volumn = column

func update_property():
	match property:
		"upgrade":
			$TextureButton.texture_normal = load("res://Icons/Upgrade.png")
			$TextureButton.texture_disabled = load("res://Icons/UpgradeDisabled.png")
			self.property = "upgrade"
		"empty":
			$TextureButton.texture_normal = load("res://Icons/Empty.png")
			$TextureButton.texture_disabled = load("res://Icons/Empty.png")
			self.property = "empty"
		"event", "mystery":
			$TextureButton.texture_normal = load("res://Icons/Mystery.png")
			$TextureButton.texture_disabled = load("res://Icons/MysteryDisabled.png")
			self.property = "event" 
		"battle", "enemy":
			$TextureButton.texture_normal = load("res://Icons/Enemy.png")
			$TextureButton.texture_disabled = load("res://Icons/EnemyDisabled.png")
			self.property = "battle"
		"heal", "recovery":
			$TextureButton.texture_normal = load("res://Icons/Recovery.png")
			$TextureButton.texture_disabled = load("res://Icons/RecoveryDisabled.png")
			self.property = "heal"

func get_property() -> String:
	return property

func set_visited(visited: bool):
	if visited:
		set_active(false)
		$VisitedSprite.visible = true
	else:
		$TextureButton.disabled = false
		$VisitedSprite.visible = false

func set_active(active: bool):
	if active:
		#$TextureButton.disabled = false
		$TextureButton.disabled = false
	else:
		#$TextureButton.disabled = true
		$TextureButton.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_active(false)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	match property:
		"upgrade":
			# To add
			Game.get_node("Game").new_mystery_event()
		"empty":
			# To add
			Game.get_node("Game").new_battle()
		"event", "mystery":
			# To add
			Game.get_node("Game").new_mystery_event()
		"battle", "enemy":
			# To add
			Game.get_node("Game").new_battle()
		"heal", "recovery":
			# To add
			Game.get_node("Game").new_mystery_event()
		_: # Default
			Game.get_node("Game").new_battle()
	print(get_parent().get_parent().has_method("destroy"))
	get_parent().get_parent().destroy(self)


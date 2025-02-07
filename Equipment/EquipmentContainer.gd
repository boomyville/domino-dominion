extends Control

var equipment_name: String
var description: String
var equipped: bool
var criteria
var selected: bool = false

signal equipment_pressed

func _init(name: String = "Empty", new_description: String = "Empty slot", new_equipped_status: bool = false, new_criteria: Array = []): 
	self.equipment_name = name
	self.description = new_description
	self.equipped = new_equipped_status
	self.criteria = new_criteria
	#print("Equipment container initialized: name: ", self.equipment_name, " description: ", self.description, " equipped: ", self.equipped, " criteria: ", self.criteria)

func set_equipment_container(player, equipment):
	set_equipment_name(equipment.equipment_name)
	set_description(equipment.description)
	set_icon(equipment.icon)
	set_criteria(equipment.criteria)
	set_equipped(player.is_equipped(equipment))

func set_equipment_name(name: String):
	self.equipment_name = name

func set_description(new_description: String):	
	self.description = new_description

func get_description() -> String:
	return self.description

func set_icon(icon: String):
	var icon_texture = load(icon)
	$Sprite.texture_normal = icon_texture 
	#print("Icon type:", typeof(icon_texture))  # Should output TYPE_TEXTURE (25)
	
func set_criteria(new_criteria: Array):	
	self.criteria = new_criteria

func set_equipped(new_equpped_status: bool):
	self.equipped = new_equpped_status
	self.set_equip(new_equpped_status)

func set_equip(value: bool):
	self.equipped = value
	if equipped:
		$IconRect.color = Color(0.2, 0.7, 0.2, 1)
	else:
		$IconRect.color = Color(0.5, 0.2, 0.2, 1)

func update():
	if(selected):
		$ColorRect.color = Color(0.0, 0.5, 0.0, 1)
	else:
		$ColorRect.color = Color(0.0, 0.0, 0.0, 0.0)

func _on_Sprite_pressed():
	emit_signal("equipment_pressed")

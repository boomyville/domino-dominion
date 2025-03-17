extends Container

# The below global variables are copied from RewardDomino.gd

var reference
var reference_scene
var type
enum reward_type {DOMINO, EQUIPMENT}

func _ready():
	reference_scene = get_parent().get_parent()

# This script has a strong reliance on the parent node
# The parent node (shop.gd) will have a reference_domino window 
# that will be updated with the domino or equipment information
# when the buttons are pressed

func set_type(type_of_reward):
	if(type_of_reward == "DOMINO"):
		type = reward_type.DOMINO
	elif(type_of_reward == "EQUIPMENT"):
		type = reward_type.EQUIPMENT
	elif (type_of_reward == null):
		type = null
	else:
		push_error("Invalid type of reward: " + type_of_reward)

func get_type():
	return type

func set_reference(new_reference):
	reference = new_reference

func create(item, new_type_of_reward, upgrade_level_modifier: int = 0, over_upgrade: bool = false):
	set_type(new_type_of_reward)
	set_reference(item)

func _on_Button1_pressed():
	reference_scene.get_node("Container").visible = true

		# Shows information about item
	if !is_instance_valid(reference_scene):
		push_error("reference_scene is not valid")
		return
		
	var target_node = reference_scene.get_node_or_null("Container/Node2D")
	if target_node == null:
		push_error("Target node path not found")
		return
			
	print("Setting domino / equipment, type: ", get_type(), " reference: ", reference)
	if get_type() == reward_type.DOMINO:
		print("Setting domino", reference)
		target_node.set_type(reward_type.DOMINO)
		target_node.set_domino(reference, 0, false)
	elif get_type() == reward_type.EQUIPMENT:
		target_node.set_type(reward_type.EQUIPMENT)
		target_node.set_equipment(reference)

func _on_Button2_pressed():
	reference_scene.get_node("Container").visible = false
	Game.get_node("Game").player.add_gems(-reference.get_value())
	if(get_type() == reward_type.DOMINO):
		Game.get_node("Game").player.add_to_deck(reference, "player")
		print(reference, " added to deck")
	elif(get_type() == reward_type.EQUIPMENT):
		Game.get_node("Game").player.add_to_inventory(reference)
	set_reference(null)
	set_type(null)
	reference_scene.refresh_shop()
	


# Goes through all files in the Equipment and Domino/Attacks and Domino/Skills folders
# and returns the item with the matching name
# Utility method that is not used
func get_item_from_name(item_name: String):
	var item = null
	var item_type = null
	var item_path = "res://Equipment/" + item_name.replace(" ", "") + ".tscn"
	if File.new().file_exists(item_path):
		item = load(item_path).instance()
		item_type = "EQUIPMENT"
	else:
		item_path = "res://Domino/Attacks/" + item_name + ".tscn"
		if File.new().file_exists(item_path):
			item = load(item_path).instance()
			item_type = "DOMINO"
		else:
			item_path = "res://Domino/Skills/" + item_name + ".tscn"
			if File.new().file_exists(item_path):
				item = load(item_path).instance()
				item_type = "DOMINO"
	print("Item: ", item, "Type: ", item_type)
	return [item, item_type]

func refresh():
	if get_type() == null or reference == null:
		self.visible = false
		return

	if get_type() == reward_type.DOMINO:
		get_node("Information").text = reference.get_domino_name()
		
		# Grab domino numbers and corresponding texture
		var number1 = reference.get_numbers()[0]
		var number2 = reference.get_numbers()[1]

		# List of icon names based on numbers
		var icon_list = {
			-2: "res://Icons/-2Tile.png",
			-1: "res://Icons/-1Tile.png",
			0: "res://Icons/0Tile.png",
			1: "res://Icons/1Tile.png",
			2: "res://Icons/2Tile.png",
			3: "res://Icons/3Tile.png",
			4: "res://Icons/4Tile.png",
			5: "res://Icons/5Tile.png",
			6: "res://Icons/6Tile.png"
		}

		# Set the texture of the domino numbers
		get_node("TextureRect2").texture = load(icon_list[number1])
		get_node("TextureRect3").texture = load(icon_list[number2])
		self.visible = true
		
	elif get_type() == reward_type.EQUIPMENT:
		get_node("Information").text = reference.get_name()
		get_node("TextureRect").texture = load(reference.get_icon())
		self.visible = true
	else:
		push_error("Invalid type of reward")
		self.visible = false
		return

	# Check prices
	if(reference.get_value() > 0):
		get_node("CostText").bbcode_text = "[center]Buy " + str(reference.get_value()) + BBCode.bb_code_gem() + "[/center]"
	else:
		get_node("CostText").bbcode_text = "[center]Take[/center]"

	# Check if user can buy
	if(reference.get_value() > Game.get_node("Game").player.get_gems()):
		get_node("Button2").disabled = true
		# Change font if the user can't afford the item
		var disabled_font = load("res://Fonts/MicroRed.fnt")
		get_node("CostText").add_font_override("normal_font", disabled_font)
	else:
		get_node("Button2").disabled = false
		
		# Change font if the user can't afford the item
		var regular_font = load("res://Fonts/MicroWhite.fnt")
		get_node("CostText").add_font_override("normal_font", regular_font)
			

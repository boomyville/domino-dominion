extends Node

func _ready():
	# Create random items  
	# We will make a list of item names and then randomly select one
	# We will firstly go thru all equipment and add them if:
		# 1. criteria met
		# 2. player doesn't have one equipped or in inventory
		# 3. not cursed or event (this will be a criteria )
	# Then we will go thru all dominoes and add them if:
		# 1. criteria met
		# 2. player doesn't have one in deck and domino is not unique
		# 3. not event or blight (this will be a criteria )

	# We will also have a list of items that are not allowed to be added to the shop
	# Must be capitalised and no spaces
	var items_not_allowed = [""]
	var domino_list = []
	var equipment_list = []
	var consumables_list = []

	# Wait for a few frames to ensure player is loaded
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	
	# Iterate thru all files in equipment
	var equipment_path = "res://Equipment/"
	var equipment_files = Directory.new()
	var not_included = ["Equipment", "EquipmentContainer", "Status"]
	
	if equipment_files.open(equipment_path) == OK:
		equipment_files.list_dir_begin(true, true)  # Skip navigational and hidden files
		
		var file_name = equipment_files.get_next()
		while file_name != "":
			# Check if the file is a `.tscn` file
			if file_name.ends_with(".tscn") and  not file_name.replace(".tscn", "") in not_included:
				var full_path = equipment_path + "/" + file_name
				print("Loading: " + full_path)
				
				var equipment_scene = load(full_path)
				if equipment_scene:
					# Instance the Equip scene
					var equipment_instance = equipment_scene.instance()
					
					# Apply your filtering conditions

					# If item has some value and not cursed and not unique and not in items_not_allowed list and not in player's inventory or equipped 
					if(equipment_instance.get_value() > 0 and !(equipment_instance.is_unique()  and Game.get_node("Game").player.has_in_posession(equipment_instance.equipment_name)) and Game.get_node("Game").player.can_equip(equipment_instance) and !equipment_instance.is_cursed() and !items_not_allowed.has(equipment_instance.equipment_name.to_upper().replace(" ", ""))):
						# Add to shop
						# print("Adding equipment to shop: ", equipment_instance.get_name())
						if( equipment_instance.is_consumable()):
							consumables_list.append(equipment_instance)
						else:
							equipment_list.append(equipment_instance)

			file_name = equipment_files.get_next()  # Get the next file
		
		equipment_files.list_dir_end()  # End iteration
	else:
		print("Failed to open folder: res://Equipment")
		
	# Iterate thru all files in domino/attacks
	"""
	var domino_attacks_path = "res://Domino/Attacks/"
	var domino_attacks_files = Directory.new()
	domino_attacks_files.open(domino_attacks_path)
	domino_attacks_files.list_dir_begin(true, true)
	while true:
		var file = domino_attacks_files.get_next()
		if file == "":
			break
		if file.ends_with(".tscn"):
			var domino = load(domino_attacks_path + file).instance()
			# If item has some value and not in items_not_allowed list and not in player's stack and not unique
			if(!items_not_allowed.has(domino.domino_name.to_upper().replace(" ", "")) and !Game.get_node("Game").player.has_in_stack(domino.domino_name) and !domino.get_criteria().has("unique")):
				# Add to shop
				print("Adding domino to shop: ", domino.get_name())
				domino_list.append(domino)
	domino_attacks_files.list_dir_end()
	"""

	var domino_attacks_path = "res://Domino/Attack/"
	var domino_attacks_files = Directory.new()
	
	if domino_attacks_files.open(domino_attacks_path) == OK:
		domino_attacks_files.list_dir_begin(true, true)  # Skip navigational and hidden files
		
		var file_name = domino_attacks_files.get_next()
		while file_name != "":
			# Check if the file is a `.tscn` file
			if file_name.ends_with(".tscn"):
				var full_path = domino_attacks_path + "/" + file_name
				# print("Loading: " + full_path)
				
				var domino_scene = load(full_path)
				if domino_scene:
					# Instance the domino scene
					var domino_instance = domino_scene.instance()
					
					# Apply your filtering conditions
					if(!items_not_allowed.has(domino_instance.domino_name.to_upper().replace(" ", "")) and 
					   !Game.get_node("Game").player.has_in_stack(domino_instance.domino_name) and 
					   !domino_instance.get_criteria().has("unique") and !domino_instance.get_criteria().has("event")and !domino_instance.get_criteria().has("starter")):
						# print("Adding domino to shop: ", domino_instance.domino_name)
						domino_list.append(domino_instance)
			
			file_name = domino_attacks_files.get_next()  # Get the next file
		
		domino_attacks_files.list_dir_end()  # End iteration
	else:
		print("Failed to open folder: res://Domino/Attacks")


	# Iterate thru all files in domino/skills
	var domino_skills_path = "res://Domino/Skill/"
	var domino_skills_files = Directory.new()
	
	if domino_skills_files.open(domino_skills_path) == OK:
		domino_skills_files.list_dir_begin(true, true)  # Skip navigational and hidden files
		
		var file_name = domino_skills_files.get_next()
		while file_name != "":
			# Check if the file is a `.tscn` file
			if file_name.ends_with(".tscn"):
				var full_path = domino_skills_path + "/" + file_name
				# print("Loading: " + full_path)
				
				var domino_scene = load(full_path)
				if domino_scene:
					# Instance the domino scene
					var domino_instance = domino_scene.instance()
					
					# Apply your filtering conditions
					if(!items_not_allowed.has(domino_instance.domino_name.to_upper().replace(" ", "")) and 
					   !(Game.get_node("Game").player.has_in_stack(domino_instance.domino_name) and 
					   domino_instance.get_criteria().has("unique"))):
						# print("Adding domino to shop: ", domino_instance.domino_name)
						domino_list.append(domino_instance)
			
			file_name = domino_skills_files.get_next()  # Get the next file
		
		domino_skills_files.list_dir_end()  # End iteration
	else:
		print("Failed to open folder: res://Domino/Skills")

	# Randomly select 5 equipment and 5 dominoes
	randomize()
	equipment_list.shuffle()
	domino_list.shuffle()
	consumables_list.shuffle()

	print("Equipment: ", equipment_list.size(), " Dominoes: ", domino_list.size(), " Consumables: ", consumables_list.size())
	# Create shop items
	var random_equipment = equipment_list.slice(0, 4)
	var random_dominoes = domino_list.slice(0, 4)
	var random_consumable = consumables_list.slice(0, 4)
	
	var _i = 0
		
	for equip in random_equipment:
		var shop_item = get_node("GridContainer/" + "Container" + str(_i + 1))
		# Check node exists
		if(shop_item == null):
			push_error("ShopItem" + str(_i + 1) + " not found")
			return
		shop_item.create(equip, "EQUIPMENT")
		_i += 1
	
	for domino in random_dominoes:
		var shop_item = get_node("GridContainer/" + "Container" + str(_i + 1))
		# Check node exists
		if(shop_item == null):
			push_error("ShopItem" + str(_i + 1) + " not found")
			return
		print("Creating domino: ", domino.domino_name)
		shop_item.create(domino, "DOMINO")
		_i += 1

	for consumable in random_consumable:
		var shop_item = get_node("GridContainer/" + "Container" + str(_i + 1))
		# Check node exists
		if(shop_item == null):
			push_error("ShopItem" + str(_i + 1) + " not found")
			return
		shop_item.create(consumable, "EQUIPMENT")
		_i += 1

	refresh_shop()

func refresh_shop():
	for child in get_node("GridContainer").get_children():
		child.refresh()
	get_node("GemsText").bbcode_text = str(Game.get_node("Game").string_to_battler("player").get_gems()) + BBCode.bb_code_gem()


func _on_Status_pressed():
	var status_screen = preload("res://Equipment/Status.tscn").instance() 
	status_screen.get_node("Node2D").initialise()
	Game.get_node("Game").add_child(status_screen)


func _on_Next_pressed():
	destroy()
	Game.get_node("Game").player.reset_deck()
	Game.get_node("Game").next_event()


func _on_Stack_pressed():
	var library = preload("res://Reward/Library.tscn").instance() 
	library.clear()
	library.populate_deck()
	Game.get_node("Game").add_child(library)

func destroy():
	queue_free()

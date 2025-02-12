extends Node2D

var columns = 12  # Number of columns
var node_spacing_x = 72  # Horizontal spacing
var node_spacing_y = 48  # Vertical spacing
var start_x = 0  # X position for first column
var start_y = 240  # Centered Y position
var node_types = ["enemy", "heal", "event", "upgrade"]
var jitter = 12 # Randomization factor in terms of position of nodes

var all_nodes = []  # Stores nodes for each column
var connections = {}  # Stores connections as {from_node: [to_nodes]}
"""
func create_map_data(number_of_columns: int, starting_x: int, starting_y: int, padding_x: int, padding_y: int, padding_variance: int, guaranteed_heal_columns: Array, guaranteed_upgrade_columns: Array, guaranteed_enemy_columns: Array, guaranteed_boss_columns: Array) -> Array:
	var node_collection = []
	for col in range(number_of_columns):
		var nodes_in_column = 1 # Default value
		if (col < number_of_columns * 0.75) && (col > number_of_columns * 0.25):
			nodes_in_column = max(1, 9 - int(col / 2))
		elif col == 0:
			nodes_in_column = 1
		elif col == number_of_columns - 1:
			nodes_in_column = 1 + randi() % 2
		elif col <= number_of_columns * 0.25:
			nodes_in_column = col + 1
		elif number_of_columns >= number_of_columns * 0.75:
			nodes_in_column = max(1, int(number_of_columns - col))
		else:
			nodes_in_column = 1

		# nodes is a multi-dimensional array where first element is equal to column number and second element is another array of nodes
		var nodes = []        
		var has_heal = false
		var has_upgrade = false

		for i in range(nodes_in_column):
			var node_instance = preload("res://Event/MapNode.tscn").instance()
			var x = starting_x + col * padding_x + floor(randf() * padding_variance)  # Randomize X slightly
			var y = starting_y + (i - nodes_in_column / 2.0) * padding_y + floor(randf() * padding_variance)  # Randomize Y slightly
			node_instance.position = Vector2(x, y)

			# Determine node type
			var node_type = "enemy"  # Default

			if col in guaranteed_enemy_columns:
				node_type = "enemy"
			elif col in guaranteed_boss_columns:
				#node_type = "boss"
				pass
			elif col in guaranteed_heal_columns and randf() > 0.5:
				node_type = "heal"
				has_heal = true
			elif col in guaranteed_upgrade_columns and randf() > 0.5:
				node_type = "upgrade"
				has_upgrade = true
			else:
				node_type = "event" if randf() > 0.7 else "enemy"  # Assign remaining nodes

			node_instance.set_property(node_type)
			node_instance.set_column(col)

			#$Container.add_child(node_instance)
			nodes.append(node_instance)

			if i == nodes_in_column - 1 and col in guaranteed_heal_columns and has_heal == false:
				nodes[randi() % nodes.size()].set_property("heal")
				print("Heal node added to column: ", col)
			if i == nodes_in_column - 1 and col in guaranteed_upgrade_columns and has_upgrade == false:
				nodes[randi() % nodes.size()].set_property("upgrade")
				print("Upgrade node added to column: ", col)
		
		node_collection.append(nodes)

	# Now create connections
	var max_y_distance = 40  # Maximum allowed Y distance for connections
	for col in range(node_collection.size() - 1):
		var current_nodes = node_collection[col]
		var next_nodes = node_collection[col + 1]

		var connected_nodes = {}  # Track which nodes in the next column have at least one connection

		# Ensure each node in the next column has at least one incoming path
		for next_node in next_nodes:
			var closest_prev_node = get_closest_node(next_node, current_nodes)
			if closest_prev_node:
				create_connection(closest_prev_node, next_node)
				connected_nodes[next_node] = true  # Mark it as connected

		# Ensure each current node has at least one outgoing path
		for node in current_nodes:
			var valid_next_nodes = []

			# Find nodes within range
			for next_node in next_nodes:
				if abs(node.position.y - next_node.position.y) <= max_y_distance:
					valid_next_nodes.append(next_node)

			if valid_next_nodes.size() == 0:
				# No valid connections -> Force connection to the closest node
				var closest_node = get_closest_node(node, next_nodes)
				if closest_node:
					create_connection(node, closest_node)
			else:
				# Create 1 to 3 random connections within range
				var connections_count = randi() % 3 + 1
				for i in range(min(connections_count, valid_next_nodes.size())):
					var next_node = valid_next_nodes[randi() % valid_next_nodes.size()]
					create_connection(node, next_node)
	
	return node_collection 

func create_nodes():
	randomize()

	var first = [3, 4, 5, 6]
	var second = [7, 8, 9, 10]
	first.shuffle()
	second.shuffle()

	var guaranteed_heal_columns = [first[0], second[0]]  # Columns where we must place a heal
	var guaranteed_upgrade_columns = [first[1], second[1]]  # Columns where we must place an upgrade
	var guaranteed_enemy = [0]
	var guaranteed_boss = [columns - 1] # Not implemented!

	print ("Guaranteed heal columns: ", guaranteed_heal_columns, " | Guaranteed upgrade columns: ", guaranteed_upgrade_columns)

	for col in range(columns):
		var nodes_in_column = 1 # Default value
		if (col < columns * 0.75) && (col > columns * 0.25):
			nodes_in_column = max(1, 9 - int(col / 2))
		elif col == 0:
			nodes_in_column = 1
		elif col == columns - 1:
			nodes_in_column = 1 + randi() % 2
		elif col <= columns * 0.25:
			nodes_in_column = col + 1
		elif columns >= columns * 0.75:
			nodes_in_column = max(1, int(columns - col))
		else:
			nodes_in_column = 1

		var nodes = []        
		var has_heal = false
		var has_upgrade = false

		for i in range(nodes_in_column):
			var node_instance = preload("res://Event/MapNode.tscn").instance()
			var x = start_x + col * node_spacing_x + randf() * jitter  # Randomize X slightly
			var y = start_y + (i - nodes_in_column / 2.0) * node_spacing_y + randf() * jitter  # Randomize Y slightly
			node_instance.position = Vector2(x, y)

			# Determine node type
			var node_type = "enemy"  # Default

			if col in guaranteed_enemy:
				node_type = "enemy"
			elif col in guaranteed_boss:
				#node_type = "boss"
				pass
			elif col in guaranteed_heal_columns and randf() > 0.5:
				node_type = "heal"
				has_heal = true
			elif col in guaranteed_upgrade_columns and randf() > 0.5:
				node_type = "upgrade"
				has_upgrade = true
			else:
				node_type = "event" if randf() > 0.7 else "enemy"  # Assign remaining nodes

			node_instance.set_property(node_type)
			node_instance.set_column(col)

			#print("Column: ", col, " | Position: ", node_instance.position, " | Type: ", node_type)

			$Container.add_child(node_instance)
			nodes.append(node_instance)

			if i == nodes_in_column - 1 and col in guaranteed_heal_columns and has_heal == false:
				nodes[randi() % nodes.size()].set_property("heal")
				print("Heal node added to column: ", col)
			if i == nodes_in_column - 1 and col in guaranteed_upgrade_columns and has_upgrade == false:
				nodes[randi() % nodes.size()].set_property("upgrade")
				print("Upgrade node added to column: ", col)
	
		all_nodes.append(nodes)
	
	create_connections()
	print("Map created with", columns, "columns")
	Game.get_node("Game").store_map_data(all_nodes, connections, $Container.get_child(0).position)

func create_connections():
	var max_y_distance = 40  # Maximum allowed Y distance for connections

	for col in range(columns - 1):
		var current_nodes = all_nodes[col]
		var next_nodes = all_nodes[col + 1]

		var connected_nodes = {}  # Track which nodes in the next column have at least one connection

		# Ensure each node in the next column has at least one incoming path
		for next_node in next_nodes:
			var closest_prev_node = get_closest_node(next_node, current_nodes)
			if closest_prev_node:
				create_connection(closest_prev_node, next_node)
				connected_nodes[next_node] = true  # Mark it as connected

		# Ensure each current node has at least one outgoing path
		for node in current_nodes:
			var valid_next_nodes = []

			# Find nodes within range
			for next_node in next_nodes:
				if abs(node.position.y - next_node.position.y) <= max_y_distance:
					valid_next_nodes.append(next_node)

			if valid_next_nodes.size() == 0:
				# No valid connections -> Force connection to the closest node
				var closest_node = get_closest_node(node, next_nodes)
				if closest_node:
					create_connection(node, closest_node)
			else:
				# Create 1 to 3 random connections within range
				var connections_count = randi() % 3 + 1
				for i in range(min(connections_count, valid_next_nodes.size())):
					var next_node = valid_next_nodes[randi() % valid_next_nodes.size()]
					create_connection(node, next_node)

# Finds the closest node in a given set of nodes
func get_closest_node(current_node, node_list):
	var closest_node = null
	var min_distance = INF

	for node in node_list:
		var distance = abs(current_node.position.y - node.position.y)
		if distance < min_distance:
			closest_node = node
			min_distance = distance
	
	return closest_node

# Creates a connection and stores it
func create_connection(from_node, to_node):
	if not connections.has(from_node):
		connections[from_node] = []  # Ensure key exists

	if to_node in connections[from_node]:
		return  # Prevent duplicate connections
	
	connections[from_node].append(to_node)

	# Draw connection line
	var line = Line2D.new()
	line.add_point(from_node.position + Vector2(36, 16))
	line.add_point(to_node.position - Vector2(4, -16))
	line.width = 1
	$Container.add_child(line)
"""

#================================================================================
# Map save/load functions
#================================================================================
"""
func recreate_map(map_data: Dictionary, player_visited_nodes: Array):
	var current_level = Game.get_node("Game").current_level()  # Get the current column

	print("Recreating map with current level:", current_level, " and map data of: ", map_data)
	var last_player_pos
	if player_visited_nodes.size() > 0:
		last_player_pos = player_visited_nodes[-1]
		 
	# Clear existing nodes
	for child in $Container.get_children():
		child.queue_free()

	all_nodes.clear()
	connections.clear()

# Recreate nodes, but only show relevant ones
	for node_info in map_data["nodes"]:
		var col = node_info["column"]
		var node_pos = node_info["position"]
		var visible = false
		var active = true
		var visited = false

		# Make the last player node visible
		if node_pos == last_player_pos:
			visible = true
			active = false

		# Make connected nodes (and nodes 1 column ahead) visible
		if last_player_pos and str(last_player_pos) in map_data["connections"]:
			if str(node_pos) in map_data["connections"][str(last_player_pos)]:
				visible = true  # Show connected nodes
			elif col == current_level:  # Show nodes one column ahead
				visible = true
				active = true
			elif col == current_level + 1: # Show nodes two columns ahead but disable them
				visible = true
				active = false

		# If node is part of the previously visited nodes, enable visited sprite
		#print("Checking node at:", node_pos, " | Visited nodes:", map_data["player_path"])
		if node_pos in map_data["player_path"]:
			print("Node is visited")
			visited = true

		var node_instance = preload("res://Event/MapNode.tscn").instance()
		node_instance.position = node_pos
		node_instance.set_property(node_info["type"])
		node_instance.visible = visible  # Hide future nodes
		node_instance.set_visited(visited)	
		node_instance.set_active(active) 

		# Ensure the column exists in all_nodes
		if col >= all_nodes.size():
			all_nodes.resize(col + 1)
		if all_nodes[col] == null:
			all_nodes[col] = []

		all_nodes[col].append(node_instance)
		$Container.add_child(node_instance)

	# Recreate connections (only for visible nodes)
	for from_pos in map_data["connections"].keys():
		#print("From pos:", from_pos)
		var from_node = find_node_by_position(str_to_vector2(from_pos))
		if from_node and from_node.visible:  # Only show connections for visible nodes
			for to_pos in map_data["connections"][from_pos]:
				var to_node = find_node_by_position(str_to_vector2(to_pos))
				if to_node and to_node.visible:
					create_connection(from_node, to_node)
	
	#print("Map recreated with last player position:", last_player_pos, " | Current level:", current_level, " node: ", last_player_node)

func recreate_map(map_data: Dictionary, player_visited_nodes: Array):
    var current_level = Game.get_node("Game").current_level()  # Get current column
    print("Recreating map for level:", current_level, " | Map data:", map_data)

    var last_player_pos = null
    if player_visited_nodes.size() > 0:
        last_player_pos = player_visited_nodes[-1]

    # Clear existing nodes
    for child in $Container.get_children():
        child.queue_free()

    all_nodes.clear()
    connections.clear()

    # **Recreate Nodes**
    for col in range(map_data["nodes"].size()):
        var nodes_in_column = map_data["nodes"][col]
        var column_nodes = []

        for node_info in nodes_in_column:
            var node_pos = node_info.position
            var node_type = node_info.get_property()
            var visible = false
            var active = true
            var visited = node_pos in player_visited_nodes

            # **Determine Visibility & Activity**
            if node_pos == last_player_pos:
                visible = true
                active = false
            elif last_player_pos and last_player_pos in map_data["connections"]:
                var connected_positions = map_data["connections"][last_player_pos]
                if node_pos in connected_positions:
                    visible = true
                elif col == current_level:  # Show nodes one column ahead
                    visible = true
                    active = true
                elif col == current_level + 1:  # Show nodes two columns ahead (inactive)
                    visible = true
                    active = false

            # **Instantiate Node**
            var node_instance = preload("res://Event/MapNode.tscn").instance()
            node_instance.position = node_pos
            node_instance.set_property(node_type)
            node_instance.set_visited(visited)
            node_instance.set_active(active)
            node_instance.visible = visible

            column_nodes.append(node_instance)
            $Container.add_child(node_instance)

        all_nodes.append(column_nodes)

    # **Recreate Connections**
    for from_node in map_data["connections"].keys():
        var from_pos = from_node.position
        var from_instance = find_node_by_position(from_pos)

        if from_instance and from_instance.visible:
            for to_node in map_data["connections"][from_node]:
                var to_pos = to_node.position
                var to_instance = find_node_by_position(to_pos)

                if to_instance and to_instance.visible:
                    create_connection(from_instance, to_instance)

    print("Map successfully recreated | Last player position:", last_player_pos, " | Current level:", current_level)


func find_node_by_position(pos):
	for column in all_nodes:
		for node in column:
			#print("Checking node at:", node.position, " | Looking for:", pos)
			if node.position == pos:
				return node
	return null

func str_to_vector2(pos_str: String) -> Vector2:
	pos_str = pos_str.strip_edges().trim_prefix("(").trim_suffix(")")
	var parts = pos_str.split(", ")
	if parts.size() == 2:
		return Vector2(float(parts[0]), float(parts[1]))
	return Vector2.ZERO  # Default if parsing fails
"""


func recreate_map(map_data: Dictionary, player_travelled_nodes: Array):
	# Clear existing nodes
	for child in $Container.get_children():
		child.queue_free()

	# **Recreate Nodes**
	var node_instances = {}

	for col in range(map_data["nodes"].size()):
		for node_info in map_data["nodes"][col]:
			var node_instance = preload("res://Event/MapNode.tscn").instance()
			node_instance.position = node_info["position"]
			node_instance.set_property(node_info["type"])
			node_instance.set_active(false)

			# Determine if node is visible/active
			if node_info["id"] in player_travelled_nodes:
				node_instance.set_active(true)
			var found = false
			for id in node_info.get("connected_nodes", []):
				if id in player_travelled_nodes:
					found = true
					break
			if found:
				node_instance.set_active(true)

			# Store instance for connection drawing
			node_instances[node_info["id"]] = node_instance
			$Container.add_child(node_instance)

	# **Recreate Connections**
	for col in range(map_data["nodes"].size()):
		for node_info in map_data["nodes"][col]:
			if node_info["id"] in node_instances:
				var from_node = node_instances[node_info["id"]]
				for connected_id in node_info["connected_nodes"]:
					if connected_id in node_instances:
						var to_node = node_instances[connected_id]
						create_connection(from_node, to_node)

func create_connection(from_node, to_node):
	var line = Line2D.new()
	line.width = 2
	line.points = [from_node.position, to_node.position]
	line.default_color = Color(1, 1, 1, 0.5)  # Semi-transparent white
	$Container.add_child(line)
	
func destroy(clicked_node):
	for child in $Container.get_children():
		child.queue_free()
	all_nodes.clear()
	connections.clear()
	Game.get_node("Game").store_map_data(all_nodes, connections, clicked_node)
	queue_free()

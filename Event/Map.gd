extends Node2D

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
				node_instance.set_visited(true)
				if node_info["id"] == player_travelled_nodes[-1]:
					node_instance.set_active(true)
			else:
				node_instance.set_visited(false)


			if col > player_travelled_nodes.size() + 1:
				node_instance.set_visible(false)
			else:
				node_instance.set_visible(true)

			# Check if node is connected to last travelled node
			if player_travelled_nodes.size() > 0:
				if player_travelled_nodes[-1] in node_info["incoming_nodes"]:
					node_instance.set_active(true)
				else:
					node_instance.set_active(false)			

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
	line.default_color = Color(1, 1, 1, 0.5)  # Semi-transparent white
	
	var start_pos = from_node.position
	var end_pos = to_node.position
	
	# Calculate direction and shorten the line by 15% on each end
	var direction = (end_pos - start_pos).normalized()
	var shorten_amount = (end_pos - start_pos).length() * 0.15  # 15% of line length

	var new_start = start_pos + direction * shorten_amount
	var new_end = end_pos - direction * shorten_amount

	line.points = [new_start, new_end]
	$LinesContainer.add_child(line)

func get_node_id_by_position(target_position: Vector2) -> int:
	for column in Game.get_node("Game").map_data["nodes"]:
		for node in column:
			if node["position"].is_equal_approx(target_position):
				return node["id"]
	return -1  # Return -1 if no node is found

func destroy(clicked_node):
	for child in $Container.get_children():
		child.queue_free()
	Game.get_node("Game").player_visited_nodes.append(get_node_id_by_position(clicked_node.position))
	queue_free()

extends Node

var debug_console: TextEdit

func _ready():
	debug_console = $TextEdit  # Adjust the path to your TextEdit node
	debug_console.readonly = true
	DebugConsole.set_debug_console(debug_console)

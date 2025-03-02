extends Control

@onready var viewport = $CenterContainer/SubViewportContainer/SubViewport
var snake_game
var space_invaders
var active_game

func _ready():
	# Load both games
	snake_game = load("res://scenes/Snake/Snake.tscn").instantiate()
	space_invaders = load("res://scenes/SpaceInvaders/SpaceInvaders.tscn").instantiate()

	# Add both to the viewport
	viewport.add_child(snake_game)
	viewport.add_child(space_invaders)

	# Start with Space Invaders active and Snake paused
	_set_game_inactive(snake_game)
	_set_game_active(space_invaders)

func _input(event):
	if event.is_action_pressed("toggle_game"):
		_toggle_game()

func _set_game_active(game):
	active_game = game  # 🔥 Store active game
	game.set_process(true)
	game.set_physics_process(true)
	game.set_process_input(true)
	_toggle_visibility(game, true)  # 🔥 Show all nodes in the game

	# 🔥 Resume any timers in the game when reactivating
	_toggle_timers(game, true)

func _set_game_inactive(game):
	game.set_process(false)
	game.set_physics_process(false)
	game.set_process_input(false)
	_toggle_visibility(game, false)  # 🔥 Hide all nodes in the game

	# 🔥 Pause any timers in the game when deactivating
	_toggle_timers(game, false)

func _toggle_game():
	if active_game == space_invaders:
		_set_game_inactive(space_invaders)
		_set_game_active(snake_game)
	else:
		_set_game_inactive(snake_game)
		_set_game_active(space_invaders)

func _toggle_visibility(node, state):
	# 🔥 Only set visibility for nodes that have a 'visible' property
	if node.has_method("set_visible"):
		node.visible = state

	# Recursively process children
	for child in node.get_children():
		_toggle_visibility(child, state)

func _toggle_timers(node, active):
	# 🔥 Pause or resume all timers in the game
	for child in node.get_children():
		if child is Timer:
			child.paused = not active  # Pause timers when game is inactive
		else:
			_toggle_timers(child, active)  # Recursively apply to children

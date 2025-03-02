extends Control

@onready var viewport_container = $SubViewportContainer
@onready var viewport = $SubViewportContainer/SubViewport
@onready var border = $Border

var snake_game
var space_invaders
var active_game

const GAME_WIDTH = 1280
const GAME_HEIGHT = 960

func _ready():
	# Ensure UI updates properly
	_update_ui_layout()

	# Load both games
	snake_game = load("res://scenes/Snake/Snake.tscn").instantiate()
	space_invaders = load("res://scenes/SpaceInvaders/SpaceInvaders.tscn").instantiate()

	# Add both to the viewport
	viewport.add_child(snake_game)
	viewport.add_child(space_invaders)

	# Start with Space Invaders active and Snake paused
	_set_game_inactive(snake_game)
	_set_game_active(space_invaders)

	# Connect screen resizing
	get_tree().root.size_changed.connect(_update_ui_layout)

func _update_ui_layout():
	# 🔥 Get screen size dynamically
	var screen_size = get_viewport().get_visible_rect().size

	# 🔥 Manually center the viewport container
	viewport_container.position = (screen_size - Vector2(GAME_WIDTH, GAME_HEIGHT)) / 2

	# 🔥 Set border size and position
	border.position = viewport_container.position - Vector2(5, 5)  # Offset for border thickness
	border.size = Vector2(GAME_WIDTH + 10, GAME_HEIGHT + 10)  # Border wraps around

func _input(event):
	if event.is_action_pressed("toggle_game"):
		_toggle_game()

func _set_game_active(game):
	active_game = game
	game.set_process(true)
	game.set_physics_process(true)
	game.set_process_input(true)
	_toggle_visibility(game, true)
	_toggle_timers(game, true)

func _set_game_inactive(game):
	game.set_process(false)
	game.set_physics_process(false)
	game.set_process_input(false)
	_toggle_visibility(game, false)
	_toggle_timers(game, false)

func _toggle_game():
	if active_game == space_invaders:
		_set_game_inactive(space_invaders)
		_set_game_active(snake_game)
	else:
		_set_game_inactive(snake_game)
		_set_game_active(space_invaders)

func _toggle_visibility(node, state):
	if node.has_method("set_visible"):
		node.visible = state
	for child in node.get_children():
		_toggle_visibility(child, state)

func _toggle_timers(node, active):
	for child in node.get_children():
		if child is Timer:
			child.paused = not active
		else:
			_toggle_timers(child, active)

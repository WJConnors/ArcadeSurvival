extends Control

@onready	 var snake_game = preload("res://scenes/Snake/Snake.tscn").instantiate()
@onready var space_invaders = preload("res://scenes/SpaceInvaders/SpaceInvaders.tscn").instantiate()
@onready var shmup_game = preload("res://scenes/schmup/Schmup.tscn").instantiate()

@onready var viewport_container = $SubViewportContainer
@onready var viewport = $SubViewportContainer/SubViewport
@onready var border = $Border
@onready var vbox_container = $VBoxContainer  # 🔥 Ensure VBoxContainer is within UI
@onready var mult_label: Label = $VBoxContainer/MultLabel
@onready var point_label = $VBoxContainer/PointLabel  # 🔥 Points Label
@onready var countdown_bar = $VBoxContainer/ProgressBar  # 🔥 Countdown Timer
@onready var game_controller: Node = $GameController

var games = []  # Stores all game instances
var active_index = 0  # Tracks the active game index
var game_timer = Timer.new()  # 🔥 Countdown Timer

const GAME_WIDTH = 1280
const GAME_HEIGHT = 960
const GAME_DURATION = 60.0  # 🔥 3 minutes (180 seconds)

func _ready():
	add_to_group("main") 
	_update_ui_layout()

	# 🔥 Check if UI elements are properly found
	print("VBoxContainer: ", vbox_container)
	print("PointLabel: ", point_label)

	# Store in the games array
	games = [space_invaders, snake_game, shmup_game]

	# Add all games to the viewport
	for game in games:
		viewport.add_child(game)
		_set_game_inactive(game)  # Start all games as inactive

	# Start with Space Invaders active
	_set_game_active(games[active_index])

	# Setup countdown timer
	game_timer.wait_time = GAME_DURATION
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(game_timer)
	game_timer.start()

	# Setup progress bar
	countdown_bar.max_value = GAME_DURATION
	countdown_bar.value = GAME_DURATION

	# Connect screen resizing
	get_tree().root.size_changed.connect(_update_ui_layout)

func _update_ui_layout():
	var screen_size = get_viewport().get_visible_rect().size
	viewport_container.position = (screen_size - Vector2(GAME_WIDTH, GAME_HEIGHT)) / 2
	border.position = viewport_container.position - Vector2(5, 5)
	border.size = Vector2(GAME_WIDTH + 10, GAME_HEIGHT + 10)

func _input(event):
	if event.is_action_pressed("toggle_game"):
		_toggle_game()
		game_controller.game_switched()

func _set_game_active(game):
	game.set_process(true)
	game.set_physics_process(true)
	game.set_process_input(true)
	_toggle_visibility(game, true)
	_toggle_timers(game, true)
	_toggle_dynamic_objects(game, true)

func _set_game_inactive(game):
	game.set_process(false)
	game.set_physics_process(false)
	game.set_process_input(false)
	_toggle_visibility(game, false)
	_toggle_timers(game, false)
	_toggle_dynamic_objects(game, false)

func _toggle_game():
	_set_game_inactive(games[active_index])
	active_index = (active_index + 1) % games.size()
	_set_game_active(games[active_index])

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

func _toggle_dynamic_objects(game, active):
	var dynamic_container = game.get_node_or_null("DynamicObjects")
	if dynamic_container:
		for child in dynamic_container.get_children():
			if child is RigidBody2D or child is Node2D or child is Area2D:
				child.set_process(active)
				child.set_physics_process(active)
				child.set_process_input(active)
				child.visible = active  # 🔥 Hide objects when inactive

func _process(_delta):
	# 🔥 Update progress bar countdown
	countdown_bar.value = game_timer.time_left
	point_label.text = str(game_controller.score)
	mult_label.text = str(game_controller.mult)

func _on_game_timer_timeout():
	# 🔥 Stop all games when timer runs out
	print("Game Over!")
	for game in games:
		_set_game_inactive(game)

func reset_current_game():
	if active_index >= 0 and active_index < games.size():
		var game_to_reset = games[active_index]
		if game_to_reset and game_to_reset.get_parent():
			var parent = game_to_reset.get_parent()
			var new_game = load(game_to_reset.scene_file_path).instantiate()

			# Remove the current game from the viewport
			parent.remove_child(game_to_reset)
			game_to_reset.queue_free()

			# Add the new game instance
			parent.add_child(new_game)

			# Replace the reference in the games array
			games[active_index] = new_game

			# Reactivate the game
			_set_game_active(new_game)
			game_controller.game_lost()

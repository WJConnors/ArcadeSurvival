extends Node2D

@onready var enemy_scene = preload("res://scenes/SpaceInvaders/invader.tscn")  # Load enemy scene
@onready var enemy_container = $EnemyContainer  # Holds all enemies
@onready var move_timer = $MoveTimer  # Timer for moving rows down
@onready var wave_timer: Timer = $WaveTimer
@onready var wave_check_timer = Timer.new()  # 🔥 Small delay timer

const GAME_WIDTH := 1280
const GAME_HEIGHT := 960
const INVADER_SIZE := 96
const INVADER_COLUMNS := 6
const INVADER_ROWS := 3
const INVADER_SPACING := 24
const MOVE_SPEED := 50.0
const MOVE_DOWN_AMOUNT := 48  # 🔥 Moves each new wave down by one row
const ROW_MOVE_DELAY := 0.1  # 🔥 Delay for moving each row

var move_direction := 1  # 1 = right, -1 = left
var move_timer_counter := 0.0
var reverse = false
var pending_rows = []  # Stores rows that need to move
var wave_y_offset := 100  # 🔥 Keeps track of the Y position for each new wave

func _ready():
	move_timer.wait_time = ROW_MOVE_DELAY
	move_timer.one_shot = true
	_spawn_enemy_wave()

	# 🔥 Connect signals to detect when enemies are removed and timer finishes
	enemy_container.child_exiting_tree.connect(_on_enemy_removed)
	wave_timer.timeout.connect(_on_wave_timer_timeout)  # 🔥 Now we listen for the timer ending!

	# 🔥 Add a small delay timer for checking wave spawns
	wave_check_timer.wait_time = 0.01  # Ensures all enemies are fully removed
	wave_check_timer.one_shot = true
	wave_check_timer.timeout.connect(_check_for_wave_spawn)
	add_child(wave_check_timer)

func _process(delta):
	move_timer_counter += delta
	if move_timer_counter >= 0.5 and not reverse:  # Adjust movement speed timing
		_check_enemy_movement()
		move_timer_counter = 0.0

func _spawn_enemy_wave():
	var total_invader_width = (INVADER_COLUMNS * INVADER_SIZE) + ((INVADER_COLUMNS - 1) * INVADER_SPACING)
	var start_x = (GAME_WIDTH - total_invader_width) / 2

	for row in range(INVADER_ROWS):
		for col in range(INVADER_COLUMNS):
			var enemy = enemy_scene.instantiate()
			enemy.position = Vector2(
				start_x + col * (INVADER_SIZE + INVADER_SPACING),
				wave_y_offset + (row * (INVADER_SIZE + INVADER_SPACING))
			)
			enemy_container.add_child(enemy)

	# 🔥 Move the next wave one row down
	wave_y_offset += MOVE_DOWN_AMOUNT

func _on_enemy_removed(_enemy):  # 🔥 Accepts the exiting node but ignores it
	# 🔥 Start a small delay timer to ensure all enemies are fully removed
	if wave_check_timer.is_stopped():
		wave_check_timer.start()

func _check_for_wave_spawn():
	if enemy_container.get_child_count() == 0:
		print("timer started")  # Debugging print
		wave_timer.start()  # 🔥 Start the wave timer when all enemies are removed

func _on_wave_timer_timeout():  # 🔥 This runs when the timer finishes
	print("timer ended")  # Debugging print
	_spawn_enemy_wave()  # Spawn the new wave

func _check_enemy_movement():
	if reverse:
		return  # 🔥 Prevents X movement while reversing

	var leftmost_x = INF
	var rightmost_x = -INF

	# 🔥 Check future movement step **before** moving, ensuring enemies still exist
	for enemy in enemy_container.get_children():
		if enemy == null or not is_instance_valid(enemy):  # 🔥 Ensure the enemy is valid
			continue  # Skip if enemy was already freed

		var next_x = enemy.position.x + (MOVE_SPEED * move_direction)
		if next_x < leftmost_x:
			leftmost_x = next_x
		if next_x > rightmost_x:
			rightmost_x = next_x

	# 🔥 Adjust reversal conditions so enemies stay fully inside screen
	if leftmost_x <= INVADER_SIZE / 2 or rightmost_x >= GAME_WIDTH - INVADER_SIZE / 2:
		reverse = true
		move_direction *= -1
		_prepare_row_movement()
		return  # Stop movement this frame

	# 🔥 Only move if no reversal was triggered
	for enemy in enemy_container.get_children():
		if enemy == null or not is_instance_valid(enemy):  # 🔥 Ensure the enemy is valid
			continue  # Skip if enemy was already freed
		enemy.position.x += MOVE_SPEED * move_direction

func _prepare_row_movement():
	pending_rows = get_rows_from_bottom()  # Get rows from bottom to top
	if pending_rows.size() > 0:
		move_timer.connect("timeout", Callable(self, "_move_next_row"))
		move_timer.start()

func _move_next_row():
	if pending_rows.size() > 0:
		var row = pending_rows.pop_front()  # 🔥 Moves the bottom row first
		for enemy in row:
			if enemy == null or not is_instance_valid(enemy):  # 🔥 Ensure the enemy is valid
				continue  # Skip if enemy was already freed
			enemy.position.y += MOVE_DOWN_AMOUNT

		if pending_rows.size() > 0:
			move_timer.start()  # Continue moving next row after 0.1s
		else:
			move_timer.disconnect("timeout", Callable(self, "_move_next_row"))
			reverse = false  # ✅ Reset reverse once all rows move

func get_rows_from_bottom():
	var enemies = enemy_container.get_children()
	var row_groups = {}

	# Group enemies by Y position
	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):  # 🔥 Ensure the enemy is valid
			continue  # Skip if enemy was already freed

		var row_y = enemy.position.y
		if row_y not in row_groups:
			row_groups[row_y] = []
		row_groups[row_y].append(enemy)

	# Sort rows from highest Y (bottom row) to lowest Y (top row)
	var sorted_rows = row_groups.keys()
	sorted_rows.sort_custom(func(a, b): return a > b)  # 🔥 Ensure bottom row is first

	# Return a list of rows, each containing a list of enemies
	var ordered_rows = []
	for y in sorted_rows:
		ordered_rows.append(row_groups[y])

	return ordered_rows  # Bottom row is now first

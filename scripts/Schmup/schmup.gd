extends Node2D

@export var asteroid_scene: PackedScene
@export var point_scene: PackedScene
@export var spawn_rate := 1.0
@export var spawn_distance := 100

const SCREEN_WIDTH := 1280
const SCREEN_HEIGHT := 960

@onready var spawn_timer = $AsteroidTimer
@onready var points_timer = $PointsTimer
@onready var dynamic_objects = $DynamicObjects

func _ready():
	# Start spawning asteroids
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(spawn_asteroid)
	spawn_timer.start()

	# Start spawning points
	points_timer.wait_time = spawn_rate * 2  # Spawn points at half the asteroid rate
	points_timer.timeout.connect(spawn_point)
	points_timer.start()

func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	var spawn_pos = _get_random_spawn_position()

	asteroid.position = spawn_pos
	asteroid.direction = (Vector2(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2) - spawn_pos).normalized()

	# 🔥 Add to DynamicObjects so it can be paused properly
	dynamic_objects.add_child(asteroid)

func spawn_point():
	var point = point_scene.instantiate()
	point.position = Vector2(randf_range(50, SCREEN_WIDTH - 50), randf_range(50, SCREEN_HEIGHT - 50))
	dynamic_objects.add_child(point)

func _get_random_spawn_position():
	var side = randi() % 4  # 0 = top, 1 = bottom, 2 = left, 3 = right
	match side:
		0: return Vector2(randf_range(0, SCREEN_WIDTH), -spawn_distance)  # Top
		1: return Vector2(randf_range(0, SCREEN_WIDTH), SCREEN_HEIGHT + spawn_distance)  # Bottom
		2: return Vector2(-spawn_distance, randf_range(0, SCREEN_HEIGHT))  # Left
		3: return Vector2(SCREEN_WIDTH + spawn_distance, randf_range(0, SCREEN_HEIGHT))  # Right
	return Vector2.ZERO

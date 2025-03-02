extends Node2D

@export var asteroid_scene: PackedScene  # Drag in `asteroid.tscn`
@export var spawn_rate := 1.0  # Seconds between spawns
@export var spawn_distance := 100  # Distance outside screen to spawn

const SCREEN_WIDTH := 1280
const SCREEN_HEIGHT := 960

func _ready():
	# Start spawning asteroids
	$SpawnTimer.wait_time = spawn_rate
	$SpawnTimer.start()
	
func _on_spawn_timer_timeout() -> void:
	spawn_asteroid()


func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()

	# Randomly choose a spawn position **outside** the screen
	var side = randi() % 4  # 0 = top, 1 = bottom, 2 = left, 3 = right
	var spawn_pos = Vector2.ZERO

	match side:
		0: spawn_pos = Vector2(randf_range(0, SCREEN_WIDTH), -spawn_distance)  # Top
		1: spawn_pos = Vector2(randf_range(0, SCREEN_WIDTH), SCREEN_HEIGHT + spawn_distance)  # Bottom
		2: spawn_pos = Vector2(-spawn_distance, randf_range(0, SCREEN_HEIGHT))  # Left
		3: spawn_pos = Vector2(SCREEN_WIDTH + spawn_distance, randf_range(0, SCREEN_HEIGHT))  # Right

	asteroid.position = spawn_pos

	# Set movement direction toward the center
	var center = Vector2(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
	asteroid.direction = (center - spawn_pos).normalized()

	# Add asteroid to the scene
	get_parent().add_child(asteroid)

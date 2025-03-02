extends Area2D  # Or RigidBody2D if using physics

@export var speed := 200.0  # Adjust asteroid speed
var direction := Vector2.ZERO  # Movement direction

func _ready():
	# Randomize asteroid direction slightly
	direction = direction.normalized()

func _process(delta):
	# Move asteroid
	position += direction * speed * delta

	# Remove asteroid if it's far off-screen
	if position.x < -100 or position.x > 1380 or position.y < -100 or position.y > 1060:
		queue_free()

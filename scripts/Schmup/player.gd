extends CharacterBody2D  # 🚀 Best for movement with collisions

@export var speed := 300.0  # 🔥 Movement speed (adjust as needed)

const SCREEN_WIDTH := 1280
const SCREEN_HEIGHT := 960

func _process(_delta):
	# Get input direction
	var direction := Vector2.ZERO
	if Input.is_action_pressed("sm_up"):
		direction.y -= 1
	if Input.is_action_pressed("sm_down"):
		direction.y += 1
	if Input.is_action_pressed("sm_left"):
		direction.x -= 1
	if Input.is_action_pressed("sm_right"):
		direction.x += 1

	# Normalize diagonal movement speed
	if direction.length() > 0:
		direction = direction.normalized()

	# Apply movement
	velocity = direction * speed
	move_and_slide()

	# Keep player inside screen bounds
	position.x = clamp(position.x, 64, SCREEN_WIDTH - 64)  # 🚀 Adjust based on ship size
	position.y = clamp(position.y, 32, SCREEN_HEIGHT - 32)

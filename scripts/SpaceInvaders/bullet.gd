extends Area2D

@export var speed := 400.0  # Bullet speed
@export var direction := Vector2(0, -1)  # Default: Upward movement

func _ready():
	add_to_group("bullets") 

func _process(delta):
	position += direction * speed * delta  # Move the bullet

	# Remove bullet if it leaves the screen
	if position.y < -10 or position.y > get_viewport_rect().size.y + 10:
		queue_free()

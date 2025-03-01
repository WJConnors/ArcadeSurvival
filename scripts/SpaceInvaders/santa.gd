extends CharacterBody2D

@export var speed := 300.0
@onready var anim_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D
@onready var bullet_scene = preload("res://scenes/SpaceInvaders/bullet.tscn")
@onready var timer: Timer = $Timer

var lastDir: bool = true

func _process(_delta):
	var direction = Input.get_axis("si_left", "si_right")  # Left/Right movement
	velocity.x = direction * speed  # Set movement speed

	move_and_slide()  # Move the player
	
		# Lock the player within the 1280x960 window
	var screen_width = 1280  # Set your screen width
	var player_width = 128  # Half-width for centering

	position.x = clamp(position.x, player_width, screen_width - player_width)

	# Play animations based on movement
	if direction == -1:
		anim_sprite.play("left")
		lastDir = false
	elif direction == 1:
		anim_sprite.flip_h = false
		anim_sprite.play("right")
		lastDir = true
	else:
		anim_sprite.play("idle")
		if lastDir:
			anim_sprite.flip_h = false
		else:
			anim_sprite.flip_h = true

	if Input.is_action_just_pressed("si_shoot") and timer.is_stopped():
		shoot()
		timer.start()  # Start cooldown timer

func shoot():
	var bullet = bullet_scene.instantiate()  # Create an instance of the bullet
	bullet.position = global_position + Vector2(0, -20)  # Spawn slightly above player
	get_parent().add_child(bullet)  # Add bullet to the scene

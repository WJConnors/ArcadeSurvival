extends Node2D

const GRID_SIZE := 64  # Matches grid cell size
const GRID_WIDTH := 20
const GRID_HEIGHT := 15

@export var apple_texture: Texture2D  # 🔥 Assign your apple image in the Inspector

var position_grid := Vector2.ZERO  # Food position in grid coordinates
var sprite: Sprite2D  # Apple sprite

func _ready():
	sprite = Sprite2D.new()
	sprite.texture = apple_texture  # 🔥 Use the apple texture
	sprite.scale = Vector2(2, 2)  # 🔥 Doubles size (32x32 → 64x64)
	sprite.centered = false  # Align with grid position
	add_child(sprite)

	spawn_food()

func spawn_food():
	# Pick a random position inside the grid
	var x = randi_range(0, GRID_WIDTH - 1)
	var y = randi_range(0, GRID_HEIGHT - 1)
	position_grid = Vector2(x, y)

	# Set the food position
	position = position_grid * GRID_SIZE

extends Node2D

const GRID_SIZE := 64  # Matches grid cell size
const GRID_WIDTH := 20
const GRID_HEIGHT := 15

var position_grid := Vector2.ZERO  # Food position in grid coordinates

func _ready():
	spawn_food()

func spawn_food():
	# Pick a random position inside the grid
	var x = randi_range(0, GRID_WIDTH - 1)
	var y = randi_range(0, GRID_HEIGHT - 1)
	position_grid = Vector2(x, y)

	# Set the food position
	position = position_grid * GRID_SIZE

	# Draw the food as a red square
	_draw_food()

func _draw_food():
	# Remove old food visuals
	for child in get_children():
		child.queue_free()

	# Create a red square for food
	var rect = ColorRect.new()
	rect.color = Color.RED
	rect.size = Vector2(GRID_SIZE, GRID_SIZE)
	add_child(rect)

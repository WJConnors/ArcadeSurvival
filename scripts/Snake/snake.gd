extends Node2D

@onready var snake = $Char  # Reference to the Snake Node
@onready var food = $Food  # Reference to the Food Node
@onready var move_timer = $MoveTimer  # Timer for movement

const GRID_SIZE := 64  # Matches grid cell size
const GRID_WIDTH := 20  # Number of columns
const GRID_HEIGHT := 15  # Number of rows

func _ready():
	# Set up the movement timer
	move_timer.wait_time = 0.2  # Adjust for snake speed
	move_timer.one_shot = false
	move_timer.timeout.connect(_on_move_timer_timeout)
	move_timer.start()

	# Start the game
	snake.init_snake()
	food.spawn_food()

func _on_move_timer_timeout():
	snake.move()

	# Check if snake's head touches food
	if snake.body[0] == food.position_grid:
		snake.grow()  # Snake grows
		food.spawn_food()  # Respawn food

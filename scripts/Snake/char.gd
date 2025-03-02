extends Node2D

const GRID_SIZE := 64  # Matches grid cell size

var direction := Vector2.RIGHT  # Default movement direction
var body := []  # Stores snake's body positions (grid coordinates)
var growing := false  # Controls if the snake grows

func init_snake():
	# Initialize snake at the center of the grid
	var start_x = 10  # Center column (1280 / 32 / 2)
	var start_y = 7  # Center row (960 / 32 / 2)
	body = [Vector2(start_x, start_y)]  # Snake starts as a single block

	# Draw the snake on screen
	_update_snake_visuals()

func _input(event):
	if event.is_action_pressed("s_up") and direction != Vector2.DOWN:
		direction = Vector2.UP
	elif event.is_action_pressed("s_down") and direction != Vector2.UP:
		direction = Vector2.DOWN
	elif event.is_action_pressed("s_left") and direction != Vector2.RIGHT:
		direction = Vector2.LEFT
	elif event.is_action_pressed("s_right") and direction != Vector2.LEFT:
		direction = Vector2.RIGHT

func move():
	# Move the snake by adding a new head in the movement direction
	var new_head = body[0] + direction
	body.push_front(new_head)  # Add new head

	# Remove the last segment unless growing
	if not growing:
		body.pop_back()
	else:
		growing = false  # Reset growth after one frame

	_update_snake_visuals()

func _update_snake_visuals():
	# Remove old visuals
	for child in get_children():
		child.queue_free()

	# Draw each snake segment as a black square
	for i in range(body.size()):
		var rect = ColorRect.new()
		rect.size = Vector2(GRID_SIZE, GRID_SIZE)
		rect.position = body[i] * GRID_SIZE

		# Head is slightly different from body
		if i == 0:
			rect.color = Color.WHITE  # Head (White)
		else:
			rect.color = Color.BLACK  # Body (Black)

		add_child(rect)

func grow():
	growing = true  # Snake will grow on the next move
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	game_controller.add_score(1)

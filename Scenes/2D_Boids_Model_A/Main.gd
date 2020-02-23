extends Node2D

export var boid_prototype: PackedScene

var boids: Array = []
var grid: Dictionary = {}
var grid_size := 100
var window_width = ProjectSettings.get_setting("display/window/size/width")
var window_height = ProjectSettings.get_setting("display/window/size/height")

var showPartition = false


func _ready():
	randomize()
	
	for x in range(-2, 2 + (window_width+100) / grid_size):
		grid[x] = {}
		for y in range(-2, 2 + (window_height+100) / grid_size):
			grid[x][y] = []
	
	for i in range(200):
		var b:Boid2D = boid_prototype.instance()
		
		if i == 0:
			b.debug_mode = true
		
		b.position = Vector2(rand_range(0,window_width), rand_range(0,window_height))
		b.linear_velocity = Vector2.ONE.rotated(rand_range(0, PI*2)) * 100
		b.vision_dist = grid_size
		
		add_child(b)
		
		var x = int(b.position.x/grid_size)
		var y = int(b.position.y/grid_size)
		grid[x][y].append(b)
		boids.append(b)


func _physics_process(delta):
	for x in grid.keys():
		for y in grid[x].keys():
			grid[x][y].clear()
	
	for b in boids:
		var x = int(b.position.x/grid_size)
		var y = int(b.position.y/grid_size)
		grid[x][y].append(b)
	
	for b in boids:
		var x = int(b.position.x/grid_size)
		var y = int(b.position.y/grid_size)
		
		var neighbours = []
		for i in range(-1,2):
			for k in range(-1,2):
				neighbours += grid[x+i][y+k]
		
		b.behave(neighbours)


func _process(delta):
	update()
	
	if Input.is_key_pressed(KEY_Z):
		showPartition = true
	else:
		showPartition = false
	
	if Input.is_key_pressed(KEY_SPACE):
		get_tree().reload_current_scene()
	
	if Input.is_key_pressed(KEY_RIGHT):
		for b in boids:
			b.vision_radius = clamp(b.vision_radius+1, 0, 360)
			
	if Input.is_key_pressed(KEY_LEFT):
		for b in boids:
			b.vision_radius = clamp(b.vision_radius-1, 0, 360)


func _draw():
	if showPartition:
		for x in grid.keys():
			for y in grid[x].keys():
				var alpha = range_lerp(grid[x][y].size(),0, 10, 0, 1)
				alpha = clamp(alpha, 0, 1)
				
				draw_rect(
					Rect2(x*grid_size, y*grid_size, grid_size, grid_size), 
					Color(1, 0.2, 0.2, alpha))

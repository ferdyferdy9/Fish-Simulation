extends Node2D

export var boid_prototype: PackedScene

var boids: Array = []
var window_width = ProjectSettings.get_setting("display/window/size/width")
var window_height = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	for _i in range(50):
		var b = boid_prototype.instance()
		
		b.position = Vector2(rand_range(0,window_width), rand_range(0,window_height))
		b.linear_velocity = Vector2(100,10)
		b.linear_velocity = Vector2.ONE.rotated(rand_range(0, PI*2)) * 100
		
		add_child(b)
		boids.append(b)


func _physics_process(delta):

	
	if Input.is_key_pressed(KEY_SPACE):
		get_tree().reload_current_scene()
	
	if Input.is_key_pressed(KEY_RIGHT):
		for b in boids:
			b.vision_radius += 1
			
	if Input.is_key_pressed(KEY_LEFT):
		for b in boids:
			b.vision_radius -= 1

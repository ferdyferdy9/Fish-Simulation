extends Node2D

export var max_speed:float = 8
export var max_force:float = 0.2
export var vision_dist: float = 200
export var vision_radius: float = 270
export var debug_mode: bool = true

var friends
var linear_velocity:Vector2
var total_force: Vector2
var noise := OpenSimplexNoise.new()
var noiseX: float


func _ready():
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8

func _physics_process(delta):
	rotation = atan2(linear_velocity.y, linear_velocity.x)
	
	#total_force += 0.5*wander()
	total_force += 0.5*seperate(friends)
	
	apply_force(delta)
	
	update()


func checkVisionTrigger(target: Vector2) -> bool:
	var angle = atan2(target.y - position.y, target.x - position.x)
	return ((position - target).length() < vision_dist and abs(angle-rotation) < deg2rad(vision_radius*0.5))


func seek(target: Vector2):
	var desired := target - position
	desired = desired.normalized() * max_speed
	
	var force := desired - linear_velocity
	if force.length() > max_force:
		force = force.normalized() * max_force
	
	return force


func seperate(group: Array):
	var total_desire: Vector2
	
	for f in friends:
		if f == self:
			continue
		
		if checkVisionTrigger(f.position):
			var desired = position - f.position
			desired = desired.normalized() * range_lerp(desired.length(), 0, vision_dist, max_speed, 0)
			total_desire += desired
	
	var force: Vector2
	
	force = total_desire
	if force.length() > max_force:
		force = force.normalized() * max_force
	
	return force


func wander():
	var angle = range_lerp(noise.get_noise_1d(noiseX), 0, 1, 0, PI*2)
	var force = seek(position + Vector2(max_speed,0).rotated(angle))
	noiseX += 0.001
	
	return force


func apply_force(delta):
	linear_velocity += total_force
	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	position += linear_velocity
	total_force.x = 0
	total_force.y = 0


func _draw():
	if debug_mode:
		draw_circle_arc_poly(
			Vector2(), vision_dist, 
			90-vision_radius*0.5, 
			90+vision_radius*0.5,
			Color(1,1,1,0.1))


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

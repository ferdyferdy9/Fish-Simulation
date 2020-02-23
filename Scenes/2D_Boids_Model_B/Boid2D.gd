extends RigidBody2D

class_name Boid2D

export var max_speed:float = 800
export var max_force:float = 80
export var debug_mode:bool = false

var vision_dist: float
var vision_radius: float = 100
var window_width = ProjectSettings.get_setting("display/window/size/width")
var window_height = ProjectSettings.get_setting("display/window/size/height")\

onready var sprite: Sprite = $Sprite

func _ready():
	pass


func _process(_delta):
	sprite.rotation = atan2(linear_velocity.y, linear_velocity.x)
	
	update()


func _integrate_forces(state):
	if position.x < -50:
		state.transform = Transform2D(0, Vector2(window_width+50, state.transform.get_origin().y))
		position.x = window_width+50
	if position.x > window_width+50:
		state.transform = Transform2D(0, Vector2(-50, state.transform.get_origin().y))
		position.x = -50
	if position.y < -50:
		state.transform = Transform2D(0, Vector2(state.transform.get_origin().x, window_height+50))
		position.y = window_height+50
	if position.y > window_height+50:
		state.transform = Transform2D(0, Vector2(state.transform.get_origin().x, -50))
		position.y = -50


func behave(friends: Array):
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	var close_friends = []
	for f in friends:
		if checkVisionTrigger(f.position, vision_dist):
			close_friends.append(f)
	
	var too_close_friends = []
	for f in close_friends:
		if (position - f.position).length() < vision_dist*0.5:
			too_close_friends.append(f)
	
	var forces: Array = []
	forces.append(0.1*keep_going())
	forces.append(1.25*seperate(too_close_friends))
	forces.append(align(close_friends))
	forces.append(cohesion(close_friends))
	
	apply_force(forces)


func apply_force(forces):
	var total := Vector2()
	
	for f in forces:
		total += f
	total /= forces.size()
	
	linear_velocity += total
	

func checkVisionTrigger(target: Vector2, dist: float) -> bool:
	var angle = atan2(target.y - position.y, target.x - position.x)
	return ((position - target).length() < dist and abs(angle-rotation) < deg2rad(vision_radius*0.5))


func keep_going():
	var desire := linear_velocity.normalized() * max_speed
	var force := desire - linear_velocity
	if force.length_squared() > max_force*max_force:
		force = force.normalized() * max_force
	
	return force


func seek(target: Vector2):
	var desired := target - position
	desired = desired.normalized() * max_speed
	
	var force := desired - linear_velocity
	if force.length() > max_force:
		force = force.normalized() * max_force
	
	return force


func seperate(group: Array):
	var total_desire := Vector2()
	var count = 0
	
	for f in group:
		if f == self:
			continue
		
		var desired = position - f.position
		total_desire += desired.normalized()
		count += 1
	
	var force := Vector2()
	
	if count > 0:
		force = total_desire*max_speed/count
		if force.length_squared() > max_force*max_force:
			force = force.normalized() * max_force
	
	return force


func align(group: Array):
	var total_desire := Vector2()
	var count = 0
	
	for f in group:
		if f == self:
			continue
		
		total_desire += f.linear_velocity.normalized()
		count += 1
	
	var force := Vector2()
	
	if count > 0:
		force = total_desire*max_speed/count - linear_velocity
		if force.length_squared() > max_force*max_force:
			force = force.normalized() * max_force
	
	return force


func cohesion(group: Array):
	var desired_pos := Vector2()
	var count = 0
	
	for f in group:
		if f == self:
			continue
		
		desired_pos += f.position
		count += 1
	
	var force := Vector2()
	
	if count > 0:
		force = seek(desired_pos/count)
		if force.length_squared() > max_force*max_force:
			force = force.normalized() * max_force
	
	return force


func _draw():
	if debug_mode:
		draw_line(Vector2(), linear_velocity*0.15, Color.white)
		draw_circle_arc_poly(
			Vector2(), vision_dist, 
			sprite.rotation_degrees+90-vision_radius*0.5, 
			sprite.rotation_degrees+90+vision_radius*0.5,
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

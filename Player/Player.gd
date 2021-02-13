extends KinematicBody2D

const GRAVITY = 3000
const ROTATION_SPEED = 7
const JUMP_HEIGHT = -550

var motion = Vector2()
var jump = -1
var fastfall = 0
var last_speed = 0
var landfall = 0
var friction = false

var multiplier = .8

var original_position = Vector2(-1023, -1023)

var win_x = 0

slave var slave_multiplier = .8

slave var slave_position = Vector2()
slave var slave_rotation = 0

func _ready():
	pass # Replace with function body

func _physics_process(delta):
	
	if original_position == Vector2(-1023, -1023):
		original_position = position
	
	if position.x > win_x:
		print(position.x)
	
	motion.y += (GRAVITY + fastfall) * delta

	if friction:
		if rotation < -PI/1.97:
			rotation += 10 * delta
		elif rotation > PI/1.97:
			rotation -= 10 * delta
		motion.x += sign(motion.x) * -200 * delta
		
	if jump < 0:
		jump -= delta
		$animation.play("air")
		fastfall = 0
		if is_network_master():
			$Camera2D.current = true
			if(jump < -.1):
				if Input.is_action_pressed("ui_right"):
					rotation += ROTATION_SPEED * delta
				elif Input.is_action_pressed("ui_left"):
					rotation -= ROTATION_SPEED * delta
				elif Input.is_action_pressed("ui_down"):
					fastfall = 2000
			
			last_speed = sqrt(motion.x*motion.x + motion.y*motion.y)
			motion = move_and_slide(motion)
			rset('slave_position', position)
			rset('slave_rotation', rotation)

		else:
			last_speed = sqrt(motion.x*motion.x + motion.y*motion.y)
			motion = move_and_slide(motion)
			position = slave_position
			rotation = slave_rotation

		if(jump < -.3):
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				var diff = position - collision.position
				#if the distance is more than 60 pixels, then we know it's the tip 
				if sqrt(diff.x*diff.x + diff.y*diff.y) > 50:
					#jump here
					jump = .2
					friction = false
					if is_network_master():
						slave_multiplier = .6
						
						rset('slave_multiplier', .6)
					
				else:
					friction = true			
	else:	
		$animation.play("jump")
		jump -= delta
	
		if(is_network_master()):
			#print("asldkf;laks")
			if jump < .15 and jump > 0 and Input.is_action_just_pressed("ui_jump"):
				#print("ooooooooooooooo")
				slave_multiplier = .8
				rset('slave_multiplier', .8)

		#else:
			#multiplier = slave_multiplier
		
		if jump <= 0:
			motion = Vector2(0, -600 - last_speed * slave_multiplier).rotated(rotation)
			#if slave_multiplier == .8:
				#rpc("cloud_anim", $cloud_spawn.global_position, rotation)

		
func init(nickname, start_position, is_slave):
	global_position = start_position
	
func set_dominant_color(color):
	$animation.modulate = color

			
			
func _on_ghost_timer_timeout():
	#if jump < 0 and jump > -.5:
		#print(slave_multiplier)
		
	if jump < 0 and jump > -.5 and slave_multiplier == .8:
		rpc("ghost_spawn", position, rotation, $animation.frames.get_frame($animation.animation, $animation.frame))

		
		
remotesync func ghost_spawn(pos, rot, frame):

	var this_ghost = preload("res://ghost.tscn").instance()
	get_parent().add_child(this_ghost)
	this_ghost.position = pos
	this_ghost.texture = frame
	this_ghost.scale = $animation.scale
	this_ghost.rotation = rot

func reset_position():
	position = original_position
	motion = Vector2(0,0)
	rotation = 0

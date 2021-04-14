extends KinematicBody2D

const GRAVITY = 3000
const ROTATION_SPEED = 7
const JUMP_HEIGHT = -550
const CHAIN_PULL = 5000

var motion = Vector2()
var jump = -1
var fastfall = 0
var last_speed = 0
var landfall = 0
var friction = false

var multiplier = .8
var chain_velocity := Vector2(0,0)

var original_position = Vector2(-1023, -1023)

var win_x = 0

var chain_rotation = 0

var rotation_change = 10

slave var slave_multiplier = .8

slave var slave_position = Vector2()
slave var slave_rotation = 0

var collision_speed = 0
var col_diff = 0

var bounce_cooldown = 0

var m_pos = Vector2(0,0)



func _ready():
	pass # Replace with function body

func _physics_process(delta):
	bounce_cooldown -= delta
	
	
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left"))
	
	if original_position == Vector2(-1023, -1023):
		original_position = position
	
	var chain_distance = $Chain/Tip.global_position.distance_to(global_position)
	
	chain_velocity = Vector2(0,0)
	chain_rotation = $Chain/Tip.global_rotation

	var fake_rot = $animation.rotation

	#if chain_distance > 600 and $Chain.hooked:
	#	$Chain.release()
		
	if $Chain.hooked:

		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		#chain_velocity = to_local($Chain.tip).normalized() * (chain_distance*chain_distance*chain_distance) * delta / 10000
		chain_velocity = to_local($Chain.tip).normalized()  * delta * CHAIN_PULL
		#chain_velocity = to_local($Chain.tip).normalized() * motion.length()
		#if chain_velocity.y > 0:
			# Pulling down isn't as strong
			#chain_velocity.y *= 0.55
		if chain_velocity.y < 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 1.65
		#if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			#chain_velocity.x *= 0.7

		
	
	motion.y += (GRAVITY + fastfall) * delta

	if friction:
		
		#if rotation < -PI/1.97:
		#	rotation += 10 * delta
		#elif rotation > PI/1.97:
		#	rotation -= 10 * delta
		
		#if fake_rot < -PI/1.97:
		#	$animation.rotation += 10 * delta
		#elif fake_rot > PI/1.97:
		#	$animation.rotation -= 10 * delta
		

		$animation.rotation += rotation_change * delta * collision_speed * col_diff/2000
		#cur_rot_speed += rotation_change * collision_speed * col_diff/2000
		

		#if rotation_change > 0:
		#	rotation_change -= delta
		#	if rotation_change < 0:
		#		rotation_change = 0
		#else:
		#	rotation_change += delta
		#	if rotation_change < 0:
		#		rotation_change = 0
		
		#last_rotation = $animation.rotation

		#$animation.rotation += delta * cur_rot_speed
		#cur_rot_speed = ($animation.rotation - last_rotation)/delta
		
		
		
		set_rotations()

		fake_rot = $animation.rotation
		#motion.x += sign(motion.x) * -200 * delta
		
	if jump < 0:
		jump -= delta
		$animation.play("air")
		fastfall = 0
		if is_network_master():
			$Camera2D.current = true
			if(jump < -.1):
				if Input.is_action_pressed("ui_right"):
					#rotation += ROTATION_SPEED * delta
					$animation.rotation += ROTATION_SPEED * delta
				elif Input.is_action_pressed("ui_left"):
					#rotation -= ROTATION_SPEED * delta
					$animation.rotation -= ROTATION_SPEED * delta
				elif Input.is_action_pressed("ui_down"):
					fastfall = 2000
				set_rotations()
				fake_rot = $animation.rotation
			last_speed = sqrt(motion.x*motion.x + motion.y*motion.y)
			motion += chain_velocity
			motion = move_and_slide(motion)
			rset('slave_position', position)
			rset('slave_rotation', $animation.rotation)
			

		else:
			last_speed = sqrt(motion.x*motion.x + motion.y*motion.y)
			motion += chain_velocity
			motion = move_and_slide(motion)
			position = slave_position
			$animation.rotation = slave_rotation
			set_rotations()
			fake_rot = slave_rotation

		#if(jump < -.3):
		for i in get_slide_count():
			if i < get_slide_count():
				var collision = get_slide_collision(i)
				if collision:
					var diff = position - collision.position

					#if the distance is more than 60 pixels, then we know it's the tip 
					if sqrt(diff.x*diff.x + diff.y*diff.y) > 50 and jump < -.3:
						#jump here
						jump = .2
						friction = false
						if is_network_master():
							slave_multiplier = .6
							
							rset('slave_multiplier', .6)
						
					else:
						
						#print(collision.normal)
						#rotation_change = -(diff * motion * sin(diff.angle())).length() * sign(motion.cross(diff))
						rotation_change = sign(motion.cross(diff))
						if bounce_cooldown < 0 and motion.length() > .1:
							collision_speed = motion.length()
						col_diff = diff.length()
						motion = move_and_slide(Vector2(0, last_speed * .4).rotated(motion.angle()))
						bounce_cooldown = 0.1
						if sqrt(diff.x*diff.x + diff.y*diff.y) < 50:
							friction = true	

							#cur_rot_speed = rotation_change * collision_speed * col_diff/2000
						#motion = move_and_slide(motion.bounce(collision.normal)) #Vector2(0, last_speed * .4).rotated($animation.rotation)

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
		
		if jump <= 0 and bounce_cooldown < 0:
			motion = move_and_slide(Vector2(0, -600 - last_speed * slave_multiplier).rotated($animation.rotation))
			
			#if slave_multiplier == .8:
				#rpc("cloud_anim", $cloud_spawn.global_position, rotation)
	#$Chain/Links.global_rotation = chain_rotation
	#$Chain/Tip.global_rotation = chain_rotation
	
func init(nickname, start_position, is_slave):
	global_position = start_position
	
func set_dominant_color(color):
	$animation.modulate = color

			
			
func _on_ghost_timer_timeout():
	if jump < 0 and jump > -.5 and slave_multiplier == .8:
		rpc("ghost_spawn", position, $animation.rotation, $animation.frames.get_frame($animation.animation, $animation.frame))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			if is_network_master():
				$Chain.shoot(event.position - get_viewport().size * 0.5)
				#slave_chain = true
				#m_pos = event.position
				#rset('slave_chain', true)
		else:
			# We released the mouse -> release()
			$Chain.release()

		
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
	$animation.rotation = 0
	$animation.rotation = 0


func set_rotations():
	$body.global_rotation = $animation/body_copy.global_rotation
	$body.global_position = $animation/body_copy.global_position

	$body2.global_rotation = $animation/body2_copy.global_rotation
	$body2.global_position = $animation/body2_copy.global_position
	
	$body5.global_rotation = $animation/body5_copy.global_rotation
	$body5.global_position = $animation/body5_copy.global_position
	
	$body7.global_rotation = $animation/body7_copy.global_rotation
	$body7.global_position = $animation/body7_copy.global_position

	$tip_collision.global_rotation = $animation/tip_collision_copy.global_rotation
	$tip_collision.global_position = $animation/tip_collision_copy.global_position
	
	

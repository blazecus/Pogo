extends KinematicBody2D

const GRAVITY = 40
const ROTATION_SPEED = 7
const JUMP_HEIGHT = -550

var motion = Vector2()
var jump = -1
var fastfall = 0
var last_speed = 0
var landfall = 0
var friction = false

slave var slave_position = Vector2()
slave var slave_rotation = 0

func _ready():
	pass # Replace with function body

func _physics_process(delta):

	motion.y += GRAVITY + fastfall

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
					fastfall = 45
			
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
				if sqrt(diff.x*diff.x + diff.y*diff.y) > 60:
					#jump here
					jump = .2
					friction = false
				else:
					friction = true			
	else:	
		$animation.play("jump")
		jump -= delta
		if jump <= 0:
			motion = Vector2(0, -600 - last_speed * .8).rotated(rotation)

		
func init(nickname, start_position, is_slave):
	global_position = start_position
	
func set_dominant_color(color):
	$animation.modulate = color

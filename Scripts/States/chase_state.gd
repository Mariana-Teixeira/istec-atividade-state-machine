class_name ChaseState extends BaseState

func enter() -> void:
	knight.animated_sprite.play("walk")

func exit() -> void:
	pass

func tick() -> void:
	knight.velocity = knight.direction_to_cursor.normalized() * knight.speed
	knight.move_and_slide()

func branch() -> BaseState:
	var within_vision: bool = knight.cursor_within_vision_range()
	var within_attack: bool = knight.cursor_within_attack_range()
	if not within_vision:
		return IdleState.new(knight)
	elif within_attack:
		return AttackState.new(knight)
	else:
		return null

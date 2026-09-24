class_name AttackState extends BaseState

func enter() -> void:
	knight.animated_sprite.play("attack")

func exit() -> void:
	pass

func tick() -> void:
	pass

func branch() -> BaseState:
	var within_vision: bool = knight.cursor_within_vision_range()
	var within_attack: bool = knight.cursor_within_attack_range()
	if not within_vision:
		return IdleState.new(knight)
	elif not within_attack:
		return ChaseState.new(knight)
	else:
		return null

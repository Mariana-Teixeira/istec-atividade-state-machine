class_name IdleState extends BaseState

func enter() -> void:
	knight.animated_sprite.play("idle")

func exit() -> void:
	pass

func tick() -> void:
	pass

func branch() -> BaseState:
	var within_attack: bool = knight.cursor_within_attack_range()
	var within_vision: bool = knight.cursor_within_vision_range()
	if within_attack:
		return AttackState.new(knight)
	elif within_vision:
		return ChaseState.new(knight)
	else:
		return null

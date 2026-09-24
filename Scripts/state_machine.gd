class_name StateMachine extends RefCounted

var target: Knight
var current_state: BaseState

func _init(knight: Knight) -> void:
	target = knight
	var idle = IdleState.new(knight)
	change(idle)

func tick() -> void:
	current_state.tick()
	check_conditions()

func check_conditions() -> void:
	var new_state: BaseState = current_state.branch()
	if new_state != null:
		change(new_state)

func change(new_state: BaseState) -> void:
	if current_state != null:
		current_state.exit()
	current_state = new_state
	current_state.enter()

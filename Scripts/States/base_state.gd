class_name BaseState extends RefCounted

var knight: Knight

func _init(k: Knight) -> void:
	knight = k

func enter() -> void:
	pass

func exit() -> void:
	pass

func tick() -> void:
	pass

func branch() -> BaseState:
	return null

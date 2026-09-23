class_name Knight extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var vision_range: float = 32.0
@export var attack_range: float = 16.0
@export var speed: float = 8.0

var state_machine: StateMachine
var direction_to_cursor: Vector2

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	read_cursor_position()

func _physics_process(delta: float) -> void:
	pass

func read_cursor_position() -> void:
	direction_to_cursor = get_global_mouse_position() - global_position

func cursor_within_vision_radius() -> bool:
	return direction_to_cursor.length() < vision_range

func cursor_within_attack_range() -> bool:
	return direction_to_cursor.length() < attack_range

func _draw() -> void:
	draw_arc(Vector2.ZERO, vision_range, 0, TAU, 64, Color.BLUE, 0.5)
	draw_arc(Vector2.ZERO, attack_range, 0, TAU, 64, Color.RED, 0.5)

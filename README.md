# Atividade 1: State Machine

## Índice

* [1. Objetivos](#1-objetivos)
* [2. Pré-Requisitos](#2-pré-requisitos)
  * [2.1. Instala o Godot](#21-instala-o-godot)
  * [2.2. Faz *fork* do Repositório](#22-faz-fork-do-repositório)
* [3. Tutorial](#3-tutorial)
  * [3.1 Cria a classe base `BaseState`](#31-cria-a-classe-base-basestate)
  * [3.2 Cria o estado `IdleState`](#32-cria-o-estado-idlestate)
  * [3.3 Cria o estado `ChaseState`](#33-cria-o-estado-chasestate)
  * [3.4 Cria o estado `AttackState`](#34-cria-o-estado-attackstate)
  * [3.5 Cria o `StateMachine`](#35-cria-o-statemachine)
  * [3.6 Conecta a `StateMachine` ao `Knight`](#36-conecta-a-statemachine-ao-knight)
* [4. Entrega](#4-entrega)

---

## 1. Objetivos

Nesta atividade vais criar, em Godot, um personagem que reage à posição do cursor através de diferentes estados.  
O personagem pode encontrar-se num de três estados:

| Estado | Descrição |
|---|---|
| Idle | Se o cursor estiver longe do personagem, este não realiza nenhuma ação. |
| Chase | Se o cursor estiver dentro da "visão" do personagem, este segue o cursor. |
| Attack | Se o cursor estiver dentro do alcance do personagem, este "ataca" o cursor. |

Ao longo da atividade, vais implementar a lógica que permite ao personagem mudar entre estes estados de acordo com a situação do jogo.  
No final, o projeto deverá permitir observar claramente a transição entre os três estados.

---

## 2. Pré-Requisitos

Antes de começares a atividade, deves:
* instalar o Godot,
* e fazer fork deste repositório.

### 2.1. Instala o Godot

Instala o [Godot](https://godotengine.org/download/) a partir da página oficial.  
Utiliza a versão mais recente.

### 2.2. Faz *fork* do Repositório

Antes de começares a trabalhar, cria uma cópia do repositório na tua conta do GitHub.
1. Seleciona *fork* neste repositório.
2. Escolhe a tua conta como destino.
3. Confirma a criação do *fork*.

Depois de criares o teu *fork*, deves ter uma cópia do projeto na tua própria conta do GitHub que podes clonar.

---

# 3. Tutorial

## 3.1 Cria a classe base `BaseState`

Abre o `base_state.gd`.

```gdscript
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
```

Cada estado vai herdar desta classe e substituir estas quatro funções:
| Estado | Descrição |
|---|---|
| `enter()` | O que acontece quando se entra neste estado. |
| `exit()` | O que acontece quando se sai deste estado. |
| `tick()` | O que acontece em cada frame quando se está neste estado. |
| `branch()` | Decide se deve haver transição para outro estado. |

---

## 3.2 Cria o estado `IdleState`

Abre o `idle_state.gd`.

```gdscript
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
```

---

## 3.3 Cria o estado `ChaseState`

Abre o `chase_state.gd`.

```gdscript
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
```

---

## 3.4 Cria o estado `AttackState`

Abre o `attack_state.gd`.

```gdscript
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
```

---

## 3.5 Cria o `StateMachine`

Abre o `state_machine.gd`. Esta classe é responsável por saber qual é o estado atual e gerir as transições:

```gdscript
class_name StateMachine

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
```

---

## 3.6 Conecta a `StateMachine` ao `Knight`

Abre o `knight.gd`.

```gdscript
class_name Knight extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var vision_range: float = 32.0
@export var attack_range: float = 16.0
@export var speed: float = 8.0

var state_machine: StateMachine
var direction_to_cursor: Vector2

func _ready() -> void:
	state_machine = StateMachine.new(self)

func _process(_delta: float) -> void:
	read_cursor_position()

func _physics_process(_delta: float) -> void:
	state_machine.tick()

func read_cursor_position() -> void:
	var cursor_position: Vector2 = get_global_mouse_position()
	direction_to_cursor = cursor_position - global_position

func cursor_within_vision_range() -> bool:
	return direction_to_cursor.length() < vision_range

func cursor_within_attack_range() -> bool:
	return direction_to_cursor.length() < attack_range
```

---

## 4. Entrega

A entrega da atividade é feita através do Google Classroom.  
Coloca o URL do teu repositório na atividade do Google Classroom.

> **Atenção**: Define o teu repositório como **público**.
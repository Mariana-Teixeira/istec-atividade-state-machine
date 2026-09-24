# Atividade 1: State Machine

## Índice

* [1. Objetivos](#1-objetivos)
* [2. Pré-requisitos](#2-pré-requisitos)

  * [2.1. Instala o Godot](#21-instala-o-godot)
  * [2.2. Faz fork do repositório](#22-faz-fork-do-repositório)
* [3. Tutorial](#3-tutorial)

  * [3.1. Cria a classe base `BaseState`](#31-cria-a-classe-base-basestate)
  * [3.2. Cria o estado `IdleState`](#32-cria-o-estado-idlestate)
  * [3.3. Cria o estado `ChaseState`](#33-cria-o-estado-chasestate)
  * [3.4. Cria o estado `AttackState`](#34-cria-o-estado-attackstate)
  * [3.5. Cria o `StateMachine`](#35-cria-o-statemachine)
  * [3.6. Conecta a `StateMachine` ao `Knight`](#36-conecta-a-statemachine-ao-knight)
* [4. Cria uma mecânica original](#4-cria-uma-mecânica-original)

  * [4.1. Cria uma nova branch](#41-cria-uma-nova-branch)
  * [4.2. Desenvolve a mecânica](#42-desenvolve-a-mecânica)
  * [4.3. Testa a mecânica](#43-testa-a-mecânica)
* [5. Entrega](#5-entrega)
* [6. Nota de transparência](#6-nota-de-transparência)

---

## 1. Objetivos

Nesta atividade vais criar, em Godot, um personagem que reage à posição do cursor através de diferentes estados.

O personagem pode encontrar-se num de três estados:

| Estado | Descrição                                                                   |
| ------ | --------------------------------------------------------------------------- |
| Idle   | Se o cursor estiver longe do personagem, este não realiza nenhuma ação.     |
| Chase  | Se o cursor estiver dentro da "visão" do personagem, este segue o cursor.   |
| Attack | Se o cursor estiver dentro do alcance do personagem, este "ataca" o cursor. |

Ao longo da atividade, vais implementar a lógica que permite ao personagem mudar entre estes estados de acordo com a situação do jogo.

No final, o projeto deverá permitir observar a transição entre os três estados.

---

## 2. Pré-requisitos

Antes de começares a atividade, deves:

* instalar o Godot;
* fazer fork deste repositório.

### 2.1. Instala o Godot

Instala o [Godot](https://godotengine.org/download/) a partir da página oficial.

Utiliza a versão mais recente.


### 2.2. Faz fork do repositório

Antes de começares a trabalhar, cria o teu fork do repositório na tua conta do GitHub.

Deves ter uma cópia do projeto na tua própria conta do GitHub que podes clonar.

---

# 3. Tutorial

## 3.1. Cria a classe base `BaseState`

Abre o ficheiro `base_state.gd`.

A classe `BaseState` define a estrutura comum aos diferentes estados do personagem. Cada estado vai herdar desta classe e implementar o comportamento necessário.

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

A variável `knight` guarda uma referência ao personagem. Desta forma, cada estado pode aceder às suas propriedades e funções.

As quatro funções definem diferentes momentos do funcionamento de um estado:

| Função     | Descrição                                                 |
| ---------- | --------------------------------------------------------- |
| `enter()`  | É executada quando o personagem entra no estado.          |
| `exit()`   | É executada quando o personagem sai do estado.            |
| `tick()`   | É executada enquanto o estado está ativo.                 |
| `branch()` | Verifica se deve ocorrer uma transição para outro estado. |

---

## 3.2. Cria o estado `IdleState`

Abre o ficheiro `idle_state.gd`.

O estado `IdleState` representa a situação em que o personagem está parado.

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

Na função `enter()`, é reproduzida a animação `idle` quando o personagem entra neste estado.

A função `tick()` não precisa de realizar nenhuma ação porque o personagem permanece parado.

A função `branch()` verifica a posição do cursor para determinar se é necessário mudar de estado:

* se o cursor estiver dentro do alcance de ataque, passa para `AttackState`;
* se o cursor estiver dentro do alcance de visão, passa para `ChaseState`;
* caso contrário, permanece em `IdleState`.

---

## 3.3. Cria o estado `ChaseState`

Abre o ficheiro `chase_state.gd`.

O estado `ChaseState` representa a situação em que o personagem deteta o cursor e se desloca na sua direção.

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

Na função `tick()`, a direção para o cursor é normalizada e multiplicada pela velocidade do personagem.  
O resultado é atribuído a `velocity` e `move_and_slide()` aplica o movimento.

---

## 3.4. Cria o estado `AttackState`

Abre o ficheiro `attack_state.gd`.

O estado `AttackState` representa a situação em que o cursor está próximo o suficiente do personagem para este realizar um ataque.

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

## 3.5. Cria o `StateMachine`

Abre o ficheiro `state_machine.gd`.

A classe `StateMachine` mantém o estado atual do personagem e gere as transições entre estados.

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

A variável `current_state` guarda o estado atual do personagem.

No `_init()`, a máquina de estados começa no `IdleState`.

A função `tick()` atualiza o estado atual através de `current_state.tick()` e verifica se deve ocorrer uma transição.

A função `check_conditions()` chama `branch()` no estado atual. Se esta função devolver um novo estado, a máquina de estados chama `change()` para realizar a transição.

Na função `change()`, o estado anterior é terminado através de `exit()`. Depois, o novo estado passa a ser o estado atual e é inicializado através de `enter()`.

---

## 3.6. Conecta a `StateMachine` ao `Knight`

Abre o ficheiro `knight.gd`.

O `Knight` guarda os dados necessários ao funcionamento da máquina de estados e atualiza-a durante a execução do jogo.

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

As variáveis `vision_range` e `attack_range` definem as distâncias utilizadas para determinar o estado do personagem.  
A variável `speed` define a velocidade utilizada no estado `ChaseState`.

A máquina de estados é atualizada em `_physics_process()` através de `state_machine.tick()`, porque estados como `ChaseState` usam o motor de física do Godot para mover a personagem. Um estado que não dependesse da física poderia, em vez disso, correr em `_process()`.

As funções `cursor_within_vision_range()` e `cursor_within_attack_range()` verificam se o cursor está dentro das respetivas distâncias.

---

# 4. Cria uma mecânica original

Depois de concluíres o tutorial, vais utilizar a máquina de estados para criar uma mecânica original.

A mecânica deve ser diferente do comportamento desenvolvido no tutorial, mas deve utilizar os mesmos princípios de uma máquina de estados.

## 4.1. Cria uma nova branch

Cria uma nova branch a partir da versão do projeto em que concluíste o tutorial.

Escolhe um nome que identifique claramente o objetivo da branch.

A partir desta branch, vais desenvolver a tua mecânica sem alterar o trabalho concluído no tutorial.

## 4.2. Desenvolve a mecânica

Cria uma mecânica que possa ser representada através de diferentes estados.

Os estados e o comportamento da mecânica ficam ao teu critério.

A tua implementação deve:

* utilizar vários estados;
* definir um comportamento para cada estado;
* definir condições para as transições entre estados;
* utilizar uma `StateMachine` para gerir essas transições.

---

# 5. Entrega

A entrega da atividade é feita através do Google Classroom.

Coloca o URL do teu repositório na atividade do Google Classroom.

> **Atenção:** Define o teu repositório como **público**.

---

# 6. Nota de transparência

Com o objetivo de garantir transparência, descrevo de seguida o processo que adotei no desenvolvimento desta atividade.

O processo teve início com a criação de um projeto piloto em Godot, no qual implementei a máquina de estados descrita neste tutorial. Esta fase teve como objetivo validar a adequação da proposta de atividade antes da sua transformação em material didático. Redigi posteriormente o conteúdo da ficha de atividade num ficheiro Markdown. Recorri a LLMs para formatar o documento e para rever o texto ao nível da ortografia, gramática e clareza.

O conteúdo técnico, nomeadamente o código e a lógica da máquina de estados, foi desenvolvido e validado exclusivamente por mim no projeto piloto, tendo a utilização de LLMs sido limitada à formatação e à revisão do texto.
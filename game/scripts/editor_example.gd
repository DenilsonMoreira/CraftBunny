extends Node2D

const PLAYER = preload("res://scripts/player.gd")
const ENEMY = preload("res://scripts/enemy.gd")
const PICKUP = preload("res://scripts/pickup.gd")
var player: CharacterBody2D
var enemies: Array[CharacterBody2D] = []
var carrots := 0

func _ready() -> void:
 _setup_inputs()
 var start := get_node("InicioJogador") as Marker2D
 player = PLAYER.new()
 player.position = to_local(start.global_position)
 player.add_to_group("player")
 add_child(player)
 start.hide()
 player.controls_enabled = true
 player.hammer_used.connect(_hammer)
 player.health_changed.connect(func(_health): _update_status())
 player.died.connect(_died)
 for child in player.get_children():
  if child is Camera2D:
   child.limit_right = 960
   child.limit_top = 0
   child.limit_bottom = 540
   child.position_smoothing_enabled = false
 for marker in $Inimigos.get_children():
  if not marker is Marker2D: continue
  var enemy = ENEMY.new()
  enemy.setup("cobra",to_local(marker.global_position),player)
  enemy.add_to_group("enemy")
  add_child(enemy)
  enemy.active = true
  enemy.attack_landed.connect(func(amount: int, from_x: float): player.take_damage(amount,from_x))
  enemy.defeated.connect(_defeated)
  enemies.append(enemy)
  marker.hide()
 _update_status()

func _setup_inputs() -> void:
 var bindings := {"move_left":[KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],"jump":[KEY_SPACE,KEY_W,KEY_UP],"attack":[KEY_J],"craft":[KEY_K],"pause_game":[KEY_ESCAPE,KEY_P]}
 for action in bindings:
  if InputMap.has_action(action): continue
  InputMap.add_action(action)
  for key in bindings[action]:
   var event := InputEventKey.new()
   event.physical_keycode = key
   InputMap.action_add_event(action,event)

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
  get_tree().reload_current_scene()

func _hammer(hitbox: Rect2) -> void:
 for enemy in enemies:
  if is_instance_valid(enemy) and enemy.alive and hitbox.intersects(enemy.get_hurtbox()):
   enemy.take_hit(1,player.global_position.x)

func _defeated(enemy: CharacterBody2D,reward: int) -> void:
 for index in range(reward):
  var pickup = PICKUP.new()
  pickup.setup("carrot")
  pickup.position = to_local(enemy.global_position)+Vector2(index*22,-30)
  pickup.collected.connect(_collected)
  add_child(pickup)

func _collected(pickup: Area2D) -> void:
 pickup._claimed = true
 carrots += pickup.amount
 pickup.queue_free()
 _update_status()

func _died() -> void:
 for enemy in enemies:
  if is_instance_valid(enemy): enemy.active = false
 _update_status()

func _update_status() -> void:
 $Interface/Status.text = "VIDA: %d/3   CENOURAS: %d   |   %s" % [player.health,carrots,"R: reiniciar exemplo" if player.health > 0 else "R: tentar novamente"]

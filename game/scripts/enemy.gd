extends CharacterBody2D

signal defeated(enemy: CharacterBody2D, reward: int)
signal attack_landed(amount: int, enemy_x: float)

const GRAVITY := 1150.0
const BIRD_DIVE_SPEED := 220.0
const BIRD_RETURN_SPEED := 150.0
const BIRD_RETURN_LIMIT := 1.2
const BIRD_ATTACK_DISTANCE := 110.0
const BIRD_RETURN_DRIFT := 80.0
const BIRD_TURN_DISTANCE := 72.0
const HIT_FLASH_TIME := 0.24
const HEALTH_FEEDBACK_TIME := 1.25
const ALERT_TIME := 0.90
const DATA := {
 "cobra": {"hp": 2, "damage": 1, "reward": 1, "speed": 56.0, "spot": 185.0, "range": 43.0, "windup": 0.28, "cooldown": 1.5},
 "guaxinim": {"hp": 5, "damage": 2, "reward": 3, "speed": 92.0, "spot": 275.0, "range": 48.0, "windup": 0.35, "cooldown": 1.8},
 "ave": {"hp": 7, "damage": 3, "reward": 5, "speed": 140.0, "spot": 315.0, "range": 55.0, "windup": 0.55, "cooldown": 2.5}
}

var kind := "cobra"
var hp := 2
var patrol_origin := Vector2.ZERO
var facing := -1
var player: CharacterBody2D
var state := "patrol"
var timer := 0.0
var attack_timer := 0.0
var damage_recovery := 0.0
var knockback := Vector2.ZERO
var alive := true
var active := false
var home_position := Vector2.ZERO
var _attack_hit_sent := false
var _contact_damage_timer := 0.0
var animated_sprite: AnimatedSprite2D
var dive_direction := Vector2.DOWN
var hit_flash_timer := 0.0
var health_feedback_timer := 0.0
var alert_timer := 0.0
var player_detected := false
var last_damage := 0
var hit_material: ShaderMaterial

func setup(enemy_kind: String, pos: Vector2, target: CharacterBody2D) -> void:
 kind = enemy_kind
 position = pos
 patrol_origin = pos
 home_position = pos
 player = target
 hp = int(DATA[kind]["hp"])

func _ready() -> void:
 collision_layer = 1
 collision_mask = 1
 var col := CollisionShape2D.new()
 var rect := RectangleShape2D.new()
 rect.size = Vector2(36,26) if kind != "ave" else Vector2(40,24)
 col.shape = rect
 add_child(col)
 _setup_visual()

func _setup_visual() -> void:
 animated_sprite = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/" + kind + ".png", {
  "idle": [0,1,2,3], "move": [4,5,6,7], "attack": [8,9,10,11],
  "hurt": [12,13], "death": [14,15]
 }, Vector2(52,38) if kind == "ave" else Vector2(46,30), 13.0, kind == "ave")
 if animated_sprite != null:
  hit_material = ShaderMaterial.new()
  hit_material.shader = preload("res://scripts/enemy_hit.gdshader")
  animated_sprite.material = hit_material
  add_child(animated_sprite)

func _process(delta: float) -> void:
 if not active: return
 hit_flash_timer = maxf(0,hit_flash_timer-delta)
 health_feedback_timer = maxf(0,health_feedback_timer-delta)
 alert_timer = maxf(0,alert_timer-delta)
 if hit_material != null:
  hit_material.set_shader_parameter("hit_strength",minf(1.0,hit_flash_timer/HIT_FLASH_TIME*1.6))
 queue_redraw()

func _physics_process(delta: float) -> void:
 if not alive or not active:
  return
 if is_instance_valid(animated_sprite):
  var animation_name := "hurt" if damage_recovery > 0.0 else ("attack" if state in ["windup", "attack"] else ("move" if absf(velocity.x) > 5.0 else "idle"))
  if animated_sprite.animation != animation_name: animated_sprite.play(animation_name)
  animated_sprite.flip_h = facing < 0
 timer += delta
 attack_timer = maxf(0.0, attack_timer - delta)
 _contact_damage_timer = maxf(0.0, _contact_damage_timer - delta)
 if damage_recovery > 0:
  damage_recovery -= delta
  if kind != "ave":
   velocity.y += GRAVITY * delta
   velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
   move_and_slide()
  else:
   global_position += knockback * delta
   knockback = knockback.move_toward(Vector2.ZERO, 400.0 * delta)
  queue_redraw()
  return
 var cfg: Dictionary = DATA[kind]
 var distance: float = global_position.distance_to(player.global_position) if is_instance_valid(player) else INF
 var dx: float = player.global_position.x-global_position.x if is_instance_valid(player) else 0.0
 var detect: bool = distance < float(cfg["spot"]) and player.controls_enabled
 if detect and not player_detected: alert_timer = ALERT_TIME
 player_detected = detect
 var player_above: bool = player.global_position.y + 21 <= global_position.y - (12 if kind == "ave" else 13) + 5
 if not player_above and distance <= 28.0 and absf(player.global_position.y-global_position.y) < 34.0 and _contact_damage_timer <= 0.0:
  attack_landed.emit(int(cfg["damage"]), global_position.x)
  _contact_damage_timer = 0.6
 if state == "windup":
  velocity.x = 0
  if kind != "ave":
   velocity.y += GRAVITY*delta
   move_and_slide()
  if timer >= float(cfg["windup"]):
   state = "attack"
   timer = 0
   if kind == "ave":
    dive_direction = (player.global_position-global_position).normalized()
    if dive_direction == Vector2.ZERO: dive_direction = Vector2.DOWN
 elif state == "attack":
  var blocked_dive := false
  if kind == "ave":
   velocity = dive_direction * BIRD_DIVE_SPEED
   blocked_dive = move_and_collide(velocity*delta) != null
  else:
   velocity.x = facing * (205.0 if kind == "cobra" else 190.0)
   velocity.y += GRAVITY*delta
   move_and_slide()
  if not player_above and not _attack_hit_sent and distance <= float(cfg["range"]) and absf(player.global_position.y-global_position.y)<48:
   attack_landed.emit(int(cfg["damage"]),global_position.x)
   _attack_hit_sent = true
  if timer > 0.32 or blocked_dive:
   state = "recover"
   timer = 0
   attack_timer = float(cfg["cooldown"])
 elif state == "recover":
  var recovered := timer > 0.35
  if kind == "ave":
   # Ascend and move away so the bird cannot remain pressed against the player.
   velocity = Vector2(-facing*BIRD_RETURN_DRIFT,clampf((home_position.y-global_position.y)/delta,-BIRD_RETURN_SPEED,BIRD_RETURN_SPEED))
   move_and_slide()
   recovered = (timer >= 0.35 and global_position.y <= home_position.y+4) or timer >= BIRD_RETURN_LIMIT
  else:
   velocity.x = move_toward(velocity.x,0,520*delta)
   velocity.y += GRAVITY*delta
   move_and_slide()
  if recovered:
   state = "patrol"
   timer = 0
 else:
  var attack_aligned := distance <= float(cfg["range"])+22
  if kind == "ave":
   attack_aligned = absf(dx) <= float(cfg["range"])+22 and distance <= BIRD_ATTACK_DISTANCE and player.global_position.y >= global_position.y-24
  if detect and attack_aligned and attack_timer <= 0:
   facing = 1 if dx > 0 else -1
   state = "windup"
   timer = 0
   _attack_hit_sent = false
  elif detect:
   state = "chase"
   if kind != "ave" or absf(dx) > BIRD_TURN_DISTANCE:
    facing = 1 if dx > 0 else -1
  else:
   state = "patrol"
   if absf(global_position.x-patrol_origin.x) > 105:
    facing = -1 if global_position.x>patrol_origin.x else 1
  if kind == "ave":
   var target_y: float = home_position.y + sin(timer * 2.5) * 18
   if state == "chase":
    target_y = minf(home_position.y+75,player.global_position.y-68)
   velocity = Vector2(facing * (float(cfg["speed"]) if state == "chase" else 65), clampf((target_y-global_position.y)*3,-110,110))
   global_position += velocity*delta
  else:
   velocity.x = facing*float(cfg["speed"]) * (1.35 if state == "chase" else 1)
   velocity.y += GRAVITY*delta
   move_and_slide()
   if is_on_wall(): facing *= -1
 queue_redraw()

func get_hurtbox() -> Rect2:
 var size := Vector2(40,24) if kind == "ave" else Vector2(36,26)
 return Rect2(global_position-size/2,size)

func take_hit(amount: int, from_x: float) -> void:
 if not alive or damage_recovery > 0: return
 hp -= amount
 last_damage = amount
 hit_flash_timer = HIT_FLASH_TIME
 health_feedback_timer = HEALTH_FEEDBACK_TIME
 if hit_material != null: hit_material.set_shader_parameter("hit_strength",1.0)
 if is_instance_valid(animated_sprite): animated_sprite.play("hurt")
 if hp <= 0:
  alive = false
  alert_timer = 0
  defeated.emit(self,int(DATA[kind]["reward"]))
  collision_layer = 0
  collision_mask = 0
  if is_instance_valid(animated_sprite):
   animated_sprite.play("death")
   await get_tree().create_timer(0.4).timeout
  queue_free()
  return
 damage_recovery = 0.28
 state = "recover"
 timer = 0
 facing = 1 if global_position.x >= from_x else -1
 velocity.x = facing*150.0
 velocity.y = -95.0
 knockback = Vector2(facing*140,-45)
 queue_redraw()

func _draw() -> void:
 _draw_feedback()
 if is_instance_valid(animated_sprite):
  return
 if damage_recovery > 0 and int(Time.get_ticks_msec()/75)%2==0: return
 match kind:
  "cobra":
   draw_rect(Rect2(-19,-4,39,15),Color("559545"))
   draw_rect(Rect2(4,-18,17,19),Color("84be4c"))
   draw_rect(Rect2(13,-12,5,4),Color("f5e0a5"))
   draw_rect(Rect2(16,-11,2,2),Color("342b30"))
  "guaxinim":
   draw_rect(Rect2(-20,-11,38,25),Color("988177"))
   draw_rect(Rect2(-14,-19,10,12),Color("70584e"))
   draw_rect(Rect2(7,-19,10,12),Color("70584e"))
   draw_rect(Rect2(-13,-9,28,12),Color("4e4547"))
   draw_rect(Rect2(-8,-6,5,5),Color.WHITE)
   draw_rect(Rect2(6,-6,5,5),Color.WHITE)
   draw_rect(Rect2(16,5,16,8),Color("756054"))
  "ave":
   draw_rect(Rect2(-15,-10,30,20),Color("985e38"))
   draw_colored_polygon(PackedVector2Array([Vector2(-12,0),Vector2(-39,-19-sin(timer*16)*9),Vector2(-29,8),Vector2(-8,10)]),Color("b8793e"))
   draw_colored_polygon(PackedVector2Array([Vector2(10,0),Vector2(39,-18-sin(timer*16)*9),Vector2(29,10),Vector2(8,10)]),Color("b8793e"))
   draw_rect(Rect2(7,-6,5,5),Color.WHITE)
   draw_colored_polygon(PackedVector2Array([Vector2(15,0),Vector2(25,4),Vector2(15,8)]),Color("e8b64e"))
 if state == "windup":
  draw_circle(Vector2(0,-35),5,Color("e4a443"))
  draw_rect(Rect2(-2,-46,4,9),Color("e4a443"))

func _draw_feedback() -> void:
 if health_feedback_timer > 0:
  var maximum: int = int(DATA[kind]["hp"])
  draw_rect(Rect2(-19,-32,38,7),Color("231b1c"))
  draw_rect(Rect2(-17,-30,34,3),Color("74413b"))
  draw_rect(Rect2(-17,-30,34*float(maxi(hp,0))/maximum,3),Color("f9c45b"))
  var rise := minf(1.0,(HEALTH_FEEDBACK_TIME-health_feedback_timer)/0.5)
  var font := preload("res://scripts/ui_theme.gd").pixel_font()
  draw_string(font,Vector2(21,-24-rise*10),"-"+str(last_damage),HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("fff0bc"))
 if hit_flash_timer > 0:
  var spread := 6+(1.0-hit_flash_timer/HIT_FLASH_TIME)*14
  for direction in [Vector2(-1,-1),Vector2(1,-1),Vector2(-1,0.5),Vector2(1,0.5)]:
   draw_rect(Rect2((Vector2(0,-8)+direction*spread).round(),Vector2(3,3)),Color("ffe7a0"))
 if alive and alert_timer > 0:
  var origin := Vector2(-10,-58)
  draw_rect(Rect2(origin+Vector2(2,0),Vector2(16,21)),Color("2c211d"))
  draw_rect(Rect2(origin+Vector2(0,2),Vector2(20,17)),Color("2c211d"))
  draw_rect(Rect2(origin+Vector2(2,3),Vector2(16,14)),Color("fff0d0"))
  draw_rect(Rect2(origin+Vector2(8,18),Vector2(5,5)),Color("2c211d"))
  draw_rect(Rect2(origin+Vector2(9,16),Vector2(3,5)),Color("fff0d0"))
  draw_rect(Rect2(origin+Vector2(9,5),Vector2(3,7)),Color("a63c2a"))
  draw_rect(Rect2(origin+Vector2(9,14),Vector2(3,2)),Color("a63c2a"))

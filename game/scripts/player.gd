extends CharacterBody2D

signal health_changed(value: int)
signal hammer_used(hitbox: Rect2)
signal box_requested()
signal died()
signal pit_falling()
signal stomped()

const MAX_HEALTH := 3
const SPEED := 230.0
const ACCELERATION := 1250.0
const FRICTION := 1600.0
const GRAVITY := 1150.0
# Height = v² / (2g) ~= 42 px (the rabbit's 42 px collision height).
# Clear the 42 px crate with a small collision margin, including a short tap.
const JUMP_SPEED := -340.0
const MIN_RELEASE_JUMP_SPEED := -335.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.12
const INVULNERABILITY := 1.0
const ATTACK_COOLDOWN := 0.42
const ATTACK_ACTIVE_TIME := 0.12
const HAMMER_REACH := 32.0
const HAMMER_HEIGHT := 26.0
const ATTACK_VISUAL_DURATION := 0.40
const ATTACK_FRAME_COUNT := 12
const WORLD_ZOOM := 1.25
const DEATH_VISUAL_DURATION := 0.80
const STOMP_REBOUND := -240.0
const STOMP_GROUND_BOUNCE := -110.0
const STOMP_VISUAL_DURATION := 0.80

var health := MAX_HEALTH
var facing := 1
var invincible_timer := 0.0
var hammer_timer := 0.0
var attack_active := 0.0
var coyote_timer := 0.0
var jump_buffer := 0.0
var controls_enabled := false
var _was_on_floor := false
var _hammer_hit_sent := false
var animated_sprite: AnimatedSprite2D
var _visual_ready := false
var attack_sprite: AnimatedSprite2D
var attack_visual_timer := 0.0
var attack_facing := 1
var death_sprite: AnimatedSprite2D
var death_cause := ""
var death_elapsed := 0.0
var pit_announced := false
var stomp_sprite: AnimatedSprite2D
var stomp_visual_timer := 0.0
var stomp_contact_grace := 0.0
var ground_bounce_pending := false
var ground_bounce_count := 0
var pit_warning_y := 525.0
var fall_death_y := 735.0

func _ready() -> void:
 collision_layer = 1
 collision_mask = 1
 var collision := CollisionShape2D.new()
 var shape := RectangleShape2D.new()
 shape.size = Vector2(26, 42)
 collision.shape = shape
 add_child(collision)
 var camera := Camera2D.new()
 camera.position = Vector2(0, -90)
 camera.zoom = Vector2.ONE * WORLD_ZOOM
 camera.limit_left = 0
 camera.limit_right = 12000
 camera.limit_top = -400
 camera.limit_bottom = 720
 camera.position_smoothing_enabled = true
 camera.position_smoothing_speed = 6.5
 add_child(camera)
 _setup_visual()

func _setup_visual() -> void:
 animated_sprite = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/bunny.png", {
  "idle": [0,1,2,3], "walk": [4,5,6,7], "run": [4,5,6,7],
  "jump": [8,9], "fall": [10], "land": [11], "attack": [12,13,14,15],
  "hurt": [3], "death": [11], "craft": [12,13,15]
 }, Vector2(48,60), 21.0)
 if animated_sprite == null: return
 add_child(animated_sprite)
 _visual_ready = true
 attack_sprite = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/bunny_attack_12.png", {
  "idle": [0], "attack": range(ATTACK_FRAME_COUNT)
 }, Vector2(88,60), 21.0, false, Vector2i(4,3), PackedVector2Array([
  Vector2(171,326), Vector2(170,326), Vector2(179,327), Vector2(184,328),
  Vector2(184,327), Vector2(180,327), Vector2(119,327), Vector2(107,327),
  Vector2(118,327), Vector2(122,328), Vector2(140,329), Vector2(160,330)
 ]))
 if attack_sprite != null:
  attack_sprite.sprite_frames.set_animation_speed("attack", float(ATTACK_FRAME_COUNT) / ATTACK_VISUAL_DURATION)
  attack_sprite.visible = false
  add_child(attack_sprite)
 death_sprite = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/bunny_death_8.png", {
  "idle": [0], "death": [0,1,2,3,4,5,6,7]
 }, Vector2(70,48), 21.0, false, Vector2i(4,2))
 if death_sprite != null:
  death_sprite.visible = false
  add_child(death_sprite)
 stomp_sprite = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/bunny_stomp_8.png", {
  "idle": [0], "stomp": [0,1,2,3,4,5,6,7]
 }, Vector2(60,48), 21.0, false, Vector2i(4,2))
 if stomp_sprite != null:
  stomp_sprite.visible = false
  add_child(stomp_sprite)

func _update_animation(axis: float) -> void:
 if not _visual_ready: return
 var next_animation := "idle"
 if health <= 0:
  next_animation = "death"
 elif invincible_timer > 0.0:
  next_animation = "hurt"
 elif attack_active > 0.0:
  next_animation = "attack"
 elif not is_on_floor():
  next_animation = "jump" if velocity.y < 0.0 else "fall"
 elif absf(axis) > 0.01:
  next_animation = "run" if absf(velocity.x) > SPEED * 0.85 else "walk"
 if animated_sprite.animation != next_animation or not animated_sprite.is_playing():
  animated_sprite.play(next_animation)
 animated_sprite.visible = health <= 0 or invincible_timer <= 0 or int(Time.get_ticks_msec() / 90) % 2 != 0
 if is_instance_valid(attack_sprite):
  var attacking := attack_visual_timer > 0 and health > 0
  if attacking:
   attack_sprite.frame = mini(ATTACK_FRAME_COUNT-1, int((ATTACK_VISUAL_DURATION-attack_visual_timer) * ATTACK_FRAME_COUNT / ATTACK_VISUAL_DURATION))
  attack_sprite.visible = attacking and animated_sprite.visible
  attack_sprite.flip_h = attack_facing < 0
  if attacking: animated_sprite.visible = false
 if axis != 0.0: animated_sprite.flip_h = axis < 0.0
 if is_instance_valid(stomp_sprite):
  var stomping := stomp_visual_timer > 0 and health > 0 and attack_visual_timer <= 0
  stomp_sprite.visible = stomping and (invincible_timer <= 0 or int(Time.get_ticks_msec()/90)%2 != 0)
  if stomping:
   animated_sprite.visible = false
   stomp_sprite.animation = "stomp"
   stomp_sprite.pause()
   stomp_sprite.frame = mini(7, int((STOMP_VISUAL_DURATION-stomp_visual_timer)*8.0/STOMP_VISUAL_DURATION))
   stomp_sprite.flip_h = facing < 0

func _physics_process(delta: float) -> void:
 if health <= 0:
  death_elapsed = minf(DEATH_VISUAL_DURATION, death_elapsed + delta)
  velocity.x = 0
  if not is_on_floor() and global_position.y < 950:
   velocity.y += GRAVITY * delta
   move_and_slide()
  if _visual_ready: animated_sprite.visible = false
  if is_instance_valid(attack_sprite): attack_sprite.visible = false
  if is_instance_valid(stomp_sprite): stomp_sprite.visible = false
  if is_instance_valid(death_sprite):
   death_sprite.visible = true
   death_sprite.flip_h = facing < 0
   death_sprite.animation = "death"
   death_sprite.pause()
   death_sprite.frame = mini(7, int(death_elapsed * 8.0 / DEATH_VISUAL_DURATION))
  return
 if not controls_enabled:
  velocity = Vector2.ZERO
  if is_instance_valid(attack_sprite): attack_sprite.speed_scale = 0
  if _visual_ready and health <= 0: _update_animation(0)
  queue_redraw()
  return
 if is_instance_valid(attack_sprite): attack_sprite.speed_scale = 1
 stomp_visual_timer = maxf(0, stomp_visual_timer-delta)
 stomp_contact_grace = maxf(0, stomp_contact_grace-delta)
 attack_visual_timer = maxf(0, attack_visual_timer-delta)
 invincible_timer = maxf(0.0, invincible_timer - delta)
 hammer_timer = maxf(0.0, hammer_timer - delta)
 attack_active = maxf(0.0, attack_active - delta)
 if is_on_floor():
  coyote_timer = COYOTE_TIME
 else:
  coyote_timer = maxf(0.0, coyote_timer - delta)
 if Input.is_action_just_pressed("jump"):
  jump_buffer = JUMP_BUFFER_TIME
 jump_buffer = maxf(0.0, jump_buffer - delta)
 var axis := Input.get_axis("move_left", "move_right")
 if absf(axis) > 0.01:
  facing = 1 if axis > 0 else -1
  velocity.x = move_toward(velocity.x, axis * SPEED, ACCELERATION * delta)
 else:
  velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
 if jump_buffer > 0 and coyote_timer > 0:
  velocity.y = JUMP_SPEED
  jump_buffer = 0.0
  coyote_timer = 0.0
 velocity.y += GRAVITY * delta
 if Input.is_action_just_released("jump") and velocity.y < MIN_RELEASE_JUMP_SPEED:
  velocity.y = MIN_RELEASE_JUMP_SPEED
 var was_grounded := is_on_floor()
 var fall_speed := velocity.y
 var previous_bottom := global_position.y + 21.0
 move_and_slide()
 var did_stomp := _resolve_stomp(previous_bottom, fall_speed)
 if not did_stomp and not was_grounded and is_on_floor() and ground_bounce_pending and _landed_on_ground():
  ground_bounce_pending = false
  ground_bounce_count += 1
  velocity.y = STOMP_GROUND_BOUNCE
 _was_on_floor = is_on_floor()
 if Input.is_action_just_pressed("attack") and hammer_timer <= 0:
  hammer_timer = ATTACK_COOLDOWN
  attack_active = ATTACK_ACTIVE_TIME
  _hammer_hit_sent = false
  attack_visual_timer = ATTACK_VISUAL_DURATION
  attack_facing = facing
  if is_instance_valid(attack_sprite):
   attack_sprite.stop()
   attack_sprite.play("attack")
   # Drive all twelve frames with the visual clock, independent of render FPS.
   attack_sprite.pause()
 if attack_active > 0 and not _hammer_hit_sent:
  _hammer_hit_sent = true
  hammer_used.emit(get_hammer_hitbox())
 if Input.is_action_just_pressed("craft"):
  box_requested.emit()
 if global_position.y > pit_warning_y and velocity.y > 0 and not is_on_floor() and not pit_announced:
  pit_announced = true
  pit_falling.emit()
 if global_position.y > fall_death_y:
  _die("pit")
 _update_animation(axis)
 queue_redraw()

func get_hammer_hitbox() -> Rect2:
 var left := 13.0 if facing > 0 else -13.0-HAMMER_REACH
 return Rect2(global_position+Vector2(left,-16),Vector2(HAMMER_REACH,HAMMER_HEIGHT))

func take_damage(amount: int = 1, from_x: float = 0.0) -> void:
 if health <= 0 or invincible_timer > 0.0 or stomp_contact_grace > 0 or not controls_enabled:
  return
 health = maxi(0, health - amount)
 invincible_timer = INVULNERABILITY
 velocity.x = 215.0 if global_position.x >= from_x else -215.0
 velocity.y = -190.0
 health_changed.emit(health)
 if health <= 0:
  _die("damage")

func _die(cause: String) -> void:
 if death_cause != "": return
 health = 0
 controls_enabled = false
 death_cause = cause
 death_elapsed = 0
 attack_visual_timer = 0
 health_changed.emit(health)
 died.emit()

func _resolve_stomp(previous_bottom: float, fall_speed: float) -> bool:
 if fall_speed <= 0 or stomp_contact_grace > 0: return false
 for index in range(get_slide_collision_count()):
  var contact := get_slide_collision(index)
  var enemy = contact.get_collider()
  if not is_instance_valid(enemy) or not enemy.is_in_group("enemy"): continue
  if not enemy.alive or contact.get_normal().y > -0.5: continue
  var top: float = enemy.global_position.y - (12.0 if enemy.kind == "ave" else 13.0)
  if previous_bottom > top + 6.0: continue
  # One damage per landing. The grace prevents the same overlap hitting again.
  enemy.damage_recovery = 0.0
  enemy.take_hit(1, global_position.x)
  velocity.y = STOMP_REBOUND
  stomp_contact_grace = 0.16
  stomp_visual_timer = STOMP_VISUAL_DURATION
  ground_bounce_pending = true
  ground_bounce_count = 0
  if is_instance_valid(stomp_sprite):
   stomp_sprite.animation = "stomp"
   stomp_sprite.frame = 0
  stomped.emit()
  return true
 return false

func _landed_on_ground() -> bool:
 for index in range(get_slide_collision_count()):
  var contact := get_slide_collision(index)
  var body = contact.get_collider()
  if contact.get_normal().y < -0.5 and is_instance_valid(body) and not body.is_in_group("enemy"):
   return true
 return false

func _draw() -> void:
 if _visual_ready: return
 if invincible_timer > 0.0 and int(Time.get_ticks_msec() / 90) % 2 == 0:
  return
 # Placeholder matching the intended bunny: no clothes, worn scarf and satchel.
 draw_rect(Rect2(-13,-46,10,26), Color("fff0dd"))
 draw_rect(Rect2(3,-50,10,30), Color("fff0dd"))
 draw_rect(Rect2(-10,-43,4,17), Color("f2a2ad"))
 draw_rect(Rect2(6,-47,4,19), Color("f2a2ad"))
 draw_rect(Rect2(-17,-26,35,35), Color("fff3e2"))
 draw_rect(Rect2(-18,3,10,13), Color("fff3e2"))
 draw_rect(Rect2(7,3,11,13), Color("fff3e2"))
 draw_rect(Rect2(-17,-16,35,6), Color("a94542"))
 draw_colored_polygon(PackedVector2Array([Vector2(-8,-12),Vector2(-27,-6),Vector2(-24,2),Vector2(-9,-5)]),Color("ad4842"))
 draw_rect(Rect2(-18,-1,9,13), Color("916339"))
 draw_rect(Rect2(-14,-3,7,3), Color("c18d53"))
 draw_rect(Rect2(6 if facing > 0 else -11,-19,5,5), Color("2c2932"))
 draw_rect(Rect2(13 if facing > 0 else -17,-11,4,4), Color("db8b8c"))
 var hx := 24.0 if facing > 0 else -24.0
 draw_line(Vector2(hx,-11),Vector2(hx,-30),Color("86603e"),5.0)
 draw_rect(Rect2(hx-10,-34,20,11),Color("bd874c"))
 draw_rect(Rect2(hx-10,-34,20,3),Color("d9b77d"))
 if hammer_timer > ATTACK_COOLDOWN - ATTACK_ACTIVE_TIME:
  draw_arc(Vector2(facing*29,-19),24,-1.1,1.2,10,Color("f7dc79"),3)

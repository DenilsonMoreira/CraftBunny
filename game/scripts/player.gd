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

@export_group("Dash")
@export var dash_speed := 600.0
@export var dash_duration := 0.16
@export var dash_cooldown := 0.8
@export var dash_attack_buffer_time := 0.12
@export_group("Lenço")
@export var glide_double_tap_window := 0.35
@export var glide_duration := 1.0
@export var glide_fall_speed := 70.0

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var air_dash_used := false
var dash_direction := 1
var buffered_attack := 0.0
var gliding := false
var glide_remaining := 1.0
var glide_requested := false
var jump_tap_timer := 0.0
var jumped_this_airtime := false
var second_tap_used := false
var jump_press_pending := false
var dash_press_pending := false
var dash_elapsed := 0.0
var dash_visual_timer := 0.0
const DASH_VISUAL_DURATION := 0.24
var glide_visual_elapsed := 0.0
var glide_release_timer := 0.0
var mobility_sprite: AnimatedSprite2D
var movement_fx: Node2D
var dash_audio: AudioStreamPlayer
@export var dash_sound: AudioStream

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
 glide_remaining = glide_duration
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
 movement_fx = preload("res://scripts/movement_fx.gd").new()
 add_child(movement_fx)
 dash_audio = AudioStreamPlayer.new()
 dash_audio.bus = "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master"
 dash_audio.stream = dash_sound if dash_sound != null else load("res://assets/audio/sfx/dash_placeholder.wav")
 dash_audio.volume_db = -12.0
 add_child(dash_audio)

func _input(event: InputEvent) -> void:
 handle_movement_input(event)

func handle_movement_input(event: InputEvent) -> void:
 # Events, including touch InputEventAction, distinguish taps from a held key.
 if not controls_enabled or health <= 0 or event.is_echo(): return
 if event.is_action_pressed("jump"): jump_press_pending = true
 if event.is_action_released("jump"): glide_requested = false
 if event.is_action_pressed("dash"): dash_press_pending = true

func _reset_air_abilities() -> void:
 air_dash_used = false
 glide_remaining = glide_duration
 glide_requested = false
 gliding = false
 jumped_this_airtime = false
 second_tap_used = false
 jump_tap_timer = 0.0

func _cancel_mobility() -> void:
 dash_timer = 0.0
 dash_visual_timer = 0.0
 glide_release_timer = 0.0
 gliding = false
 glide_requested = false
 buffered_attack = 0.0
 jump_press_pending = false
 dash_press_pending = false

func _try_dash() -> void:
 if dash_timer > 0 or dash_cooldown_timer > 0 or attack_visual_timer > 0 or (not is_on_floor() and air_dash_used): return
 dash_direction = facing
 dash_timer = dash_duration
 dash_elapsed = 0.0
 dash_visual_timer = DASH_VISUAL_DURATION
 dash_cooldown_timer = dash_cooldown
 if not is_on_floor(): air_dash_used = true
 gliding = false
 movement_fx.start_dash(is_on_floor())
 dash_audio.play()

func _begin_attack() -> void:
 hammer_timer = ATTACK_COOLDOWN
 attack_active = ATTACK_ACTIVE_TIME
 _hammer_hit_sent = false
 attack_visual_timer = ATTACK_VISUAL_DURATION
 attack_facing = facing
 if is_instance_valid(attack_sprite):
  attack_sprite.stop()
  attack_sprite.play("attack")
  attack_sprite.pause()

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
 mobility_sprite = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v3/bunny_dash_12.png", {
  "idle": [0], "dash": range(12)
 }, Vector2(74,60), 21.0, false, Vector2i(4,3))
 if mobility_sprite != null:
  var idle_pose := animated_sprite.sprite_frames.get_frame_texture("idle",0) as AtlasTexture
  var normal_pose_height := idle_pose.region.size.y*animated_sprite.scale.y
  var glide := preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v3/bunny_glide_12.png", {
   "idle": [0], "glide": range(12)
  }, Vector2(64,54), 21.0, false, Vector2i(4,3), PackedVector2Array(),normal_pose_height)
  if glide != null:
   # Copy frames; both sheets use the same cell dimensions. Per-animation
   # scale/position below preserves the helper's alpha-bound calibration.
   mobility_sprite.sprite_frames.add_animation("glide")
   for index in range(12):
    mobility_sprite.sprite_frames.add_frame("glide",glide.sprite_frames.get_frame_texture("glide",index))
   mobility_sprite.set_meta("glide_scale",glide.scale)
   mobility_sprite.set_meta("glide_position",glide.position)
   glide.free()
  mobility_sprite.set_meta("dash_scale",mobility_sprite.scale)
  mobility_sprite.set_meta("dash_position",mobility_sprite.position)
  mobility_sprite.visible = false
  add_child(mobility_sprite)

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
 if is_instance_valid(mobility_sprite):
  var show_dash := dash_visual_timer > 0.0
  var show_glide := gliding or glide_release_timer > 0.0
  mobility_sprite.visible = health > 0 and invincible_timer <= 0 and attack_visual_timer <= 0 and stomp_visual_timer <= 0 and (show_dash or show_glide)
  if mobility_sprite.visible:
   var action := "dash" if show_dash else "glide"
   mobility_sprite.animation = action
   mobility_sprite.pause()
   mobility_sprite.scale = mobility_sprite.get_meta(action+"_scale")
   mobility_sprite.position = mobility_sprite.get_meta(action+"_position")
   mobility_sprite.flip_h = (dash_direction if show_dash else facing) < 0
   if show_dash:
    mobility_sprite.frame = mini(11,int((DASH_VISUAL_DURATION-dash_visual_timer)*12.0/DASH_VISUAL_DURATION))
   elif gliding:
    mobility_sprite.frame = mini(2,int(glide_visual_elapsed/0.04)) if glide_visual_elapsed < 0.12 else 3+int((glide_visual_elapsed-0.12)/0.06)%6
   else:
    mobility_sprite.frame = mini(11,9+int((0.12-glide_release_timer)/0.04))
   animated_sprite.visible = false

func _tick_mobility_visual(delta: float, was_gliding: bool) -> void:
 dash_visual_timer = maxf(0.0,dash_visual_timer-delta)
 glide_release_timer = maxf(0.0,glide_release_timer-delta)
 if gliding:
  glide_visual_elapsed = glide_visual_elapsed+delta if was_gliding else 0.0
 elif was_gliding and dash_timer <= 0:
  glide_release_timer = 0.12

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
  if is_instance_valid(mobility_sprite): mobility_sprite.visible = false
  if is_instance_valid(death_sprite):
   death_sprite.visible = true
   death_sprite.flip_h = facing < 0
   death_sprite.animation = "death"
   death_sprite.pause()
   death_sprite.frame = mini(7, int(death_elapsed * 8.0 / DEATH_VISUAL_DURATION))
  return
 if not controls_enabled:
  # Pause freezes budgets, but queued button presses must never leak into resume.
  jump_press_pending = false
  dash_press_pending = false
  buffered_attack = 0.0
  if not Input.is_action_pressed("jump"): glide_requested = false
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
 dash_cooldown_timer = maxf(0.0, dash_cooldown_timer-delta)
 buffered_attack = maxf(0.0, buffered_attack-delta)
 jump_tap_timer = maxf(0.0, jump_tap_timer-delta)
 if is_on_floor():
  coyote_timer = COYOTE_TIME
  if not _was_on_floor and _landed_on_ground(): _reset_air_abilities()
 else:
  coyote_timer = maxf(0.0, coyote_timer - delta)
 if jump_press_pending or Input.is_action_just_pressed("jump"):
  if jump_press_pending and jumped_this_airtime and not is_on_floor() and not second_tap_used and jump_tap_timer > 0.0:
   second_tap_used = true
   glide_requested = Input.is_action_pressed("jump")
  else:
   jump_buffer = JUMP_BUFFER_TIME
 jump_press_pending = false
 jump_buffer = maxf(0.0, jump_buffer - delta)
 var axis := Input.get_axis("move_left", "move_right")
 var was_gliding := gliding
 if dash_press_pending or Input.is_action_just_pressed("dash"): _try_dash()
 dash_press_pending = false
 var dashing := dash_timer > 0.0
 if dashing:
  velocity.x = dash_direction * dash_speed
 elif absf(axis) > 0.01:
  facing = 1 if axis > 0 else -1
  velocity.x = move_toward(velocity.x, axis * SPEED, ACCELERATION * delta)
 else:
  velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
 if jump_buffer > 0 and coyote_timer > 0:
  velocity.y = JUMP_SPEED
  jumped_this_airtime = true
  second_tap_used = false
  jump_tap_timer = glide_double_tap_window
  jump_buffer = 0.0
  coyote_timer = 0.0
 velocity.y += GRAVITY * delta
 gliding = not dashing and not is_on_floor() and velocity.y >= 0.0 and glide_requested and Input.is_action_pressed("jump") and glide_remaining > 0.0
 if gliding:
  # Never boost upward; only cap downward speed, spending one budget per airtime.
  velocity.y = minf(velocity.y, glide_fall_speed)
  glide_remaining = maxf(0.0, glide_remaining-delta)
 if Input.is_action_just_released("jump") and velocity.y < MIN_RELEASE_JUMP_SPEED:
  velocity.y = MIN_RELEASE_JUMP_SPEED
 var was_grounded := is_on_floor()
 var fall_speed := velocity.y
 var previous_bottom := global_position.y + 21.0
 move_and_slide()
 if dashing:
  dash_timer = maxf(0.0, dash_timer-delta)
  dash_elapsed += delta
  if is_on_wall(): dash_timer = 0.0
  # A ground dash leaving a ledge consumes the same aerial charge.
  if not is_on_floor(): air_dash_used = true
 if is_on_floor() and not was_grounded and _landed_on_ground(): _reset_air_abilities()
 # Dash itself never deals damage, including incidental top contacts.
 var did_stomp := false if dashing else _resolve_stomp(previous_bottom, fall_speed)
 if not did_stomp and not was_grounded and is_on_floor() and ground_bounce_pending and _landed_on_ground():
  ground_bounce_pending = false
  ground_bounce_count += 1
  velocity.y = STOMP_GROUND_BOUNCE
 _was_on_floor = is_on_floor()
 if Input.is_action_just_pressed("attack"):
  if dashing:
   buffered_attack = dash_attack_buffer_time
  elif hammer_timer <= 0:
   _begin_attack()
 if dash_timer <= 0 and buffered_attack > 0 and hammer_timer <= 0:
  buffered_attack = 0.0
  _begin_attack()
 if attack_active > 0 and not _hammer_hit_sent:
  _hammer_hit_sent = true
  hammer_used.emit(get_hammer_hitbox())
 if Input.is_action_just_pressed("craft") and not dashing:
  box_requested.emit()
 if global_position.y > pit_warning_y and velocity.y > 0 and not is_on_floor() and not pit_announced:
  pit_announced = true
  pit_falling.emit()
 if global_position.y > fall_death_y:
  _die("pit")
 _tick_mobility_visual(delta,was_gliding)
 _update_animation(axis)
 queue_redraw()

func get_hammer_hitbox() -> Rect2:
 var left := 13.0 if facing > 0 else -13.0-HAMMER_REACH
 return Rect2(global_position+Vector2(left,-16),Vector2(HAMMER_REACH,HAMMER_HEIGHT))

func take_damage(amount: int = 1, from_x: float = 0.0) -> void:
 if health <= 0 or invincible_timer > 0.0 or stomp_contact_grace > 0 or not controls_enabled:
  return
 health = maxi(0, health - amount)
 _cancel_mobility()
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
 _cancel_mobility()
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

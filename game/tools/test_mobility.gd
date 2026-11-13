extends SceneTree
const DT := 1.0/60.0
var failures := 0
var checks := 0
var world: Node2D
var p: CharacterBody2D
var attacks := 0
var crafts := 0

func check(value: bool, label: String) -> void:
 checks += 1
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)

func _initialize() -> void: call_deferred("_run")

func ticks(count: int) -> void:
 for index in range(count):
  await physics_frame
  await process_frame

func action(name: String, pressed: bool) -> void:
 var event := InputEventAction.new()
 event.action = name
 event.pressed = pressed
 Input.parse_input_event(event)

func solid(at: Vector2, size: Vector2) -> StaticBody2D:
 var body := StaticBody2D.new()
 var collision := CollisionShape2D.new()
 var shape := RectangleShape2D.new()
 shape.size = size
 collision.shape = shape
 body.add_child(collision)
 body.position = at
 world.add_child(body)
 return body

func fresh(grounded := true) -> void:
 for key in ["jump","dash","attack","craft","move_left","move_right"]: action(key,false)
 if is_instance_valid(world):
  world.queue_free()
  await process_frame
 world = Node2D.new()
 root.add_child(world)
 solid(Vector2(0,470),Vector2(20000,70))
 p = preload("res://scripts/player.gd").new()
 p.position = Vector2(100,414 if grounded else -200)
 p.fall_death_y = 5000
 p.pit_warning_y = 4000
 world.add_child(p)
 p.controls_enabled = true
 p.hammer_used.connect(func(_rect): attacks += 1)
 p.box_requested.connect(func(): crafts += 1)
 attacks = 0
 crafts = 0
 await ticks(3)

func double_tap() -> void:
 action("jump",true)
 await ticks(2)
 action("jump",false)
 await ticks(2)
 action("jump",true)
 await ticks(1)

func _run() -> void:
 for binding in {"jump":KEY_SPACE,"dash":KEY_I,"attack":KEY_J,"craft":KEY_K,"move_left":KEY_A,"move_right":KEY_D}:
  if not InputMap.has_action(binding): InputMap.add_action(binding)
 await fresh()
 var start: Vector2 = p.position
 action("dash",true)
 await ticks(1)
 check(p.dash_timer > 0 and is_equal_approx(p.velocity.x,600.0),"ground dash uses 600 px/s without multiplying velocity by delta")
 check(p.invincible_timer == 0 and p.health == 3 and attacks == 0,"dash grants no invulnerability or attack")
 check(p.movement_fx.dust_time > 0 and p.dash_audio.playing,"ground dash emits dust and replaceable SFX")
 await ticks(8)
 check(p.movement_fx.ghosts.size() in range(2,4),"dash has two or three translucent afterimages")
 await ticks(2)
 check(p.dash_timer == 0 and p.position.x-start.x >= 85 and p.position.x-start.x <= 110,"dash lasts about .16 s and travels about 96 px")
 var speed: float = p.velocity.x
 await ticks(1)
 check(p.velocity.x < speed and p.velocity.x > 0,"dash returns with gradual deceleration")
 action("dash",false)
 action("dash",true)
 await ticks(1)
 check(p.dash_timer == 0,"ground cooldown blocks immediate repeated dash")
 await ticks(48)
 action("dash",false)
 p.facing = -1
 action("dash",true)
 await ticks(1)
 check(p.velocity.x == -600,"dash follows facing left")

 await fresh()
 action("jump",true)
 action("dash",true)
 await ticks(1)
 check(p.dash_timer > 0 and p.velocity.y < 0 and p.air_dash_used,"simultaneous jump and dash preserve both actions")

 await fresh(false)
 p.position.y = -1000
 action("dash",true)
 await ticks(1)
 check(p.air_dash_used and p.dash_timer > 0,"air dash consumes one airborne charge")
 await ticks(53)
 # Still airborne from a high start; the cooldown has expired.
 action("dash",false)
 action("dash",true)
 await ticks(1)
 check(not p.is_on_floor() and p.dash_timer == 0 and p.air_dash_used,"second air dash rejected even after cooldown")
 for tick in range(180):
  if p.is_on_floor(): break
  await ticks(1)
 check(p.is_on_floor() and not p.air_dash_used and p.glide_remaining == p.glide_duration,"landing replenishes air dash and glide")
 action("dash",false)
 action("dash",true)
 await ticks(1)
 check(p.dash_timer > 0,"dash works again after landing")

 await fresh()
 var wall := solid(Vector2(165,380),Vector2(20,130))
 await ticks(2)
 action("dash",true)
 var hit_wall := false
 for tick in range(10):
  await ticks(1)
  hit_wall = hit_wall or p.is_on_wall()
 check(p.position.x <= 142.1 and p.dash_timer == 0 and hit_wall,"dash collides with wall without tunneling")
 wall.queue_free()

 await fresh()
 action("jump",true)
 await ticks(3)
 check(p.velocity.y < 0 and not p.glide_requested and not p.gliding,"first tap only jumps")
 var initial_jump: float = p.velocity.y
 action("jump",false)
 await ticks(2)
 action("jump",true)
 await ticks(1)
 check(p.glide_requested and p.second_tap_used and not p.gliding and p.velocity.y < 0,"second event during ascent queues glide without upward impulse")
 check(p.velocity.y > initial_jump,"second tap cannot add jump height")
 await ticks(18)
 check(p.gliding and p.velocity.y >= 0 and p.velocity.y <= 70,"glide activates only when descending and caps fall speed")
 check(p.invincible_timer == 0 and attacks == 0,"glide neither attacks nor grants invulnerability")
 var remaining: float = p.glide_remaining
 action("jump",false)
 await ticks(3)
 check(not p.gliding and p.velocity.y > 70 and p.glide_remaining == remaining,"releasing jump resumes normal fall without replenishing budget")

 await fresh(false)
 # Simulate an already initiated jump at height so duration can be measured.
 p.jumped_this_airtime = true
 p.jump_tap_timer = .3
 action("jump",true)
 await ticks(1)
 check(p.gliding,"second tap during descent starts glide immediately")
 await ticks(62)
 check(p.glide_remaining == 0 and not p.gliding and p.velocity.y > 70,"glide expires at one second even while held")
 action("jump",false)
 action("jump",true)
 await ticks(2)
 check(p.glide_remaining == 0 and not p.gliding,"third tap cannot reset glide in midair")

 await fresh(false)
 p.jumped_this_airtime = true
 p.jump_tap_timer = .01
 await ticks(2)
 action("jump",true)
 await ticks(1)
 check(not p.glide_requested,"late second tap outside .35 s is rejected")
 await fresh()
 await double_tap()
 action("dash",true)
 await ticks(1)
 check(p.dash_timer > 0 and not p.gliding and p.glide_requested,"jump plus dash suspends queued glide")
 await ticks(20)
 check(p.gliding and p.air_dash_used and p.glide_remaining < 1,"jump dash glide combination resumes descending glide")

 await fresh(false)
 p.jumped_this_airtime = true
 p.jump_tap_timer = .3
 action("jump",true)
 await ticks(5)
 var before_dash: float = p.glide_remaining
 action("dash",true)
 await ticks(5)
 check(not p.gliding and p.glide_remaining == before_dash,"dash suspends active glide without resetting or spending its remaining budget")
 await ticks(7)
 check(p.gliding and p.glide_remaining < before_dash and p.glide_remaining > 0,"active glide resumes after dash with original remaining budget")

 await fresh()
 action("dash",true)
 await ticks(2)
 action("attack",true)
 action("craft",true)
 await ticks(1)
 check(attacks == 0 and crafts == 0,"hammer and building blocked during dash")
 action("attack",false)
 action("craft",false)
 await ticks(7)
 check(attacks == 1 and crafts == 0,"attack requested within .12 s is buffered until dash ends; build is not queued")
 await ticks(30)
 action("attack",true)
 action("craft",true)
 await ticks(1)
 check(attacks == 2 and crafts == 1,"hammer and building work normally afterward")
 await fresh()
 action("dash",true)
 action("attack",true)
 await ticks(15)
 check(attacks == 0,"attack buffer expires if requested too early in dash")

 await fresh()
 action("dash",true)
 await ticks(1)
 p.take_damage(1,p.position.x-20)
 check(p.health == 2 and p.dash_timer == 0 and p.velocity.y < 0,"damage cancels dash and applies normal knockback")
 p.take_damage(1)
 check(p.health == 2,"existing damage invulnerability still blocks repeated hits")
 await fresh(false)
 p.jumped_this_airtime = true
 p.jump_tap_timer = .3
 action("jump",true)
 await ticks(1)
 p.take_damage(1)
 check(p.health == 2 and not p.gliding and not p.glide_requested,"damage interrupts glide")
 p.invincible_timer = 0
 p.take_damage(3)
 check(p.health == 0 and not p.controls_enabled and p.dash_timer == 0,"death cancels abilities")

 await fresh()
 # Event echo cannot count as the second press.
 action("jump",true)
 await ticks(2)
 var echo := InputEventKey.new()
 echo.physical_keycode = KEY_SPACE
 echo.pressed = true
 echo.echo = true
 p._input(echo)
 await ticks(1)
 check(not p.glide_requested,"keyboard repeat is not a second tap")
 action("jump",false)
 await ticks(45)
 # Preserve jump-buffer and coyote paths using the existing timers.
 p.position = Vector2(100,390)
 p.velocity = Vector2(0,170)
 await ticks(1)
 action("jump",true)
 await ticks(8)
 check(p.velocity.y < 0 and not p.is_on_floor(),"normal landing jump buffer preserved")
 action("jump",false)
 await ticks(45)
 p.position.y -= 2
 await ticks(1)
 action("jump",true)
 await ticks(1)
 check(p.velocity.y < -300,"coyote jump preserved")
 check(p.mobility_sprite.sprite_frames.get_frame_count("dash") == 12 and p.mobility_sprite.sprite_frames.get_frame_count("glide") == 12,"both new animations have twelve frames")
 for key in ["jump","dash","attack","craft","move_left","move_right"]: action(key,false)
 world.queue_free()
 await process_frame
 print("MOBILITY_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures == 0 else 1)

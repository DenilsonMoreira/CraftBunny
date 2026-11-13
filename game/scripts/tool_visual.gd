extends Node2D
## Modular technical placeholder. Final SpriteFrames use tool/state names.
const TOOLS = preload("res://scripts/tool_catalog.gd")
const ICONS = preload("res://scripts/tool_icons.gd")
var final_frames: SpriteFrames
var final_sprite: AnimatedSprite2D
var animation_key := "hammer/idle"
var frame := 0
var clock := 0.0
var available_animations := TOOLS.animation_names()
var trajectory_points := PackedVector2Array()
var draw_placeholder := false

func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 if final_frames != null:
  final_sprite = AnimatedSprite2D.new()
  final_sprite.sprite_frames = final_frames
  add_child(final_sprite)

func _physics_process(delta: float) -> void:
 var p = get_parent()
 if p.controls_enabled: clock += delta
 var state := "idle"
 var progress := fmod(clock,1.2)/1.2
 if p.switch_remaining > 0:
  state = "switch"
  progress = 1.0-p.switch_remaining/TOOLS.SWITCH_DURATION
 elif p.attack_visual_timer > 0:
  state = "attack"
  progress = 1.0-p.attack_visual_timer/p.attack_total
 elif p.dash_visual_timer > 0:
  state = "dash"
  progress = 1.0-p.dash_visual_timer/p.DASH_VISUAL_DURATION
 elif p.gliding:
  state = "glide"
 elif not p.is_on_floor(): state = "jump" if p.velocity.y < 0 else "fall"
 elif absf(p.velocity.x)>5:
  state = "run"
  progress = fmod(clock,.6)/.6
 var next_key: String = TOOLS.KEYS[p.equipped_tool]+"/"+state
 if next_key != animation_key and state in ["idle","run","jump","fall","glide"]:
  clock = 0
  progress = 0
 frame = clampi(int(progress*12),0,11)
 animation_key = next_key
 var has_final: bool = final_frames != null and final_frames.has_animation(animation_key) and final_frames.get_frame_count(animation_key)>0
 var custom: bool = (p.equipped_tool != TOOLS.Type.HAMMER or p.switch_remaining > 0 or has_final) and p.health > 0
 var blink: bool = p.invincible_timer <= 0 or int(Time.get_ticks_msec()/90)%2 != 0
 draw_placeholder = custom and blink
 if custom:
  p.animated_sprite.hide()
  for sprite in [p.attack_sprite,p.mobility_sprite,p.stomp_sprite]:
   if is_instance_valid(sprite): sprite.hide()
 if is_instance_valid(final_sprite):
  final_sprite.visible = custom and blink and has_final
  if has_final:
   final_sprite.animation = animation_key
   final_sprite.pause()
   final_sprite.frame = mini(frame,final_frames.get_frame_count(animation_key)-1)
   final_sprite.flip_h = p.facing < 0
   if custom: draw_placeholder = false
 trajectory_points.clear()
 if p.aiming and p.controls_enabled:
  var origin: Vector2 = p.sling_origin()
  var velocity: Vector2 = p.sling_velocity()
  trajectory_points.append(origin-p.global_position)
  for index in range(1,27):
   var t := float(index)*.045
   var point := origin+velocity*t+Vector2(0,TOOLS.PROJECTILE_GRAVITY*.5*t*t)
   var previous: Vector2 = trajectory_points[-1]+p.global_position
   var query := PhysicsRayQueryParameters2D.create(previous,point,1,[p.get_rid()])
   var hit: Dictionary = p.get_world_2d().direct_space_state.intersect_ray(query)
   trajectory_points.append((hit["position"] if not hit.is_empty() else point)-p.global_position)
   if not hit.is_empty(): break
 queue_redraw()

func _draw() -> void:
 for index in range(1,trajectory_points.size()):
  draw_circle(trajectory_points[index],1.5,Color(1,.88,.45,.9))
 if not draw_placeholder: return
 var p = get_parent()
 var phase := float(frame)/12.0*TAU
 var state: String = animation_key.get_slice("/",1)
 var step := sin(phase)*3 if state=="run" else 0.0
 var crouch := 4.0 if state=="dash" else 0.0
 var cream := Color("fff0d5")
 var edge := Color("493027")
 const BODY_SCALE := 0.74
 draw_set_transform(Vector2(0,21*(1-BODY_SCALE)),0,Vector2(p.facing*BODY_SCALE,BODY_SCALE))
 # Pixel silhouette: bare rabbit, red worn scarf, satchel, coherent 42 px body.
 draw_rect(Rect2(-12,-9+crouch,25,28-crouch),edge)
 draw_rect(Rect2(-10,-7+crouch,21,23-crouch),cream)
 draw_rect(Rect2(-13+step,15,11,6),edge)
 draw_rect(Rect2(4-step,15,13,6),edge)
 draw_rect(Rect2(-12+step,16,9,4),cream)
 draw_rect(Rect2(5-step,16,11,4),cream)
 draw_rect(Rect2(-14,-29+crouch,30,25),edge)
 draw_rect(Rect2(-12,-27+crouch,26,21),cream)
 for x in [-10,3]:
  var tilt := -4.0 if state in ["run","dash"] else sin(phase)*.5
  draw_colored_polygon(PackedVector2Array([Vector2(x,-26+crouch),Vector2(x+tilt-3,-49+crouch),Vector2(x+tilt+4,-51+crouch),Vector2(x+8,-27+crouch)]),edge)
  draw_rect(Rect2(x,-46+crouch,4,17),Color("eeb0a0"))
 draw_rect(Rect2(7,-20+crouch,3,5),Color("302622"))
 draw_rect(Rect2(12,-12+crouch,4,3),Color("da9390"))
 draw_rect(Rect2(-13,-8+crouch,25,5),Color("a63e37"))
 var spread := 14.0 if state=="glide" else 0.0
 draw_colored_polygon(PackedVector2Array([Vector2(-8,-6),Vector2(-29-spread,-8+sin(phase)*2),Vector2(-24-spread,1),Vector2(-11,1)]),Color("b84a3d"))
 if state=="glide":
  draw_line(Vector2(-19,-7),Vector2(21,-7),Color("a63e37"),6)
  draw_line(Vector2(-8,-1),Vector2(-18,-7),cream,5)
 draw_line(Vector2(6,-4),Vector2(-12,10),Color("775032"),3)
 draw_rect(Rect2(-16,4,11,13),Color("6e452c"))
 draw_rect(Rect2(-14,5,8,7),Color("b78041"))
 var hand := Vector2(16,-1+crouch)
 var angle := 0.0
 if state=="attack":
  var cfg: Dictionary = TOOLS.DATA[p.attack_tool]
  var elapsed: float = float(frame)/11.0*p.attack_total
  var windup: float = cfg["windup"]
  var active: float = cfg["active"]
  if elapsed < windup and windup>0:
   var t := elapsed/windup
   hand = Vector2(13,lerpf(-1,-20,t))
   angle = lerpf(0,-1.8,t)
  elif elapsed < windup+active and active>0:
   var t := (elapsed-windup)/active
   hand = Vector2(16,lerpf(-20,2,t))
   angle = lerpf(-1.8,1.2,t)
  else:
   var t := clampf((elapsed-windup-active)/maxf(.01,p.attack_total-windup-active),0,1)
   hand = Vector2(16,lerpf(2,-1,t))
   angle = lerpf(1.2,0,t)
 elif state=="switch":
  hand = Vector2(lerpf(-10,16,float(frame)/11.0),3-sin(float(frame)/11.0*PI)*10)
 draw_line(Vector2(6,-1+crouch),hand,edge,7)
 draw_line(Vector2(6,-1+crouch),hand,cream,5)
 draw_set_transform(Vector2.ZERO)
 ICONS.draw_icon(self,TOOLS.KEYS[p.equipped_tool],Vector2(hand.x*p.facing*BODY_SCALE,21+(hand.y-21)*BODY_SCALE),.75*BODY_SCALE,angle*p.facing)

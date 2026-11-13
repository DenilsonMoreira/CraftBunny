extends SceneTree
var failures := 0

class FrameProbe extends Node:
 var player: CharacterBody2D
 var dash_frames := {}
 var glide_frames := {}
 func _physics_process(_delta: float) -> void:
  var sprite: AnimatedSprite2D = player.mobility_sprite
  if not sprite.visible: return
  if sprite.animation == "dash": dash_frames[sprite.frame] = true
  if sprite.animation == "glide": glide_frames[sprite.frame] = true

func _initialize() -> void: call_deferred("_run")

func action(name: String, pressed: bool) -> void:
 var event := InputEventAction.new()
 event.action = name
 event.pressed = pressed
 Input.parse_input_event(event)

func ticks(count: int) -> void:
 for index in range(count):
  await physics_frame
  await process_frame

func capture(label: String) -> void:
 await RenderingServer.frame_post_draw
 var path := ProjectSettings.globalize_path("res://../docs/qa_mobility_"+label+".png")
 if root.get_texture().get_image().save_png(path) != OK: failures += 1

func _run() -> void:
 # Slow motion for visual inspection; normal-speed timing is tested separately.
 Engine.time_scale = 0.25
 var game = load("res://main.tscn").instantiate()
 game.controls_file = "user://qa_mobility_controls.cfg"
 game.settings_file = "user://qa_mobility_settings.cfg"
 game.records_file = "user://qa_mobility_records.cfg"
 root.add_child(game)
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 var p = game.player
 var probe := FrameProbe.new()
 probe.player = p
 p.add_child(probe)
 await ticks(5)
 action("move_right",true)
 await ticks(12)
 action("dash",true)
 var captured_dash := false
 for tick in range(120):
  await ticks(1)
  if not captured_dash and p.dash_elapsed >= .07:
   captured_dash = true
   await capture("dash")
  if p.dash_visual_timer <= 0: break
 action("dash",false)
 action("move_right",false)
 await ticks(40)
 p.position = Vector2(120,-340)
 p.velocity = Vector2.ZERO
 await ticks(2)
 # Queued second-tap descent, with sufficient height to observe the full cycle.
 p.jumped_this_airtime = true
 p.jump_tap_timer = .3
 action("jump",true)
 for tick in range(170):
  await ticks(1)
  if tick == 65: await capture("glide")
 action("jump",false)
 for tick in range(40):
  await ticks(1)
 var dash_frames := probe.dash_frames
 var glide_frames := probe.glide_frames
 if dash_frames.size() != 12:
  failures += 1
  push_error("dash frames observed: "+str(dash_frames.keys()))
 if glide_frames.size() != 12:
  failures += 1
  push_error("glide frames observed: "+str(glide_frames.keys()))
 print("MOBILITY_VISUAL dash_frames=",dash_frames.size()," glide_frames=",glide_frames.size()," failures=",failures)
 game.queue_free()
 await process_frame
 quit(failures)

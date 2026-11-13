extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("_run")
func check(value: bool,label: String) -> void:
 checks += 1
 if not value:
  failures += 1
  push_error(label)
func ticks(count: int) -> void:
 for i in range(count):
  await physics_frame
  await process_frame
func capture_tool(tool: int) -> void:
 await process_frame
 await RenderingServer.frame_post_draw
 var path := ProjectSettings.globalize_path("user://qa_export_tool_%d_052.png" % tool)
 check(root.get_texture().get_image().save_png(path)==OK,"exported tool screenshot "+str(tool))
 print("EXPORT_CAPTURE=",path)
func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 game.controls_file = "user://qa_presentation_controls.cfg"
 game.records_file = "user://qa_presentation_records.cfg"
 game.settings_file = "user://qa_presentation_settings.cfg"
 root.add_child(game)
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 var p = game.player
 await ticks(4)
 check(p.final_tool_frames!=null and p.tool_visual.production_art,"default production resource loaded (including exported remaps)")
 check(p.final_tool_frames.get_animation_names().size()==33,"all final animation states available")
 print("ART_SOURCE_FILE=",FileAccess.file_exists("res://assets/production/v4/tool_frames.tres")," ART_RESOURCE=",ResourceLoader.exists("res://assets/production/v4/tool_frames.tres"))
 p.set_physics_process(false)
 p.tool_visual.set_physics_process(false)
 for tool in range(4):
  p.equipped_tool = tool
  p.velocity = Vector2.ZERO
  p.attack_visual_timer = 0
  p.switch_remaining = 0
  p.tool_visual._physics_process(.016)
  check(p.tool_visual.final_sprite.visible and not p.tool_visual.draw_placeholder,"real equipped body tool "+str(tool))
  check(p.tool_visual.gear_sprite.visible,"real equipped tool layer "+str(tool))
  if tool==0: continue
  p.attack_total = p.TOOLS.DATA[tool]["total"]
  p.attack_tool = tool
  p.attack_visual_timer = p.attack_total*.5
  p._update_animation(0)
  p.tool_visual._physics_process(.016)
  check(p.tool_visual.animation_key==p.TOOLS.KEYS[tool]+"/attack" and p.tool_visual.final_sprite.visible,"real attack tool "+str(tool))
  check(not p.attack_sprite.visible and not p.tool_visual.draw_placeholder,"no hammer or provisional body during alternate attack")
  if "--capture-tools" in OS.get_cmdline_user_args():
   game._update_hud()
   await capture_tool(tool)
  if tool==3:
   p.attack_visual_timer = 0
   p.aiming = true
   p.tool_visual._physics_process(.016)
   check(p.tool_visual.animation_key=="slingshot/aim" and p.tool_visual.final_sprite.visible,"slingshot final aiming pose")
   p.aiming = false
 p.attack_visual_timer = 0
 p.tool_visual._physics_process(.016)
 var tree = get_nodes_in_group("tool_obstacles").filter(func(n):return n.kind=="tree")[0]
 var rock = get_nodes_in_group("tool_obstacles").filter(func(n):return n.kind=="rock")[0]
 check(tree.fall_sound.stream.resource_path.ends_with("falling-tree.mp3") and tree.fall_sound.stream.get_length()>0,"tree fall sound imported")
 check(rock.sound.stream.resource_path.ends_with("rock-falls.mp3") and rock.sound.stream.get_length()>0,"rock hit sound imported")
 check(tree.fall_sound.bus=="SFX" and rock.sound.bus=="SFX","new sounds respect SFX bus")
 tree.apply_tool(1)
 tree.apply_tool(1)
 check(not tree.fall_sound.playing and not tree.falling,"cutting does not start fall sound early")
 tree.apply_tool(1)
 check(tree.falling and tree.fall_sound.playing,"final axe hit starts fall sound once")
 check(not tree.apply_tool(1),"falling tree rejects extra strikes/restarts")
 tree.set_process(false)
 var last_angle := -PI/2
 for i in range(13):
  tree.animation_time = float(i)/12*tree.DROP_DURATION
  var pose: Dictionary = tree.fall_pose()
  check(pose["angle"]>=last_angle and pose["angle"]<=0,"fall rotates progressively toward gap "+str(i))
  last_angle = pose["angle"]
 var landing: Dictionary = tree.fall_pose()
 check(is_zero_approx(landing["crown_alpha"]),"canopy fades before becoming bridge")
 tree.animation_time = tree.FALL_DURATION-.00001
 var before: Dictionary = tree.fall_pose()
 tree.bridge_ready = true
 tree.falling = false
 var after: Dictionary = tree.fall_pose()
 check(before["pivot"].distance_to(after["pivot"])<.01 and absf(before["angle"]-after["angle"])<.001,"continuous trunk transform at final bridge transition")
 var bounds: Rect2 = tree.bridge_rect()
 check(after["pivot"]+Vector2(0,-12)==bounds.position-tree.global_position,"visual bridge starts exactly at collider")
 check(after["pivot"]+Vector2(tree.bridge_length,12)==bounds.end-tree.global_position,"visual bridge ends exactly at collider")
 tree._activate_bridge()
 check(not tree.collider.disabled and tree.collider.shape.size==Vector2(tree.bridge_length,24),"original solid bridge dimensions preserved")
 check(not rock.apply_tool(0) and rock.hp==3,"hammer still cannot break rock")
 for i in range(3):
  check(rock.apply_tool(2) and rock.sound.playing,"rock sound on pickaxe strike "+str(i+1))
 check(rock.broken,"three pickaxe hits still break rock")
 if "--capture" in OS.get_cmdline_user_args():
  # A deterministic wide overview, showing canopy and all fall phases.
  var overlay := CanvasLayer.new()
  overlay.layer = 100
  root.add_child(overlay)
  var canvas := Node2D.new()
  overlay.add_child(canvas)
  game.hide()
  for child in p.get_children():
   if child is Camera2D: child.enabled = false
  var bg := Polygon2D.new()
  bg.polygon = PackedVector2Array([Vector2.ZERO,Vector2(960,0),Vector2(960,540),Vector2(0,540)])
  bg.color = Color("b6e4e5")
  canvas.add_child(bg)
  for i in range(6):
   var example = load("res://scripts/tool_obstacle.gd").new()
   canvas.add_child(example)
   example.position = Vector2(45+(i%3)*320,245+(i/3)*265)
   example.scale = Vector2.ONE*.21
   example.set_process(false)
   example.falling = true
   example.animation_time = [.0,.20,.35,.45,.55,.65][i]
   example.bridge_ready = i==5
   example.queue_redraw()
   var label := Label.new()
   label.text = "%.2f s" % example.animation_time
   label.position = Vector2(40+(i%3)*320,250+(i/3)*265)
   label.add_theme_color_override("font_color",Color("493027"))
   canvas.add_child(label)
  await process_frame
  await RenderingServer.frame_post_draw
  check(root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/qa_tree_fall_052.png"))==OK,"tree fall contact sheet saved")
  overlay.queue_free()
 game.queue_free()
 await process_frame
 print("PRESENTATION_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures==0 else 1)

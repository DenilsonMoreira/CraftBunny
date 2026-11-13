extends SceneTree
const RIG = preload("res://scripts/equipment_rig.gd")
const ART = preload("res://scripts/equipment_art.gd")
var checks := 0
var failures := 0
func check(value: bool,label: String) -> void:
 checks += 1
 if not value:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var p = load("res://scripts/player.gd").new()
 root.add_child(p)
 p.set_physics_process(false)
 p.tool_visual.set_physics_process(false)
 p.controls_enabled = true
 for child in p.get_children():
  if child is Camera2D: child.enabled = false
 var visual = p.tool_visual
 check(visual.final_frames.get_meta("equipment_rig_version",0)==2,"per-frame rig loaded")
 check(visual.gear_sprite.get_index()<visual.final_sprite.get_index(),"palm/body occludes handle and face cannot be overdrawn")
 for state in RIG.HANDS:
  var key: String = "slingshot/"+state
  var layout: Dictionary = visual.layouts[key]
  check(layout["attachments"].size()==12 and layout["angles"].size()==12,"twelve attachments "+state)
  for i in range(12):
   var frame: AtlasTexture = visual.final_frames.get_frame_texture(key,i)
   var cell := Vector2i(frame.atlas.get_width()/4,frame.atlas.get_height()/3)
   var source_point: Vector2 = RIG.HANDS[state][i]+Vector2(Vector2i(i%4,i/4)*cell)
   if state!="glide":
    var pixel := frame.atlas.get_image().get_pixelv(Vector2i(source_point))
    check(pixel.a>.9 and pixel.r>.75 and pixel.g>.58 and pixel.b>.44,"authored grip lies in actual cream paw %s %d" % [state,i])
   for tool in range(4):
    for facing in [-1,1]:
     p.equipped_tool = tool
     p.previous_tool = tool
     p.facing = facing
     p.dash_direction = facing
     visual.animation_key = p.TOOLS.KEYS[tool]+"/"+state
     visual.frame = i
     visual._update_equipment(p,state)
     var gear: Sprite2D = visual.gear_sprite
     var size := gear.texture.get_size()
     var grip: Vector2 = size*ART.GRIPS[tool]
     var actual := gear.to_global((grip-size/2)*Vector2(facing,1))
     var socket: Vector2 = visual.layouts[visual.animation_key]["attachments"][i]
     var expected: Vector2 = visual.to_global(Vector2(socket.x*facing,socket.y))
     check(actual.distance_to(expected)<.001,"grip stays attached %s %d tool%d facing%d" % [state,i,tool,facing])
     check(gear.flip_h==(facing<0),"tool mirrored with body")
 check(visual.layouts["slingshot/glide"]["stowed"],"both paws free for scarf, tool attached to satchel")
 var run: PackedVector2Array = visual.layouts["slingshot/run"]["attachments"]
 var movement := 0.0
 for i in range(1,12): movement = maxf(movement,run[i].distance_to(run[0]))
 check(movement>4,"running equipment follows real moving hand rather than fixed point")
 p.facing = -1
 p.dash_direction = 1
 check(visual._pose_facing(p,"dash")==1,"dash art follows locked dash direction")
 p.attack_facing = 1
 check(visual._pose_facing(p,"attack")==1,"attack art follows strike direction")
 if "--capture" in OS.get_cmdline_user_args():
  p.hide()
  var sheet := Node2D.new()
  root.add_child(sheet)
  var bg := Polygon2D.new()
  bg.polygon = PackedVector2Array([Vector2.ZERO,Vector2(960,0),Vector2(960,540),Vector2(0,540)])
  bg.color = Color("314b48")
  sheet.add_child(bg)
  p.equipped_tool = 3
  p.facing = 1
  for i in range(12):
   var group := Node2D.new()
   group.position = Vector2(60+(i%6)*156,105+(i/6)*255)
   group.scale = Vector2.ONE*2
   sheet.add_child(group)
   visual.animation_key = "slingshot/run"
   visual.frame = i
   visual._update_equipment(p,"run")
   var gear: Sprite2D = visual.gear_sprite.duplicate()
   gear.visible = true
   group.add_child(gear)
   var body := Sprite2D.new()
   body.texture = visual.final_frames.get_frame_texture("slingshot/run",i)
   body.position = visual.layouts["slingshot/run"]["position"]
   body.scale = visual.layouts["slingshot/run"]["scale"]
   body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   group.add_child(body)
   var label := Label.new()
   label.text = "RUN %02d" % (i+1)
   label.position = Vector2(28+(i%6)*156,190+(i/6)*255)
   sheet.add_child(label)
  await process_frame
  await RenderingServer.frame_post_draw
  var path := ProjectSettings.globalize_path("user://qa_rig_sling_054.png")
  check(root.get_texture().get_image().save_png(path)==OK,"saved twelve running grips")
  print("RIG_CAPTURE=",path)
  sheet.queue_free()
 p.queue_free()
 await process_frame
 print("EQUIPMENT_RIG_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures==0 else 1)

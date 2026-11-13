extends SceneTree
const FRAMES = preload("res://assets/production/v4/tool_frames.tres")
const TOOLS = preload("res://scripts/tool_catalog.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func check(value: bool, label: String) -> void:
 checks += 1
 if not value:
  failures += 1
  push_error(label)
func _run() -> void:
 var layouts: Dictionary = FRAMES.get_meta("layout")
 check(FRAMES.get_animation_names().size()==33,"33 complete production animations")
 for key in FRAMES.get_animation_names():
  check(FRAMES.get_frame_count(key)==12,key+": twelve frames")
  var complete := true
  var bounded := true
  var stable := true
  var same_size := Vector2.ZERO
  for i in range(12):
   var frame := FRAMES.get_frame_texture(key,i) as AtlasTexture
   complete = complete and frame!=null and frame.region.has_area()
   if frame==null: continue
   var box := Rect2(frame.margin.position,frame.region.size)
   bounded = bounded and box.position.x>=2 and box.position.y>=2 and box.end.x<=frame.get_width()-2 and box.end.y<=frame.get_height()-2
   if i==0: same_size = frame.get_size()
   stable = stable and same_size==frame.get_size()
   if layouts[key]["layered"]:
    var limit := 68.0 if str(key).ends_with("/glide") else 56.01
    check(frame.region.size.y*layouts[key]["scale"].y<=limit,key+": body/scarf height controlled")
  check(complete,key+": no empty poses")
  check(bounded,key+": full weapon/scarf inside transparent canvas")
  check(stable,key+": common canvas avoids frame resizing")
 var player = preload("res://scripts/player.gd").new()
 root.add_child(player)
 player.set_physics_process(false)
 player.tool_visual.set_physics_process(false)
 player.controls_enabled = true
 for child in player.get_children():
  if child is Camera2D: child.enabled = false
 for tool in range(4):
  player.equipped_tool = tool
  player.velocity = Vector2(0,1)
  player.tool_visual._physics_process(.016)
  check(player.tool_visual.final_sprite.visible and not player.tool_visual.draw_placeholder,"production fall replaces fallback for tool "+str(tool))
  check(player.tool_visual.gear_sprite.texture==preload("res://scripts/equipment_art.gd").texture(tool),"matching modular equipment "+str(tool))
  player.facing = -1
  player.tool_visual._physics_process(.016)
  check(player.tool_visual.final_sprite.flip_h and player.tool_visual.gear_sprite.flip_h,"left facing mirrors body and tool")
  player.facing = 1
 for kind in ["tree","rock"]:
  for i in range(8 if kind=="tree" else 4):
   check(preload("res://scripts/world_art.gd").texture(kind,i).get_size().length()>0,"environment art "+kind+str(i))
 if "--capture" in OS.get_cmdline_user_args():
  player.hide()
  var sheet := Node2D.new()
  root.add_child(sheet)
  var bg := Polygon2D.new()
  bg.polygon = PackedVector2Array([Vector2.ZERO,Vector2(960,0),Vector2(960,540),Vector2(0,540)])
  bg.color = Color("314b48")
  sheet.add_child(bg)
  var states := ["idle","run","jump","dash","glide","attack"]
  for tool in range(4):
   for column in range(states.size()):
    var state: String = states[column]
    var key: String = TOOLS.KEYS[tool]+"/"+state
    var pose := 6 if state=="attack" else 4
    var at := Vector2(80+column*160,75+tool*130)
    var sprite := Sprite2D.new()
    sprite.texture = FRAMES.get_frame_texture(key,pose)
    sprite.position = at+layouts[key]["position"]
    sprite.scale = layouts[key]["scale"]
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sheet.add_child(sprite)
    if layouts[key]["layered"]:
     player.equipped_tool = tool
     player.tool_visual.animation_key = key
     player.tool_visual.frame = pose
     player.tool_visual._update_equipment(player,state)
     var gear: Sprite2D = player.tool_visual.gear_sprite.duplicate()
     gear.position += at
     gear.visible = true
     sheet.add_child(gear)
    var label := Label.new()
    label.text = TOOLS.KEYS[tool]+" / "+state
    label.position = at+Vector2(-70,29)
    label.add_theme_font_size_override("font_size",13)
    sheet.add_child(label)
  await process_frame
  await RenderingServer.frame_post_draw
  check(root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/qa_art_poses_051.png"))==OK,"saved rendered production poses")
  sheet.queue_free()
 player.queue_free()
 await process_frame
 print("ART_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures==0 else 1)

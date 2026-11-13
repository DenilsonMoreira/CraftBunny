extends SceneTree
var failures := 0
var checks := 0
var sheet: Node2D

func check(value: bool, label: String) -> void:
 checks += 1
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)

func _initialize() -> void: call_deferred("_run")

func stamp(texture: Texture2D, factor: Vector2, offset: Vector2, at: Vector2, label: String, flip := false) -> void:
 var sprite := Sprite2D.new()
 sprite.texture = texture
 sprite.scale = factor
 sprite.position = at+offset
 sprite.flip_h = flip
 sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 sheet.add_child(sprite)
 var text := Label.new()
 text.text = label
 text.position = at+Vector2(-65,28)
 sheet.add_child(text)
 var line := Line2D.new()
 line.points = PackedVector2Array([at+Vector2(-65,21),at+Vector2(65,21)])
 line.width = 1
 line.default_color = Color(0.3,0.8,0.5,0.45)
 sheet.add_child(line)

func capture(path: String) -> void:
 await process_frame
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path)) == OK,"rendered sprite sheet saved")

func _run() -> void:
 var player = preload("res://scripts/player.gd").new()
 root.add_child(player)
 player.set_physics_process(false)
 player.hide()
 for child in player.get_children():
  if child is Camera2D: child.enabled = false
 var attack: AnimatedSprite2D = player.attack_sprite
 var scale_expected := 60.0/316.0
 check(is_equal_approx(attack.scale.x,scale_expected),"hammer visual scale unchanged")
 check(player.get_hammer_hitbox().size == Vector2(32,26),"hammer damage reach unchanged")
 var common_size := Vector2.ZERO
 for index in range(12):
  var texture := attack.sprite_frames.get_frame_texture("attack",index) as AtlasTexture
  var canvas := texture.get_size()
  var drawn := Rect2(texture.margin.position,texture.region.size)
  check(drawn.position.x >= 2 and drawn.position.y >= 2 and drawn.end.x <= canvas.x-2 and drawn.end.y <= canvas.y-2,"attack frame %d fits full hammer and feet inside canvas" % index)
  if index == 0: common_size = canvas
  check(canvas == common_size,"attack frame %d shares stable canvas" % index)
 var idle := player.animated_sprite.sprite_frames.get_frame_texture("idle",0) as AtlasTexture
 var normal_height: float = idle.region.size.y*player.animated_sprite.scale.y
 var mobility: AnimatedSprite2D = player.mobility_sprite
 var glide_scale: Vector2 = mobility.get_meta("glide_scale")
 var first := mobility.sprite_frames.get_frame_texture("glide",0) as AtlasTexture
 check(absf(first.region.size.y*glide_scale.y-normal_height) < .01,"opening glide pose matches normal rabbit height")
 for index in range(12):
  var texture := mobility.sprite_frames.get_frame_texture("glide",index) as AtlasTexture
  var height := texture.region.size.y*glide_scale.y
  check(height <= normal_height*1.05 and height >= normal_height*.80,"glide frame %d has consistent body scale" % index)
 check(attack.sprite_frames.get_frame_count("attack") == 12 and mobility.sprite_frames.get_frame_count("glide") == 12,"both sequences retain twelve frames")
 if "--capture" in OS.get_cmdline_user_args():
  sheet = Node2D.new()
  root.add_child(sheet)
  for index in range(24):
   stamp(attack.sprite_frames.get_frame_texture("attack",index%12),attack.scale,attack.position,Vector2(80+(index%6)*155,70+(index/6)*125),"Martelo %02d %s" % [index%12+1,"E" if index>=12 else "D"],index>=12)
  await capture("res://../docs/qa_attack_layout_043.png")
  sheet.queue_free()
  await process_frame
  sheet = Node2D.new()
  root.add_child(sheet)
  stamp(idle,player.animated_sprite.scale,player.animated_sprite.position,Vector2(80,95),"Normal")
  for index in range(12):
   stamp(mobility.sprite_frames.get_frame_texture("glide",index),glide_scale,mobility.get_meta("glide_position"),Vector2(80+((index+1)%6)*155,95+((index+1)/6)*150),"Planar %02d" % (index+1))
  await capture("res://../docs/qa_glide_scale_043.png")
  sheet.queue_free()
 player.queue_free()
 await process_frame
 print("SPRITE_LAYOUT_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures == 0 else 1)

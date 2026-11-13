@tool
extends StaticBody2D
const TOOLS = preload("res://scripts/tool_catalog.gd")
const ICONS = preload("res://scripts/tool_icons.gd")
const ART = preload("res://scripts/world_art.gd")
@export_enum("tree","rock") var kind := "tree":
 set(value):
  kind = value
  _refresh_preview()
@export var hits_required := 3
@export_range(128,4096,1) var bridge_length := 1184.0:
 set(value):
  bridge_length = value
  _refresh_preview()
@export var rock_size := Vector2(64,96):
 set(value):
  rock_size = value.max(Vector2(16,16))
  _refresh_preview()
var hp := 3
var falling := false
var bridge_ready := false
var broken := false
var animation_time := 0.0
var flash := 0.0
var collider: CollisionShape2D
var sound: AudioStreamPlayer

func _refresh_preview() -> void:
 if is_instance_valid(collider) and not falling and not broken and not bridge_ready:
  var shape := RectangleShape2D.new()
  shape.size = Vector2(28,bridge_length) if kind=="tree" else rock_size
  collider.shape = shape
  collider.position = Vector2(0,-bridge_length/2) if kind=="tree" else Vector2(rock_size.x/2,-rock_size.y/2)
 queue_redraw()

func _ready() -> void:
 hp = hits_required
 collision_layer = 1
 collision_mask = 1
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 collider = CollisionShape2D.new()
 collider.name = "ObstacleCollision"
 var shape := RectangleShape2D.new()
 shape.size = Vector2(28,bridge_length) if kind=="tree" else rock_size
 collider.shape = shape
 collider.position = Vector2(0,-bridge_length/2) if kind=="tree" else Vector2(rock_size.x/2,-rock_size.y/2)
 add_child(collider)
 if not Engine.is_editor_hint():
  add_to_group("tool_obstacles")
  if kind=="tree": add_to_group("bridges")
  sound = AudioStreamPlayer.new()
  sound.stream = load("res://music/impact-thud.mp3")
  sound.bus = "SFX" if AudioServer.get_bus_index("SFX")>=0 else "Master"
  sound.volume_db = -12
  add_child(sound)
 queue_redraw()

func hit_rect() -> Rect2:
 return Rect2(global_position+Vector2(-20,-65),Vector2(40,65)) if kind=="tree" else Rect2(global_position+Vector2(0,-rock_size.y),rock_size)

func bridge_rect() -> Rect2:
 return Rect2(global_position+Vector2(-80,0),Vector2(bridge_length,24))

func apply_tool(tool: int) -> bool:
 if broken or falling or bridge_ready: return false
 if tool != (TOOLS.Type.AXE if kind=="tree" else TOOLS.Type.PICKAXE): return false
 hp -= 1
 flash = .18
 if is_instance_valid(sound): sound.play()
 if hp <= 0:
  animation_time = 0
  collider.set_deferred("disabled",true)
  if kind=="tree": falling = true
  else: broken = true
 queue_redraw()
 return true

func _process(delta: float) -> void:
 if Engine.is_editor_hint(): return
 var player = get_tree().get_first_node_in_group("player")
 if is_instance_valid(player) and not player.controls_enabled: return
 flash = maxf(0,flash-delta)
 if falling:
  animation_time += delta
  if animation_time >= .65:
   falling = false
   bridge_ready = true
   _activate_bridge.call_deferred()
 elif broken: animation_time = minf(.5,animation_time+delta)
 queue_redraw()

func _activate_bridge() -> void:
 var shape := RectangleShape2D.new()
 shape.size = Vector2(bridge_length,24)
 collider.shape = shape
 collider.position = Vector2(bridge_length/2-80,12)
 collider.disabled = false

func _draw() -> void:
 if kind=="tree":
  var t := clampf(animation_time/.65,0,1) if falling else (1.0 if bridge_ready else 0.0)
  if t<.99:
   draw_texture_rect(ART.texture("tree",4),Rect2(-32,-48,64,48),false)
   draw_set_transform(Vector2(-80*t,12*t),t*PI/2)
   var bark := ART.texture("tree",1)
   for index in range(ceili(bridge_length/64)):
    var height := minf(64,bridge_length-index*64)
    draw_texture_rect_region(bark,Rect2(-16,-bridge_length+index*64,32,height),Rect2(Vector2.ZERO,Vector2(bark.get_width(),bark.get_height()*height/64)))
   draw_texture_rect(ART.texture("tree",0),Rect2(-170,-bridge_length-120,340,290),false)
   draw_set_transform(Vector2.ZERO)
  else:
   var middle := ART.texture("tree",2)
   for index in range(ceili((bridge_length-80)/64)):
    var width := minf(64,bridge_length-80-index*64)
    draw_texture_rect_region(middle,Rect2(-40+index*64,0,width,24),Rect2(Vector2.ZERO,Vector2(middle.get_width()*width/64,middle.get_height())))
   draw_texture_rect(ART.texture("tree",5),Rect2(-80,0,40,24),false)
   draw_texture_rect(ART.texture("tree",6),Rect2(bridge_length-120,0,40,24),false)
   draw_texture_rect(ART.texture("tree",3),Rect2(-16,-12,32,12),false)
   draw_texture_rect(ART.texture("tree",7),Rect2(bridge_length-145,-9,65,21),false)
  if not bridge_ready and not falling:
   draw_rect(Rect2(-19,-67,38,34),Color("eee0ac"))
   ICONS.draw_icon(self,"axe",Vector2(0,-49),.75)
   for index in range(hits_required-hp): draw_line(Vector2(-12,-23-index*6),Vector2(8,-27-index*6),Color("f5c881"),3)
 else:
  if broken:
   if animation_time < .5:
    draw_texture_rect(ART.texture("rock",3),Rect2(0,-28,rock_size.x,28),false,Color(1,1,1,1-animation_time))
    for index in range(7):
     var offset := Vector2(index*9, -20-animation_time*80+animation_time*animation_time*200)
     draw_rect(Rect2(offset,Vector2(7,7)),Color(.6,.59,.52,1-animation_time*2))
   return
  var box := Rect2(Vector2(0,-rock_size.y),rock_size)
  draw_texture_rect(ART.texture("rock",clampi(hits_required-hp,0,2)),box,false,Color.WHITE if flash<=0 else Color(1.25,1.15,1))
  ICONS.draw_icon(self,"pickaxe",Vector2(rock_size.x*.5,-rock_size.y*.5),.9)

@tool
extends StaticBody2D

@export var size := Vector2(96,20):
 set(value):
  size = value
  _sync()
@export_enum("earth","branch") var art := "earth":
 set(value):
  art = value
  queue_redraw()
@export var one_way := false:
 set(value):
  one_way = value
  _sync()
const EARTH = preload("res://assets/production/tiles/forest_ground_v2.png")
const BRANCH = preload("res://assets/production/v3/branch_platform.png")
var branch_region := Rect2()
static var cached_branch_region := Rect2()
func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 if not cached_branch_region.has_area():
  var image := BRANCH.get_image()
  cached_branch_region = Rect2(preload("res://scripts/sprite_atlas.gd").visible_bounds(image,Rect2i(Vector2i.ZERO,image.get_size())))
 branch_region = cached_branch_region
 _sync()
func _sync() -> void:
 var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
 if collision != null:
  var shape := RectangleShape2D.new()
  shape.size = size
  collision.shape = shape
  collision.one_way_collision = one_way
 queue_redraw()
func surface_rect() -> Rect2:
 return Rect2(global_position-size/2,size)
func _draw() -> void:
 var rect := Rect2(-size/2,size)
 if art=="branch" and branch_region.has_area():
  var source := Rect2(branch_region.position+Vector2(branch_region.size.x*0.25,0),Vector2(branch_region.size.x*0.5,branch_region.size.y))
  for column in range(ceili(size.x/192.0)):
   var width := minf(192.0,size.x-column*192)
   draw_texture_rect_region(BRANCH,Rect2(rect.position+Vector2(column*192,0),Vector2(width,size.y)),source)
 else:
  for column in range(ceili(size.x/128.0)):
   var width := minf(128.0,size.x-column*128)
   draw_texture_rect_region(EARTH,Rect2(rect.position+Vector2(column*128,0),Vector2(width,size.y)),Rect2(0,0,512,256))

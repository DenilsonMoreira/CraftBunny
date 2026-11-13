@tool
extends Node2D
const EARTH = preload("res://assets/production/tiles/forest_ground_v2.png")
@export var tree: Texture2D
@export var cloud: Texture2D
@export var world_width := 24000.0
func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 queue_redraw()
func _draw() -> void:
 draw_rect(Rect2(-500,-1600,world_width+1000,3200),Color("b9e9ec"))
 if cloud != null:
  for index in range(ceili(world_width/300)+5):
   draw_texture_rect(cloud,Rect2(index*300-100,-700+(index%3)*120,180,70),false,Color(1,1,1,0.8))
 if tree != null:
  for index in range(ceili(world_width/310)+2):
   draw_texture_rect(tree,Rect2(index*310-40,115,260,320),false,Color(0.80,0.91,0.80,0.7))
 draw_rect(Rect2(-500,560,world_width+1000,1200),Color("4f3329"))
 for index in range(ceili(world_width/256)+2):
  draw_texture_rect_region(EARTH,Rect2(index*256,560,256,650),Rect2(0,256,256,650),Color(0.30,0.23,0.20,0.72))

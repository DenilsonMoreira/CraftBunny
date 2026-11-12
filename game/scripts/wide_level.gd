extends Node2D
const WIDTH := 48000.0
const SURFACE_Y := 435.0
const UPPER_Y := -285.0
const LOWER_Y := 915.0
const MAX_CARROTS := 200
const SURFACE_SCRIPT = preload("res://scripts/level_surface.gd")

func _ready() -> void:
 if get_parent()==get_tree().root:
  get_tree().call_deferred("change_scene_to_file","res://main.tscn")

func solid_rects() -> Array[Rect2]:
 var rects: Array[Rect2] = []
 for layer in $Terrenos.get_children():
  if not layer is TileMapLayer: continue
  var top_rows := {}
  for cell in layer.get_used_cells():
   if layer.get_cell_source_id(cell-Vector2i(0,1)) != -1: continue
   if not top_rows.has(cell.y): top_rows[cell.y] = []
   top_rows[cell.y].append(cell.x)
  for row in top_rows:
   var columns: Array = top_rows[row]
   columns.sort()
   var start: int = columns[0]
   var last := start
   for index in range(1,columns.size()+1):
    if index<columns.size() and columns[index]==last+1:
     last = columns[index]
     continue
    var origin: Vector2 = layer.to_global(Vector2(start*256,row*256))
    rects.append(Rect2(origin,Vector2((last-start+1)*64,128)))
    if index<columns.size():
     start = columns[index]
     last = start
 for surface in $Plataformas.get_children():
  if surface.has_method("surface_rect"): rects.append(surface.surface_rect())
 return rects

func goal_rect() -> Rect2:
 return Rect2($Chegada.global_position+Vector2(-46,-84),Vector2(92,100))

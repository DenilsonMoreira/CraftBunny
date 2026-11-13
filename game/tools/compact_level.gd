extends SceneTree

# Author a new native scene; never overwrite the original or an edited compact map.
const SOURCE := "res://scenes/level_wide/fase_ampla.tscn"
const OUTPUT := "res://scenes/level_wide/fase_compacta.tscn"
func _initialize() -> void: call_deferred("_run")
func compress_tiles(layer: TileMapLayer) -> Dictionary:
 var old_cells := layer.get_used_cells()
 var rows := {}
 var old_columns := {}
 for cell in old_cells:
  rows[cell.y] = true
  if cell.y==0: old_columns[cell.x] = true
 var gaps := {}
 for column in range(750):
  if not old_columns.has(column): gaps[int(column/2)] = true
 var cells := []
 for cell in old_cells:
  cells.append([Vector2i(int(cell.x/2),cell.y),layer.get_cell_source_id(cell),layer.get_cell_atlas_coords(cell),layer.get_cell_alternative_tile(cell)])
 layer.clear()
 for item in cells: layer.set_cell(item[0],item[1],item[2],item[3])
 for column in gaps:
  for row in rows: layer.erase_cell(Vector2i(column,row))
 return gaps
func safe_x(layer: TileMapLayer,x: float) -> float:
 var column := clampi(int(x/64),0,374)
 while layer.get_cell_source_id(Vector2i(column,0))==-1: column += 1
 return clampf(x,column*64+24,column*64+40)
func _run() -> void:
 if FileAccess.file_exists(OUTPUT):
  push_error("Compact scene already exists; refusing to overwrite your edits.")
  quit(1)
  return
 var level := load(SOURCE).instantiate() as Node2D
 level.name = "FaseCompacta"
 var forest := level.get_node("Terrenos/Floresta") as TileMapLayer
 var lower := level.get_node("Terrenos/Subsolo") as TileMapLayer
 compress_tiles(forest)
 compress_tiles(lower)
 var branches: Array = level.get_node("Plataformas").get_children().filter(func(node): return str(node.name).begins_with("Galho"))
 branches.sort_custom(func(a,b): return a.position.x<b.position.x)
 var original_width := 0.0
 for branch in branches: original_width += branch.size.x
 var new_left := 640.0
 var branch_end := 21752.0
 var width_ratio: float = (branch_end-new_left-64*(branches.size()-1))/original_width
 var mapping := []
 for branch in branches:
  var old_left: float = branch.position.x-branch.size.x/2
  var old_width: float = branch.size.x
  var width: float = old_width*width_ratio
  mapping.append({"old_left":old_left,"old_right":old_left+old_width,"new_left":new_left,"width":width,"ratio":width_ratio})
  branch.size = Vector2(width,branch.size.y)
  branch.position.x = new_left+width/2
  new_left += width+64
 for platform in level.get_node("Plataformas").get_children():
  var label := str(platform.name)
  if label.begins_with("EscadaAlta"):
   platform.position.x -= 24000
  elif label.begins_with("Retorno"):
   platform.position.x = int(int(platform.position.x/64)/2)*64+32
 for group in ["Itens","Inimigos"]:
  for marker in level.get_node(group).get_children():
   if marker.position.y<0:
    var nearest: Dictionary = mapping[0]
    var distance := INF
    for part in mapping:
     var current := absf(marker.position.x-clampf(marker.position.x,part["old_left"],part["old_right"]))
     if current<distance:
      nearest = part
      distance = current
    marker.position.x = nearest["new_left"]+clampf((marker.position.x-nearest["old_left"])*nearest["ratio"],26,nearest["width"]-26)
   else:
    marker.position.x = safe_x(lower if marker.position.y>560 else forest,marker.position.x/2)
 level.get_node("Chegada").position.x = 23600
 var packed := PackedScene.new()
 assert(packed.pack(level)==OK)
 assert(ResourceSaver.save(packed,OUTPUT)==OK)
 level.free()
 print("COMPACT_LEVEL_CREATED=",OUTPUT)
 quit(0)

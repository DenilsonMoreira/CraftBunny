extends SceneTree
const OUTPUT := "res://scenes/level_wide/fase_ferramentas.tscn"
const OBSTACLE = preload("res://scripts/tool_obstacle.gd")
const SURFACE = preload("res://scripts/level_surface.gd")
const GAPS := [Vector2(2048,3072),Vector2(14336,15360)]
func _initialize() -> void: call_deferred("_run")
func own(node: Node, parent: Node, level: Node) -> void:
 parent.add_child(node)
 node.owner = level
func wall(level: Node, label: String, at: Vector2, size: Vector2) -> void:
 var node := StaticBody2D.new()
 node.set_script(SURFACE)
 node.name = label
 node.position = at
 node.size = size
 own(node,level.get_node("Plataformas"),level)
 var col := CollisionShape2D.new()
 col.name = "CollisionShape2D"
 var shape := RectangleShape2D.new()
 shape.size = size
 col.shape = shape
 own(col,node,level)
func align_markers(level: Node2D) -> int:
 var surfaces: Array[Rect2] = level.solid_rects()
 var count := 0
 for marker in level.get_node("Itens").get_children():
  var floor_y := 435.0 if marker.position.y>0 and marker.position.y<560 else (915.0 if marker.position.y>560 else -285.0)
  var candidates := surfaces.filter(func(r): return is_equal_approx(r.position.y,floor_y) and r.size.x>=48)
  if candidates.any(func(r): return marker.position.x>=r.position.x+16 and marker.position.x<=r.end.x-16): continue
  var best: float = marker.position.x
  var distance := INF
  for rect in candidates:
   var x := clampf(marker.position.x,rect.position.x+24,rect.end.x-24)
   if absf(x-marker.position.x)<distance:
    best = x
    distance = absf(x-marker.position.x)
  marker.position.x = best
  count += 1
 return count
func _run() -> void:
 if FileAccess.file_exists(OUTPUT):
  if "--align-markers" in OS.get_cmdline_user_args():
   var edited: Node2D = load(OUTPUT).instantiate()
   var moved := align_markers(edited)
   var scene := PackedScene.new()
   assert(scene.pack(edited)==OK)
   assert(ResourceSaver.save(scene,OUTPUT)==OK)
   edited.free()
   print("ALIGNED_MARKERS=",moved)
   quit(0)
   return
  push_error("Refusing to overwrite an existing editable tool level.")
  quit(1)
  return
 var level: Node2D = load("res://scenes/level_wide/fase_compacta.tscn").instantiate()
 level.name = "FaseFerramentas"
 var challenges := Node2D.new()
 challenges.name = "DesafiosFerramentas"
 own(challenges,level,level)
 for gap in GAPS:
  for layer in level.get_node("Terrenos").get_children():
   for cell in layer.get_used_cells():
    if cell.x*64 >= gap.x and cell.x*64 < gap.y: layer.erase_cell(cell)
  for surface in level.get_node("Plataformas").get_children():
   var rect: Rect2 = surface.surface_rect()
   # Remove crossing branches, preserving portions on both sides of the chasm.
   if rect.end.x<=gap.x or rect.position.x>=gap.y: continue
   var left := maxf(0,gap.x-rect.position.x)
   var right := maxf(0,rect.end.x-gap.y)
   if right > 0:
    wall(level,str(surface.name)+"Direita",Vector2(gap.y+right/2,surface.position.y),Vector2(right,surface.size.y))
    var added = level.get_node("Plataformas").get_child(-1)
    added.art = surface.art
    added.one_way = surface.one_way
   if left > 0:
    surface.size.x = left
    surface.position.x = rect.position.x+left/2
    var col = surface.get_node("CollisionShape2D")
    col.shape = RectangleShape2D.new()
    col.shape.size = surface.size
   else:
    surface.get_parent().remove_child(surface)
    surface.free()
  var tree := StaticBody2D.new()
  tree.set_script(OBSTACLE)
  tree.name = "ArvorePonte%d" % (GAPS.find(gap)+1)
  tree.kind = "tree"
  tree.position = Vector2(gap.x-40,435)
  tree.bridge_length = gap.y-gap.x+160
  own(tree,challenges,level)
 for i in range(2):
  var x := 6144.0 if i==0 else 18432.0
  var rock := StaticBody2D.new()
  rock.set_script(OBSTACLE)
  rock.kind = "rock"
  rock.name = "RochaPassagem%d" % (i+1)
  rock.position = Vector2(x,915)
  own(rock,challenges,level)
  wall(level,"TetoPedra%d" % i,Vector2(x+192,807),Vector2(384,24))
  wall(level,"FundoPedra%d" % i,Vector2(x+384,855),Vector2(24,120))
  wall(level,"PisoPedra%d" % i,Vector2(x+192,927),Vector2(384,24))
 # Keep the exact carrot/wood budget. Move unsupported markers off the gaps.
 for group in ["Itens","Inimigos"]:
  for marker in level.get_node(group).get_children():
   for gap in GAPS:
    if marker.position.x >= gap.x-24 and marker.position.x < gap.y+24:
     marker.position.x = gap.x-160-(int(marker.get_index())%4)*48
     if marker.position.y<0: marker.position.y = -322 if group=="Itens" else -400
 # Place twelve existing lower-floor carrots in the two visible rock passages.
 var carrots: Array = level.get_node("Itens").get_children().filter(func(n):return n.get_meta("kind","")=="carrot" and n.position.y>560)
 for index in range(12):
  carrots[index].position = Vector2((6144 if index<6 else 18432)+100+(index%6)*42,880)
 align_markers(level)
 var packed := PackedScene.new()
 assert(packed.pack(level)==OK)
 assert(ResourceSaver.save(packed,OUTPUT)==OK)
 level.free()
 print("TOOL_LEVEL_CREATED=",OUTPUT)
 quit(0)

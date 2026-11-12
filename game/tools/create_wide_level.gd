extends SceneTree
const OUT := "res://scenes/level_wide/"
var scene: Node2D
var terrain: TileMapLayer
var underground: TileMapLayer
var platforms: Node2D
var prefabs := {}
func _initialize() -> void: call_deferred("_run")
func own(parent: Node,child: Node) -> void:
 parent.add_child(child)
 child.owner = scene
func save(node: Node,path: String) -> void:
 var packed := PackedScene.new()
 assert(packed.pack(node)==OK)
 assert(ResourceSaver.save(packed,path)==OK)
func prefab(kind: String) -> PackedScene:
 if prefabs.has(kind): return prefabs[kind]
 var marker := Marker2D.new()
 marker.name = kind.capitalize()
 marker.set_meta("kind",kind)
 marker.set_meta("_edit_group_",true)
 var preview: Node2D
 if kind in ["cobra","guaxinim","ave"]:
  preview = preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/"+kind+".png",{"idle":[0,1,2,3]},Vector2(52,38) if kind=="ave" else Vector2(46,30),13.0,kind=="ave")
  preview.stop()
 else:
  var sprite := Sprite2D.new()
  sprite.texture = preload("res://scripts/prop_art.gd").texture(kind)
  sprite.scale = preload("res://scripts/prop_art.gd").fit(sprite.texture,Vector2(20,26) if kind=="carrot" else Vector2(26,16))/sprite.texture.get_size()
  preview = sprite
 preview.name = "Previa"
 marker.add_child(preview)
 preview.owner = marker
 save(marker,OUT+kind+".tscn")
 marker.free()
 prefabs[kind] = load(OUT+kind+".tscn")
 return prefabs[kind]
func spawn(parent: Node,kind: String,pos: Vector2,index: int) -> void:
 var marker := prefab(kind).instantiate() as Marker2D
 marker.name = kind.capitalize()+"%03d" % index
 marker.position = pos
 own(parent,marker)
func surface(name: String,center: Vector2,size: Vector2,branch := false,one_way := false) -> void:
 var block := StaticBody2D.new()
 block.name = name
 block.set_script(load("res://scripts/level_surface.gd"))
 block.size = size
 block.art = "branch" if branch else "earth"
 block.one_way = one_way
 block.position = center
 var collision := CollisionShape2D.new()
 collision.name = "CollisionShape2D"
 var shape := RectangleShape2D.new()
 shape.size = size
 collision.shape = shape
 collision.one_way_collision = one_way
 block.add_child(collision)
 own(platforms,block)
 collision.owner = scene
func safe_x(layer: TileMapLayer,x: float) -> float:
 var cell := Vector2i(int(x/64),0)
 while layer.get_cell_source_id(cell)==-1: cell.x += 1
 return cell.x*64+32
func _run() -> void:
 if FileAccess.file_exists(OUT+"fase_ampla.tscn"):
  push_error("Scene exists; edit it in Godot. Refusing to overwrite your map.")
  quit(1)
  return
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
 scene = Node2D.new()
 scene.name = "FaseAmpla"
 scene.set_script(load("res://scripts/wide_level.gd"))
 scene.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 var background := Node2D.new()
 background.name = "Fundo"
 background.set_script(load("res://scripts/wide_background.gd"))
 background.tree = preload("res://scripts/prop_art.gd").texture("tree")
 background.cloud = preload("res://scripts/prop_art.gd").texture("cloud")
 background.set_meta("_edit_lock_",true)
 own(scene,background)
 var terrains := Node2D.new()
 terrains.name = "Terrenos"
 own(scene,terrains)
 for tier in range(2):
  var layer := TileMapLayer.new()
  layer.name = "Floresta" if tier==0 else "Subsolo"
  layer.position.y = 435 if tier==0 else 915
  layer.scale = Vector2.ONE*0.25
  layer.tile_set = load(OUT+"terra_tileset.tres")
  var holes: Array = [15,75,161,250,340,435,550,665] if tier==0 else [130,275,420,590]
  for x in range(750):
   if x in holes: continue
   for y in range(2): layer.set_cell(Vector2i(x,y),0,Vector2i(x%4,0 if tier==0 and y==0 else 1))
  own(terrains,layer)
  if tier==0: terrain = layer
  else: underground = layer
 platforms = Node2D.new()
 platforms.name = "Plataformas"
 own(scene,platforms)
 # Upper branches: 46,000 px of editable platform strips, with small jump gaps.
 var branch_x := 640.0
 var branch_index := 0
 while branch_x < 45752:
  var width := minf(1200.0,45752-branch_x)
  surface("Galho%02d" % branch_index,Vector2(branch_x+width/2,-269),Vector2(width,32),true)
  branch_x += width+64
  branch_index += 1
 # Four 80px rises cannot be cleared by the normal ~50px jump without crates.
 var rises := [40,40,80,40,40,80,40,40,80,40,40,80,40,40]
 var step_y := 435.0
 for index in range(rises.size()):
  step_y -= rises[index]
  surface("EscadaAlta%02d" % index,Vector2(47000-index*96+48,step_y+10),Vector2(96,20))
 # Return shafts. One-way steps allow ascent without trapping the rabbit below.
 for shaft in [15,340,665]:
  for step in range(12):
   surface("Retorno%d_%02d" % [shaft,step],Vector2(shaft*64+32,915-(step+1)*40+6),Vector2(56,12),false,true)
 var start := load("res://scenes/editor_example/inicio_jogador.tscn").instantiate() as Marker2D
 start.name = "InicioJogador"
 start.position = Vector2(100,414)
 own(scene,start)
 var enemies := Node2D.new()
 enemies.name = "Inimigos"
 own(scene,enemies)
 for index in range(12):
  var below := index<9
  var x := safe_x(underground if below else terrain,2500+index*5000 if below else 12000+(index-9)*12000)
  spawn(enemies,"cobra",Vector2(x,902 if below else 422),index)
 for index in range(6):
  var below := index<2
  var x := safe_x(underground if below else terrain,8000+index*24000 if below else 6000+(index-2)*11000)
  spawn(enemies,"guaxinim",Vector2(x,902 if below else 422),index)
 for index in range(6): spawn(enemies,"ave",Vector2(4800+index*7600,-430),index)
 var pickups := Node2D.new()
 pickups.name = "Itens"
 own(scene,pickups)
 for tier in range(3):
  var count: int = [40,70,30][tier]
  for index in range(count):
   var x := 400.0+(index+0.5)*44800.0/count
   var floor_y: float = [435.0,-285.0,915.0][tier]
   if tier==1:
    var segment := int((x-640)/1264)
    x = 640+segment*1264+clampf(fmod(x-640,1264),48,1150)
   else: x = safe_x(terrain if tier==0 else underground,x)
   spawn(pickups,"carrot",Vector2(x,floor_y-37),tier*100+index)
  var wood_count: int = [24,40,16][tier]
  for index in range(wood_count):
   var x := 200.0+(index+0.5)*44000.0/wood_count
   var floor_y: float = [435.0,-285.0,915.0][tier]
   if tier==1:
    var segment := int((x-640)/1264)
    x = 640+segment*1264+clampf(fmod(x-640,1264),52,1130)
   else: x = safe_x(terrain if tier==0 else underground,x)
   spawn(pickups,"wood",Vector2(x,floor_y-32),tier*100+index)
 for index in range(5): spawn(pickups,"heart",Vector2(safe_x(terrain,2500+index*10000),400),index)
 var goal := Marker2D.new()
 goal.name = "Chegada"
 goal.position = Vector2(47600,915)
 own(scene,goal)
 var house := Sprite2D.new()
 house.name = "CasaPixelArt"
 var texture := preload("res://assets/production/v3/bunny_house.png")
 var atlas := AtlasTexture.new()
 atlas.atlas = texture
 atlas.region = Rect2(preload("res://scripts/sprite_atlas.gd").visible_bounds(texture.get_image(),Rect2i(Vector2i.ZERO,texture.get_size())))
 house.texture = atlas
 house.scale = Vector2.ONE*minf(210.0/atlas.get_width(),190.0/atlas.get_height())
 house.position = Vector2(0,-house.texture.get_height()*house.scale.y/2)
 goal.add_child(house)
 house.owner = scene
 save(scene,OUT+"fase_ampla.tscn")
 scene.free()
 print("WIDE_LEVEL_CREATED=",OUT+"fase_ampla.tscn")
 quit(0)

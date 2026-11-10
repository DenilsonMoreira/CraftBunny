extends SceneTree

# One-time authoring helper. The resulting scene/resources are native editable
# Godot files; opening or running the scene never regenerates its terrain.
const OUTPUT := "res://scenes/editor_example/"
func _initialize() -> void: call_deferred("_run")
func own(parent: Node,child: Node,scene_owner: Node) -> void:
 parent.add_child(child)
 child.owner = scene_owner
func save_scene(node: Node,path: String) -> void:
 var packed := PackedScene.new()
 assert(packed.pack(node)==OK)
 assert(ResourceSaver.save(packed,path)==OK)
func marker_scene(path: String,kind: String) -> PackedScene:
 var marker := Marker2D.new()
 marker.name = "InicioJogador" if kind=="bunny" else "Cobra"
 marker.set_meta("_edit_group_",true)
 var preview := preload("res://scripts/sprite_atlas.gd").create("res://assets/production/v2/"+kind+".png",{"idle":[0,1,2,3]},Vector2(48,60) if kind=="bunny" else Vector2(46,30),21.0 if kind=="bunny" else 13.0)
 preview.name = "Previa"
 preview.stop()
 preview.frame = 0
 own(marker,preview,marker)
 save_scene(marker,path)
 marker.free()
 return load(path)
func _run() -> void:
 if FileAccess.file_exists(OUTPUT+"fase_exemplo.tscn"):
  push_error("Example already exists. Refusing to overwrite your edited scene.")
  quit(1)
  return
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
 var terrain := TileSet.new()
 terrain.tile_size = Vector2i(256,256)
 terrain.add_physics_layer()
 terrain.set_physics_layer_collision_layer(0,1)
 var atlas := TileSetAtlasSource.new()
 var ground := preload("res://assets/production/tiles/forest_ground_v2.png")
 atlas.texture = ground
 atlas.texture_region_size = Vector2i(256,256)
 terrain.add_source(atlas,0)
 for y in range(ground.get_height()/256):
  for x in range(ground.get_width()/256):
   var coords := Vector2i(x,y)
   atlas.create_tile(coords)
   var data := atlas.get_tile_data(coords,0)
   data.set_collision_polygons_count(0,1)
   data.set_collision_polygon_points(0,0,PackedVector2Array([Vector2(-128,-128),Vector2(128,-128),Vector2(128,128),Vector2(-128,128)]))
 assert(ResourceSaver.save(terrain,OUTPUT+"terra_tileset.tres")==OK)
 var bunny := marker_scene(OUTPUT+"inicio_jogador.tscn","bunny")
 var cobra := marker_scene(OUTPUT+"cobra.tscn","cobra")
 var scene := Node2D.new()
 scene.name = "ExemploEditavel"
 scene.set_script(load("res://scripts/editor_example.gd"))
 scene.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 var sky := Polygon2D.new()
 sky.name = "Fundo"
 sky.polygon = PackedVector2Array([Vector2.ZERO,Vector2(960,0),Vector2(960,620),Vector2(0,620)])
 sky.color = Color("b9e7ec")
 sky.set_meta("_edit_lock_",true)
 own(scene,sky,scene)
 var layer := TileMapLayer.new()
 layer.name = "Terreno"
 layer.position = Vector2(32,384)
 layer.scale = Vector2(0.25,0.25)
 layer.tile_set = load(OUTPUT+"terra_tileset.tres")
 for row in range(3):
  for column in range(14):
   layer.set_cell(Vector2i(column,row),0,Vector2i(column%4,0 if row==0 else 1))
 own(scene,layer,scene)
 var start := bunny.instantiate()
 start.position = Vector2(160,363)
 own(scene,start,scene)
 var spawns := Node2D.new()
 spawns.name = "Inimigos"
 own(scene,spawns,scene)
 var enemy := cobra.instantiate()
 enemy.position = Vector2(610,371)
 own(spawns,enemy,scene)
 var canvas := CanvasLayer.new()
 canvas.name = "Interface"
 own(scene,canvas,scene)
 var font := preload("res://scripts/ui_theme.gd").pixel_font()
 for index in range(3):
  var label := Label.new()
  label.name = ["Titulo","Controles","Status"][index]
  label.position = Vector2(24,22+index*28)
  label.text = ["EXEMPLO EDITAVEL - TERRA, COELHO E COBRA","A/D: mover | ESPACO: pular | J: martelo | R: reiniciar","VIDA: 3/3   CENOURAS: 0"][index]
  label.add_theme_font_override("font",font)
  label.add_theme_font_size_override("font_size",14)
  label.add_theme_color_override("font_color",Color("294d34"))
  label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  own(canvas,label,scene)
 save_scene(scene,OUTPUT+"fase_exemplo.tscn")
 scene.free()
 print("EDITABLE_EXAMPLE_CREATED=",OUTPUT+"fase_exemplo.tscn")
 quit(0)

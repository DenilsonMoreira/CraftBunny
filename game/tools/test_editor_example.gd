extends SceneTree
var failures := 0
func check(value: bool,label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var packed := load("res://scenes/editor_example/fase_exemplo.tscn") as PackedScene
 var scene = packed.instantiate()
 var terrain := scene.get_node("Terreno") as TileMapLayer
 check(terrain.get_used_cells().size()==42,"terrain is stored as 42 native editable cells")
 check(terrain.get_cell_tile_data(Vector2i.ZERO).get_collision_polygons_count(0)==1,"painted tiles contain collision polygons")
 check(scene.get_node("InicioJogador/Previa").sprite_frames.get_frame_count("idle")==4,"rabbit preview exists before running the scene")
 check(scene.get_node("Inimigos/Cobra/Previa").sprite_frames.get_frame_count("idle")==4,"snake preview exists before running the scene")
 scene.get_node("InicioJogador").position.x = 224
 scene.get_node("Inimigos/Cobra").position.x = 700
 terrain.set_cell(Vector2i(14,0),0,Vector2i.ZERO)
 terrain.erase_cell(Vector2i(0,0))
 var edited := PackedScene.new()
 check(edited.pack(scene)==OK,"editor changes can be packed into a normal scene")
 var path := "user://qa_editable_%d.tscn" % Time.get_ticks_usec()
 check(ResourceSaver.save(edited,path)==OK,"edited scene saves without a generator")
 scene.free()
 scene = load(path).instantiate()
 terrain = scene.get_node("Terreno")
 check(terrain.get_cell_source_id(Vector2i(14,0))==0 and terrain.get_cell_source_id(Vector2i.ZERO)==-1,"paint and erase survive saving and reopening")
 root.add_child(scene)
 await process_frame
 check(is_equal_approx(scene.player.position.x,224),"runtime player uses the edited starting marker")
 check(scene.enemies.size()==1 and is_equal_approx(scene.enemies[0].patrol_origin.x,700),"runtime enemy uses the edited snake position")
 check(not scene.get_node("InicioJogador").visible and not scene.get_node("Inimigos/Cobra").visible,"editor previews are hidden when real actors spawn")
 check(scene.player.health==3 and scene.enemies[0].hp==2,"existing rabbit and snake health rules are reused")
 for tick in range(20): await physics_frame
 check(scene.player.is_on_floor() and absf(scene.player.position.y-363)<2,"native tile collisions support the rabbit at the visible surface")
 var initial_x: float = scene.player.position.x
 Input.action_press("move_right")
 for tick in range(10): await physics_frame
 Input.action_release("move_right")
 check(scene.player.position.x>initial_x,"normal movement works on the editable floor")
 Input.action_press("jump")
 for tick in range(3): await physics_frame
 Input.action_release("jump")
 check(scene.player.velocity.y<0,"normal jump works in the editable scene")
 var enemy = scene.enemies[0]
 enemy.active = false
 enemy.global_position = scene.player.global_position+Vector2(35,0)
 scene._hammer(scene.player.get_hammer_hitbox())
 check(enemy.hp==1,"hammer causes exactly one damage using the existing enemy script")
 enemy.damage_recovery = 0
 scene._hammer(scene.player.get_hammer_hitbox())
 check(not enemy.alive,"snake is defeated after two hits")
 var pickups: Array = scene.get_children().filter(func(node): return node.get_script()==scene.PICKUP)
 check(pickups.size()==1 and pickups[0].amount==1,"snake drops its existing one-carrot reward")
 scene._collected(pickups[0])
 check(scene.carrots==1,"dropped carrot can be collected in the example")
 await create_timer(0.5).timeout
 if "--capture" in OS.get_cmdline_user_args():
  scene.free()
  scene = packed.instantiate()
  root.add_child(scene)
  await process_frame
  for tick in range(3): await physics_frame
  await RenderingServer.frame_post_draw
  check(root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/qa_editable_example.png"))==OK,"rendered editable example screenshot saved")
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://main.tscn","main game scene remains unchanged")
 scene.queue_free()
 await process_frame
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("EDITOR_EXAMPLE_FAILURES=",failures)
 quit(1 if failures else 0)

extends SceneTree
var failures := 0
func check(value: bool,label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var house_image := preload("res://assets/production/v3/bunny_house.png").get_image()
 print("HOUSE_ALPHA_REGION=",preload("res://scripts/sprite_atlas.gd").visible_bounds(house_image,Rect2i(Vector2i.ZERO,house_image.get_size())))
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.global_ranking.api_url = ""
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 var tier_carrots := [0,0,0]
 var tier_wood := [0,0,0]
 var rewards := 0
 var lower_snakes := 0
 var lower_raccoons := 0
 var birds := 0
 for child in game.get_children():
  if child.get_script()==game.PICKUP_SCRIPT:
   var tier := 1 if child.position.y<0 else (2 if child.position.y>560 else 0)
   if child.kind=="carrot": tier_carrots[tier] += 1
   if child.kind=="wood": tier_wood[tier] += 1
  elif child.get_script()==game.ENEMY_SCRIPT:
   rewards += int(child.DATA[child.kind]["reward"])
   if child.kind=="cobra" and child.position.y>560: lower_snakes += 1
   if child.kind=="guaxinim" and child.position.y>560: lower_raccoons += 1
   if child.kind=="ave":
    birds += 1
    check(child.position.y<game.level.UPPER_Y,"bird begins above the upper branches")
 check(tier_carrots==[40,70,30],"140 map carrots distributed 40 forest / 70 canopy / 30 underground")
 check(rewards==60 and rewards+140==game.global_ranking.MAX_CARROTS,"all enemy rewards complete the exact 200-carrot ceiling")
 check(tier_wood==[24,40,16],"more planks upstairs and sufficient wood before crate stairs")
 check(lower_snakes==9 and lower_raccoons==2 and birds==6,"underground favors snakes and all six birds stay upstairs")
 check(game.LEVEL_WIDTH==48000 and game.player.fall_death_y>game.level.LOWER_Y+200,"wider camera and fall threshold support the lower floor")
 game.player.set_physics_process(false)
 game.player.position = Vector2(1000,894)
 game.player.velocity = Vector2.ZERO
 game.player.set_physics_process(true)
 for tick in range(15): await physics_frame
 check(game.player.is_on_floor() and game.player.health==3 and not game.pit_audio_started,"descending into underground is safe and does not trigger a pit death")
 game.player.position = Vector2(992,894)
 game.player.velocity = Vector2.ZERO
 for tick in range(4): await physics_frame
 for step in range(12):
  Input.action_press("jump")
  for tick in range(3): await physics_frame
  Input.action_release("jump")
  for tick in range(32): await physics_frame
 check(game.player.position.y+21 <= game.FLOOR_Y+1 and game.player.health==3,"physics ascent through a return shaft reaches the forest without crates")
 var max_jump: float = pow(game.player.JUMP_SPEED,2)/(2*game.player.GRAVITY)
 game.wood_count = 12
 for index in [2,5,8,11]:
  var previous: Rect2 = game.level.get_node("Plataformas/EscadaAlta%02d" % (index-1)).surface_rect()
  var next: Rect2 = game.level.get_node("Plataformas/EscadaAlta%02d" % index).surface_rect()
  var rise := previous.position.y-next.position.y
  check(rise>max_jump and rise-game.BOX_SIZE<max_jump,"80px stair requires a crate and one crate makes it reachable")
  game.player.set_physics_process(false)
  game.player.position = Vector2(previous.position.x+64,previous.position.y-21)
  game.player.velocity = Vector2.ZERO
  game.player.facing = -1
  await physics_frame
  var before := get_nodes_in_group("crates").size()
  game._on_box_requested()
  var crates := get_nodes_in_group("crates")
  check(crates.size()==before+1,"required crate can be built on the stair tread")
  if crates.size()==before: continue
  var crate = crates[-1]
  game.player.position = crate.position+Vector2(0,-42)
  game.player.set_physics_process(true)
  for tick in range(4): await physics_frame
  Input.action_press("move_left")
  Input.action_press("jump")
  for tick in range(26): await physics_frame
  Input.action_release("move_left")
  Input.action_release("jump")
  check(game.player.position.y+21 <= next.position.y+1,"physics jump from the crate reaches the next stair level")
 check(game.wood_count==0,"four required crates consume exactly twelve planks")
 var returns: Array = game.level.get_node("Plataformas").get_children().filter(func(node): return node.name.begins_with("Retorno"))
 check(returns.size()==36 and returns.all(func(node): return node.one_way),"three return shafts have jumpable one-way steps")
 check(not game.level.goal_rect().has_point(Vector2(game.FINISH_X,414)) and game.level.goal_rect().has_point(Vector2(game.FINISH_X,894)),"arrival requires entering the house on the lower floor")
 if "--capture" in OS.get_cmdline_user_args():
  game.set_physics_process(false)
  game.player.set_physics_process(false)
  var camera: Camera2D
  for child in game.player.get_children():
   if child is Camera2D: camera = child
  camera.position_smoothing_enabled = false
  for capture in [["forest",Vector2(160,414)],["canopy",Vector2(4500,-306)],["underground",Vector2(6500,894)],["stairs",Vector2(46500,174)],["house",Vector2(47600,894)]]:
   game.player.position = capture[1]
   game.player.velocity = Vector2.ZERO
   game.player.set_physics_process(true)
   for tick in range(5): await physics_frame
   game.player.set_physics_process(false)
   game.player._update_animation(0)
   camera.reset_smoothing()
   await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/qa_wide_"+capture[0]+".png"))
 game.queue_free()
 await process_frame
 print("WIDE_LEVEL_FAILURES=",failures)
 quit(1 if failures else 0)

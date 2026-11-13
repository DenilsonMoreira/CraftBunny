extends SceneTree
var checks := 0
var failures := 0
var game: Node2D
var p: CharacterBody2D
func check(value: bool,label: String) -> void:
 checks += 1
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func ticks(count: int) -> void:
 for index in range(count):
  await physics_frame
  await process_frame
func action(name: String,pressed: bool) -> void:
 var event := InputEventAction.new()
 event.action = name
 event.pressed = pressed
 Input.parse_input_event(event)
func capture(label: String,at: Vector2) -> void:
 p.position = at
 p.velocity = Vector2.ZERO
 for child in p.get_children():
  if child is Camera2D:
   child.position_smoothing_enabled = false
   child.make_current()
 await ticks(2)
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../docs/qa_tools_"+label+".png"))==OK,"capture "+label)
func try_gap(tree) -> void:
 p.controls_enabled = false
 var rabbit: CharacterBody2D = game.PLAYER_SCRIPT.new()
 rabbit.position = Vector2(tree.position.x+20,414)
 rabbit.fall_death_y = 1260
 rabbit.pit_warning_y = 1170
 game.add_child(rabbit)
 rabbit.add_collision_exception_with(tree)
 rabbit.controls_enabled = true
 rabbit.velocity = Vector2(230,0)
 action("move_right",true)
 await ticks(2)
 action("jump",true)
 await ticks(2)
 action("jump",false)
 await ticks(2)
 action("jump",true)
 action("dash",true)
 await ticks(1)
 action("dash",false)
 for tick in range(180):
  if rabbit.health<=0: break
  await ticks(1)
 check(rabbit.position.x < tree.position.x+40+1024 and rabbit.position.y>435,"1024px chasm defeats jump plus dash plus held glide without its bridge")
 for name in ["move_right","jump","dash"]: action(name,false)
 rabbit.queue_free()
 await process_frame
 p.controls_enabled = true
func _run() -> void:
 game = load("res://main.tscn").instantiate()
 root.add_child(game)
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 p = game.player
 var trees := get_nodes_in_group("tool_obstacles").filter(func(n): return n.kind=="tree")
 var rocks := get_nodes_in_group("tool_obstacles").filter(func(n): return n.kind=="rock")
 check(trees.size()==2 and rocks.size()==2,"four editable challenges instantiated")
 var all_gaps_empty := true
 for tree in trees:
  var start: float = tree.position.x+40
  for layer in game.level.get_node("Terrenos").get_children():
   for x in range(int(start/64),int((start+1024)/64)):
    all_gaps_empty = all_gaps_empty and layer.get_cell_source_id(Vector2i(x,0))==-1
  for surface in game.level.get_node("Plataformas").get_children():
   var rect: Rect2 = surface.surface_rect()
   all_gaps_empty = all_gaps_empty and not (rect.position.x<start+1024 and rect.end.x>start)
 check(all_gaps_empty,"tree chasms have no lower-floor or canopy bypass platforms")
 var stack_bound := 230*(sqrt(2*2700.0/1150)+1+340.0/1150)+150
 check(stack_bound+26<1024,"conservative ascent/fall/glide/dash bound with all 80 boards and body width still falls short")
 for tree in trees:
  await try_gap(tree)
  p.position = tree.position+Vector2(-34,-21)
  p.velocity = Vector2.ZERO
  p.equipped_tool = 1
  p.switch_remaining = 0
  p.hammer_timer = 0
  p.attack_visual_timer = 0
  p.facing = 1
  await ticks(3)
  if "--capture" in OS.get_cmdline_user_args(): await capture("tree",p.position)
  for hit in range(3):
   action("attack",true)
   await ticks(1)
   action("attack",false)
   await ticks(35)
  await ticks(40)
  check(tree.bridge_ready,"three real axe swings create a bridge")
  action("move_right",true)
  for tick in range(360):
   if p.position.x > tree.position.x+40+1024+20: break
   await ticks(1)
  action("move_right",false)
  check(p.position.x>tree.position.x+40+1024 and p.health==3 and p.position.y<440,"rabbit physically crosses the fallen tree without falling")
 for rock in rocks:
  p.position = rock.position+Vector2(-34,-21)
  p.velocity = Vector2.ZERO
  p.equipped_tool = 2
  p.switch_remaining = 0
  p.hammer_timer = 0
  p.attack_visual_timer = 0
  p.facing = 1
  await ticks(3)
  action("move_right",true)
  await ticks(15)
  action("move_right",false)
  check(p.position.x<rock.position.x and not rock.broken,"unbroken rock physically blocks the low corridor")
  if "--capture" in OS.get_cmdline_user_args(): await capture("rock",p.position)
  for hit in range(3):
   action("attack",true)
   await ticks(1)
   action("attack",false)
   await ticks(62)
  check(rock.broken,"three real pickaxe attacks break blocking rock")
  action("move_right",true)
  await ticks(40)
  action("move_right",false)
  check(p.position.x>rock.position.x+70 and p.health==3,"opened corridor allows walking to visible carrots")
 game.queue_free()
 await process_frame
 print("TOOL_LEVEL_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures==0 else 1)

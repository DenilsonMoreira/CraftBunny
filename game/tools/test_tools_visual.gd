extends SceneTree
var failures := 0
var game: Node2D
var p: CharacterBody2D
func _initialize() -> void: call_deferred("_run")
func ticks(count: int) -> void:
 for i in range(count):
  await physics_frame
  await process_frame
func capture(label: String) -> void:
 await RenderingServer.frame_post_draw
 var prefix := "qa_art_" if "--art" in OS.get_cmdline_user_args() else "qa_tools_"
 var suffix := "_051" if "--art" in OS.get_cmdline_user_args() else ""
 var path := ProjectSettings.globalize_path("res://../docs/"+prefix+label+suffix+".png")
 if root.get_texture().get_image().save_png(path)!=OK: failures += 1
func _run() -> void:
 game = load("res://main.tscn").instantiate()
 game.controls_file = "user://qa_tools_visual_controls.cfg"
 root.add_child(game)
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 p = game.player
 for child in p.get_children():
  if child is Camera2D: child.position_smoothing_enabled = false
 p.equipped_tool = 1
 p.switch_name_timer = 1
 await ticks(4)
 if not is_instance_valid(game.mobile_controls):
  failures += 1
  push_error("run visual tools test with --touch")
 await capture("touch")
 p.equipped_tool = 3
 game.carrot_count = 8
 game._update_hud()
 Input.action_press("attack")
 await ticks(3)
 await capture("aim")
 p.aiming = false
 Input.action_release("attack")
 var tree = get_nodes_in_group("tool_obstacles").filter(func(n):return n.kind=="tree")[0]
 p.equipped_tool = 1
 p.position = tree.position+Vector2(-70,-21)
 p.velocity = Vector2.ZERO
 await ticks(3)
 await capture("tree")
 for i in range(3): tree.apply_tool(1)
 await ticks(45)
 await capture("bridge")
 var rock = get_nodes_in_group("tool_obstacles").filter(func(n):return n.kind=="rock")[0]
 p.equipped_tool = 2
 p.position = rock.position+Vector2(-40,-21)
 p.velocity = Vector2.ZERO
 await ticks(3)
 await capture("rock")
 for i in range(3): rock.apply_tool(2)
 await ticks(35)
 await capture("opened")
 game.queue_free()
 await process_frame
 print("TOOLS_VISUAL_FAILURES=",failures)
 quit(failures)

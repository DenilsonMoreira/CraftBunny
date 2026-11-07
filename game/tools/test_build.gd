extends SceneTree
var failures := 0
func check(value: bool, label: String) -> void:
 if value: print("PASS: ", label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void:
 call_deferred("_run")
func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 game.player.set_physics_process(false)
 game.player.position = Vector2(100,414)
 game.player.facing = 1
 await physics_frame
 game.wood_count = 1
 game.carrot_count = 22
 game._on_box_requested()
 check(get_nodes_in_group("crates").is_empty() and game.wood_count == 1, "22 carrots cannot replace three planks")
 game.wood_count = 22
 game._on_box_requested()
 var crates := get_nodes_in_group("crates")
 check(crates.size() == 1 and game.wood_count == 19, "22 planks builds a crate and costs three")
 var first = crates[0]
 game._on_box_requested()
 crates = get_nodes_in_group("crates")
 check(crates.size() == 2 and game.wood_count == 16, "second crate stacks even in same tick")
 if crates.size() == 2:
  check(is_equal_approx(first.position.x,crates[1].position.x) and is_equal_approx(first.position.y-crates[1].position.y,42), "stack aligned with exact 42px spacing")
 game._on_box_requested()
 check(get_nodes_in_group("crates").size() == 2 and game.wood_count == 16, "out of reach placement does not spend wood")
 game.player.position = Vector2(100,330)
 await physics_frame
 game._on_box_requested()
 check(get_nodes_in_group("crates").size() == 3 and game.wood_count == 13, "higher position allows third stacked crate")
 for crate in get_nodes_in_group("crates"): crate.queue_free()
 await physics_frame
 game.player.position = Vector2(950,414)
 await physics_frame
 game._on_box_requested()
 check(get_nodes_in_group("crates").is_empty() and game.wood_count == 13, "unsupported gap cannot consume materials")
 game.player.position = Vector2(100,414)
 await physics_frame
 game._on_box_requested()
 game.player.position = Vector2(110,372)
 await physics_frame
 game._on_box_requested()
 check(get_nodes_in_group("crates").size() == 1 and game.wood_count == 10, "stack overlapping player rejected")
 # A platform top is a valid surface, not just the global ground height.
 game._add_solid(Vector2(360,300),Vector2(120,20))
 game.ledges.append([360.0,300.0,120.0])
 game.player.position = Vector2(320,269)
 await physics_frame
 game._on_box_requested()
 crates = get_nodes_in_group("crates")
 check(crates.size() == 2 and is_equal_approx(crates[-1].position.y,269) and game.wood_count == 7, "crate builds on platform surface")
 game.queue_free()
 await process_frame
 print("BUILD_FAILURES=",failures)
 quit(1 if failures else 0)

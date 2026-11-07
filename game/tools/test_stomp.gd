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
 for enemy in get_nodes_in_group("enemy"): enemy.queue_free()
 await physics_frame
 for kind in ["cobra", "guaxinim", "ave"]:
  var enemy = game.ENEMY_SCRIPT.new()
  enemy.setup(kind, Vector2(420, 422 if kind != "ave" else 423), game.player)
  enemy.add_to_group("enemy")
  game.add_child(enemy)
  var original_hp: int = enemy.hp
  var player = game.player
  player.position = Vector2(420,350)
  player.velocity = Vector2(0,140)
  player.stomp_contact_grace = 0
  player.stomp_visual_timer = 0
  player.ground_bounce_pending = false
  player.ground_bounce_count = 0
  var hit := false
  var heard := false
  var seen := {}
  for tick in range(100):
   await physics_frame
   if player.stomp_visual_timer > 0:
    seen[player.stomp_sprite.frame] = true
   if enemy.hp < original_hp and not hit:
    hit = true
    heard = game.impact_player.playing
    check(enemy.hp == original_hp-1, kind+" takes exactly one damage")
    check(player.velocity.y < 0, kind+" stomp rebounds upward")
    # Move the test target aside so subsequent landings exercise ground bounce.
    enemy.position.x = 800
  check(hit and player.health == 3, kind+" stomp does not hurt rabbit")
  check(heard, kind+" impact SFX plays")
  check(seen.size() == 8, kind+" displays eight stomp frames")
  check(player.ground_bounce_count == 1 and not player.ground_bounce_pending, kind+" exactly one ground bounce")
  enemy.queue_free()
  await physics_frame
 var side_enemy = game.ENEMY_SCRIPT.new()
 side_enemy.setup("cobra", Vector2(420,422), game.player)
 side_enemy.add_to_group("enemy")
 game.add_child(side_enemy)
 game.player.position = Vector2(386,414)
 game.player.velocity = Vector2.ZERO
 game.player.stomp_contact_grace = 0
 Input.action_press("move_right")
 for tick in range(12): await physics_frame
 Input.action_release("move_right")
 check(side_enemy.hp == 2, "side contact does not stomp")
 side_enemy.position = Vector2(420,350)
 game.player.position = Vector2(420,390)
 game.player.velocity = Vector2(0,-150)
 for tick in range(12): await physics_frame
 check(side_enemy.hp == 2, "rising from below does not stomp")
 side_enemy.queue_free()
 await physics_frame
 game.wood_count = 6
 for i in range(20):
  var pickup = game.PICKUP_SCRIPT.new()
  pickup.setup("wood")
  pickup.position = Vector2(1000,-100)
  game.add_child(pickup)
  game._on_pickup(pickup)
 check(game.wood_count == 26 and game.status_hud.wood == 26, "wood exceeds six and HUD follows")
 game.player.position = Vector2(100,414)
 game.player.velocity = Vector2.ZERO
 await physics_frame
 game._on_box_requested()
 var crates := get_nodes_in_group("crates")
 check(crates.size() == 1 and game.wood_count == 23, "crate costs exactly three")
 if not crates.is_empty():
  var crate = crates[0]
  crate.take_hammer_hit()
  check(crate.hp == 1, "damaged crate keeps one HP")
  crate.take_hammer_hit()
  check(crate.is_queued_for_deletion(), "second hit destroys crate")
 game.queue_free()
 await process_frame
 print("STOMP_FAILURES=", failures)
 quit(1 if failures else 0)

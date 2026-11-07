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
 game.player.set_physics_process(false)
 game.player.position = Vector2(100,414)
 game.player.facing = 1
 game.player.invincible_timer = 100
 await physics_frame
 var target = game.ENEMY_SCRIPT.new()
 target.setup("guaxinim",Vector2(180,422),game.player)
 target.add_to_group("enemy")
 game.add_child(target)
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 5, "hammer misses distant enemy at 80px")
 target.position.x = 140
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 4, "hammer hits nearby enemy at 40px for one damage")
 target.hp = 5
 target.damage_recovery = 0
 target.position.x = 160
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 4, "larger mallet reaches enemy at 60px")
 target.hp = 5
 target.damage_recovery = 0
 target.position.x = 164
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 5, "enemy just beyond new hammer boundary is missed")
 target.hp = 5
 target.damage_recovery = 0
 target.position.x = 52
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 5, "hammer does not hit behind player")
 game.player.facing = -1
 target.position.x = 60
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 4, "left-facing hammer has matching short reach")
 target.hp = 5
 target.damage_recovery = 0
 target.position = Vector2(60,354)
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(target.hp == 5, "hammer misses vertically distant target")
 target.queue_free()
 var crate = game.BOX_SCRIPT.new()
 crate.position = Vector2(20,414)
 crate.add_to_group("crates")
 game.add_child(crate)
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(crate.hp == 2, "hammer misses distant crate")
 crate.position.x = 55
 game._on_hammer_used(game.player.get_hammer_hitbox())
 check(crate.hp == 1, "hammer hits adjacent crate")
 crate.queue_free()
 await physics_frame
 game.player.position = Vector2(500,414)
 var bird = game.ENEMY_SCRIPT.new()
 bird.setup("ave",Vector2(500,320),game.player)
 bird.add_to_group("enemy")
 bird.active = true
 game.add_child(bird)
 var seen := {}
 var low: Vector2 = bird.position
 var high: Vector2 = bird.position
 var returned := false
 var recover_seen := false
 for tick in range(300):
  await physics_frame
  seen[bird.state] = true
  low.x = minf(low.x,bird.position.x)
  low.y = minf(low.y,bird.position.y)
  high.x = maxf(high.x,bird.position.x)
  high.y = maxf(high.y,bird.position.y)
  if bird.state == "recover": recover_seen = true
  if recover_seen and bird.state != "recover" and bird.position.y <= bird.home_position.y+5: returned = true
 check(seen.has("windup") and seen.has("attack"), "overhead bird warns and dives instead of hovering stuck")
 check(seen.has("recover") and returned, "bird recovers to flight altitude after dive")
 check(high.y-low.y > 40 and high.x-low.x > 30, "bird makes visible vertical and lateral movement")
 check(game.player.health == 3, "invulnerable test target survives")
 bird.position = Vector2(500,245)
 bird.home_position = bird.position
 bird.patrol_origin = bird.position
 bird.state = "patrol"
 bird.timer = 0
 bird.attack_timer = 0
 var landed := [0]
 bird.attack_landed.connect(func(_amount,_x): landed[0] += 1)
 for tick in range(180): await physics_frame
 check(landed[0] > 0, "bird from normal spawn altitude approaches close enough to land dive")
 game.queue_free()
 await process_frame
 print("BIRD_HAMMER_FAILURES=",failures)
 quit(1 if failures else 0)

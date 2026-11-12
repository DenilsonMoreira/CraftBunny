extends SceneTree
var failures := 0
func check(value: bool,label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.global_ranking.api_url = ""
 game._begin_game()
 game.music_player.stop()
 for enemy in get_nodes_in_group("enemy"): enemy.queue_free()
 await process_frame
 game.player.set_physics_process(false)
 game.player.position = Vector2(500,414)
 game.player.invincible_timer = 100
 var bird = game.ENEMY_SCRIPT.new()
 bird.setup("ave",Vector2(500,320),game.player)
 game.add_child(bird)
 bird.active = true
 var states := {}
 var grounded_frames := 0
 var ground_duration := 0.0
 var left_ground := false
 var hurt_stayed := false
 var returned := false
 for tick in range(360):
  await physics_frame
  states[bird.state] = true
  if bird.state=="grounded":
   grounded_frames += 1
   if grounded_frames==4:
    bird.take_hit(1,game.player.position.x)
    hurt_stayed = bird.state=="grounded" and bird.hp==6
  elif grounded_frames>0 and not left_ground:
   left_ground = true
   ground_duration = grounded_frames*bird.get_physics_process_delta_time()
  if left_ground and bird.state not in ["land","grounded","recover"] and bird.position.y<=bird.home_position.y+5:
   returned = true
   break
 check(states.has("windup") and states.has("attack") and states.has("land"),"bird telegraphs, attacks and descends to a real floor")
 check(grounded_frames>0,"bird reaches a grounded recovery state")
 check(ground_duration>=0.5-1.0/60.0 and ground_duration<=0.5+2.0/60.0,"ground recovery lasts 0.5 seconds within one physics step")
 check(hurt_stayed,"taking damage does not cancel the grounded vulnerability window")
 check(states.has("recover") and returned,"bird returns to flight after grounded recovery without hovering stuck")
 check(game.player.health==3,"invulnerable fixture is unchanged by the dive")
 game.queue_free()
 await process_frame
 print("BIRD_GROUND_FAILURES=",failures)
 quit(1 if failures else 0)

extends SceneTree
var failures := 0

func check(value: bool, message: String) -> void:
 if value: print("PASS: ", message)
 else:
  failures += 1
  push_error(message)

func _initialize() -> void:
 call_deferred("_run")

func create_game():
 var game = load("res://main.tscn").instantiate()
 game.records_file = "user://qa_death_records_unused.cfg"
 game.controls_file = "user://qa_death_controls_unused.cfg"
 game.settings_file = "user://qa_death_audio_unused.cfg"
 root.add_child(game)
 game._begin_game()
 game._set_enemies_active(false)
 return game

func _run() -> void:
 var game = create_game()
 await physics_frame
 game.player.take_damage(3, 0)
 check(not game.music_player.playing and game.death_player.playing, "damage death stops theme and starts death SFX")
 check(not game.scream_player.playing, "damage death does not scream")
 var seen := {}
 for tick in range(55):
  await physics_frame
  seen[game.player.death_sprite.frame] = true
 check(seen.size() == 8, "all eight death frames displayed")
 check(game.player.death_sprite.frame == 7, "final death pose held")
 check(game.is_finished and game.status_hud.hp == 0, "attempt finished and HUD empty hearts")
 check(is_equal_approx(game.player.position.y+21, game.FLOOR_Y), "corpse lands on ground")
 game.queue_free()
 await process_frame
 game = create_game()
 await physics_frame
 # Current three-height level: trigger the real lower kill-plane path.
 game.player.position = Vector2(480,game.player.pit_warning_y+5)
 game.player.velocity = Vector2.ZERO
 for tick in range(3): await physics_frame
 check(game.pit_audio_started and game.scream_player.playing, "fall triggers funny scream")
 check(not game.music_player.playing and not game.death_player.playing, "theme stopped; death SFX waits for scream")
 var overlapping := false
 var death_started := false
 var limit := Time.get_ticks_msec()+8000
 while Time.get_ticks_msec() < limit:
  await process_frame
  if game.scream_player.playing and game.death_player.playing: overlapping = true
  if game.death_player.playing:
   death_started = true
   break
 check(death_started and not overlapping and not game.scream_player.playing, "scream finishes before death SFX starts")
 check(game.player.death_cause == "pit" and game.is_finished, "pit ends attempt")
 game.queue_free()
 await process_frame
 print("DEATH_FAILURES=", failures)
 quit(1 if failures else 0)

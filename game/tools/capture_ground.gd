extends SceneTree

func _initialize() -> void:
 call_deferred("_capture")

func _capture() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 var title := "--title" in OS.get_cmdline_user_args()
 if not title: game._begin_game()
 if "--settings" in OS.get_cmdline_user_args(): game._show_settings()
 if "--controls" in OS.get_cmdline_user_args(): game._show_controls()
 if "--reset-local" in OS.get_cmdline_user_args():
  # Isolated in-memory fixture; never writes or clears the player's records.
  game.records.assign([{"name":"ABC","carrots":50}])
  game._show_local_reset_confirmation()
 game.music_player.stop()
 game._set_enemies_active(false)
 if "--hearts" in OS.get_cmdline_user_args():
  game.player.health = 2
  game._update_hud()
  game._spawn_pickup("heart",Vector2(240,398))
 if "--gap" in OS.get_cmdline_user_args():
  game.player.position = Vector2(875,414)
  game.wood_count = 18
  game._update_hud()
  game._on_box_requested()
 for frame in range(20): await physics_frame
 if "--feedback" in OS.get_cmdline_user_args():
  var enemy = game.ENEMY_SCRIPT.new()
  enemy.setup("guaxinim",Vector2(185,422),game.player)
  game.add_child(enemy)
  enemy.active = true
  enemy.set_physics_process(false)
  enemy.set_process(false)
  enemy.take_hit(1,100)
  enemy.alert_timer = enemy.ALERT_TIME
  enemy._process(0.12)
 if "--attack" in OS.get_cmdline_user_args():
  game.player.set_physics_process(false)
  game.player.attack_facing = 1
  game.player.attack_sprite.animation = "attack"
  game.player.attack_sprite.pause()
  game.player.attack_visual_timer = game.player.ATTACK_VISUAL_DURATION * (1.0-7.0/12.0)
  game.player._update_animation(0)
 for child in game.player.get_children():
  if child is Camera2D: child.reset_smoothing()
 await process_frame
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image()
 var output := "res://docs/qa_title.png" if title else ("res://docs/qa_hearts_clouds.png" if "--hearts" in OS.get_cmdline_user_args() else ("res://docs/qa_gap_crate.png" if "--gap" in OS.get_cmdline_user_args() else "res://docs/qa_ground_v2.png"))
 var error := image.save_png(output)
 if "--touch" in OS.get_cmdline_user_args():
  error = image.save_png("res://docs/qa_android_controls.png")
 if "--attack" in OS.get_cmdline_user_args():
  error = image.save_png("res://docs/qa_attack_12.png")
 for mode in ["settings","controls","feedback","reset-local"]:
  if "--"+mode in OS.get_cmdline_user_args():
   error = image.save_png("res://docs/qa_pixel_"+mode+".png")
 print("GROUND_CAPTURE=", error)
 print("PLAYER_FEET=", game.player.position.y + 21, " FLOOR=", game.FLOOR_Y)
 game.queue_free()
 await process_frame
 quit(0 if error == OK else 1)

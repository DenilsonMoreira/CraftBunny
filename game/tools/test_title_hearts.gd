extends SceneTree
var failures := 0
func check(value: bool, message: String) -> void:
 if value: print("PASS: ",message)
 else:
  failures += 1
  push_error(message)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 check(game.title_screen.get_node("TitleArt").texture != null, "new pixel title art loads")
 check(game.title_screen.get_node("NovoJogo").size.x > 200, "start pixel art button has touch-friendly width")
 game.title_screen.get_node("Recordes").pressed.emit()
 check(not game.game_started and game.overlay_panel != null, "records button opens ranking")
 game._show_title()
 game.title_screen.get_node("Opcoes").pressed.emit()
 check(game.overlay_panel != null, "options accessible from title")
 game._show_title()
 game.title_screen.get_node("NovoJogo").pressed.emit()
 check(game.game_started and game.title_screen == null, "new game removes title art")
 game.music_player.stop()
 game._set_enemies_active(false)
 check(game.get_node("CloudParallax").scroll_scale.x < 0.38, "cloud layer behind forest parallax")
 check(game.status_hud.full_heart != null and game.status_hud.empty_heart != null, "full and empty heart textures loaded")
 var pickup = game.PICKUP_SCRIPT.new()
 pickup.setup("heart")
 pickup.position = Vector2(-500,-100)
 game.add_child(pickup)
 check(pickup.art != null and pickup.art.texture != null, "heart pickup uses pixel art")
 game.player.health = 3
 game._on_pickup(pickup)
 check(not pickup._claimed, "full health does not consume heart")
 game.player.health = 2
 game._on_pickup(pickup)
 check(game.player.health == 3 and game.status_hud.hp == 3 and pickup._claimed, "heart restores one HP and updates HUD")
 game.queue_free()
 await process_frame
 print("TITLE_HEART_FAILURES=",failures)
 quit(1 if failures else 0)

extends SceneTree
var failures := 0
func check(value: bool, label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 check(game.hud.theme.default_font != null,"pixel font applied to UI")
 check(game.title_screen.get_node("Opcoes").get_theme_stylebox("normal") is StyleBoxTexture,"title options have pixel art texture")
 check(game.title_screen.get_node("Controles").text == "CONTROLES","title exposes controls button")
 game.title_screen.get_node("Controles").pressed.emit()
 check(game.overlay_panel != null and game.overlay_panel.get_theme_stylebox("panel") is StyleBoxTexture,"controls use pixel wood panel")
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 game.player.set_physics_process(false)
 game.player.position = Vector2(500,414)
 for kind in ["cobra","guaxinim","ave"]:
  var enemy = game.ENEMY_SCRIPT.new()
  enemy.setup(kind,Vector2(650,390),game.player)
  game.add_child(enemy)
  enemy.active = true
  enemy.set_physics_process(false)
  enemy.set_process(false)
  enemy._physics_process(1.0/60.0)
  check(enemy.player_detected and enemy.alert_timer > 0,kind+" shows alert on detection")
  enemy._process(0.2)
  var remaining: float = enemy.alert_timer
  enemy._physics_process(1.0/60.0)
  check(enemy.alert_timer <= remaining,kind+" does not restart alert every frame")
  game.player.position.x = 2000
  enemy._physics_process(1.0/60.0)
  check(not enemy.player_detected,kind+" loses distant target")
  game.player.position.x = 500
  enemy._physics_process(1.0/60.0)
  check(is_equal_approx(enemy.alert_timer,enemy.ALERT_TIME),kind+" alerts again on reacquisition")
  var old_hp: int = enemy.hp
  enemy.take_hit(1,500)
  check(enemy.hp == old_hp-1 and enemy.animated_sprite.animation == "hurt",kind+" damage and hurt pose")
  check(enemy.hit_material.get_shader_parameter("hit_strength") == 1.0 and enemy.health_feedback_timer > 0,kind+" flash and health feedback begin immediately")
  enemy.take_hit(1,500)
  check(enemy.hp == old_hp-1,kind+" repeated hit protection preserved")
  enemy._process(0.3)
  check(enemy.hit_material.get_shader_parameter("hit_strength") == 0.0,kind+" flash clears")
  enemy.active = false
  var held: float = enemy.health_feedback_timer
  enemy._process(0.3)
  check(enemy.health_feedback_timer == held,kind+" visual feedback freezes during pause")
  enemy.active = true
  enemy._process(2)
  check(enemy.health_feedback_timer == 0 and enemy.alert_timer == 0,kind+" feedback expires")
  enemy.queue_free()
 game.queue_free()
 await process_frame
 print("PIXEL_FEEDBACK_FAILURES=",failures)
 quit(1 if failures else 0)

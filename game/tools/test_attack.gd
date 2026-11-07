extends SceneTree

func _initialize() -> void:
 call_deferred("_run")

func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game._begin_game()
 game._set_enemies_active(false)
 game.music_player.stop()
 var player = game.player
 var count: int = player.attack_sprite.sprite_frames.get_frame_count("attack")
 var hits := [0]
 player.hammer_used.connect(func(_rect): hits[0] += 1)
 Input.action_press("attack")
 var seen := {}
 for tick in range(28):
  await physics_frame
  if player.attack_sprite.visible:
   seen[player.attack_sprite.frame] = true
  if tick == 1: Input.action_release("attack")
 print("ATTACK_FRAMES=", count, " SEEN=", seen.size(), " HITS=", hits[0])
 var camera: Camera2D
 for child in player.get_children():
  if child is Camera2D: camera = child
 var zoom_ok: bool = camera != null and camera.zoom.is_equal_approx(Vector2(1.25,1.25))
 var box: Rect2 = player.get_hammer_hitbox()
 var right_box := box
 player.facing = -1
 var left_box: Rect2 = player.get_hammer_hitbox()
 var reach_ok: bool = box.size == Vector2(32,26) and is_equal_approx(right_box.end.x-player.position.x, player.position.x-left_box.position.x)
 var passed: bool = count == 12 and seen.size() == 12 and hits[0] == 1 and not player.attack_sprite.visible and zoom_ok and reach_ok
 print("ZOOM_125=",zoom_ok," HAMMER_MIRRORED_32x26=",reach_ok)
 print("ATTACK_TEST=", "PASS" if passed else "FAIL")
 game.queue_free()
 await process_frame
 quit(0 if passed else 1)

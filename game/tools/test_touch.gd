extends SceneTree
var failures := 0
func check(value: bool, label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func touch(controller, index: int, point: Vector2, pressed: bool) -> void:
 var event := InputEventScreenTouch.new()
 event.index = index
 event.position = point
 event.pressed = pressed
 controller._input(event)
func drag(controller, index: int, point: Vector2) -> void:
 var event := InputEventScreenDrag.new()
 event.index = index
 event.position = point
 controller._input(event)
func _run() -> void:
 quit_on_go_back = false
 var game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 var controller = Control.new()
 controller.set_script(load("res://scripts/touch_controls.gd"))
 controller.game = game
 game.hud.add_child(controller)
 game.mobile_controls = controller
 controller.pause_requested.connect(game._toggle_pause)
 await process_frame
 controller.visible = true
 touch(controller,0,controller.STICK_CENTER,true)
 check(controller.stick_finger==0 and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"),"stick center captures a finger without moving")
 drag(controller,0,controller.STICK_CENTER+Vector2(4,0))
 check(not Input.is_action_pressed("move_right"),"stick deadzone prevents accidental motion")
 drag(controller,0,controller.STICK_CENTER+Vector2(40,0))
 check(Input.is_action_pressed("move_right"),"drag from neutral starts right movement")
 touch(controller,7,controller.STICK_CENTER-Vector2(40,0),true)
 check(controller.stick_finger==0 and Input.is_action_pressed("move_right"),"second finger cannot steal the stick")
 touch(controller,7,controller.STICK_CENTER,false)
 check(Input.is_action_pressed("move_right"),"releasing unrelated finger preserves stick movement")
 drag(controller,0,controller.STICK_CENTER-Vector2(40,0))
 check(Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"),"drag across center switches direction without a stuck action")
 drag(controller,0,Vector2(600,300))
 check(controller.stick_offset.length() <= controller.STICK_TRAVEL+0.01 and Input.is_action_pressed("move_right") and not Input.is_action_pressed("craft"),"stick captures drags outside its base and clamps the knob")
 touch(controller,0,Vector2(600,300),false)
 check(controller.stick_finger==-1 and controller.stick_offset==Vector2.ZERO and not Input.is_action_pressed("move_right"),"lifting stick finger recenters and stops motion")
 touch(controller,0,controller.STICK_CENTER,true)
 drag(controller,0,controller.STICK_CENTER+Vector2(0,-40))
 check(not Input.is_action_pressed("jump") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"),"vertical stick drag does not jump or move horizontally")
 controller.release_all()
 touch(controller,1,Vector2(145,450),true)
 touch(controller,2,Vector2(885,430),true)
 check(Input.is_action_pressed("move_right") and Input.is_action_pressed("jump"),"move and jump at same time")
 touch(controller,2,Vector2(885,430),false)
 check(Input.is_action_pressed("move_right") and not Input.is_action_pressed("jump"),"releasing jump preserves movement")
 touch(controller,3,Vector2(775,475),true)
 check(Input.is_action_pressed("attack"),"attack touch")
 touch(controller,3,Vector2(775,475),false)
 touch(controller,4,Vector2(680,475),true)
 check(Input.is_action_pressed("craft"),"craft touch")
 touch(controller,4,Vector2(680,475),false)
 touch(controller,5,Vector2(910,110),true)
 check(game.pause_open and not Input.is_action_pressed("move_right") and controller.stick_finger==-1 and controller.stick_offset==Vector2.ZERO,"pause releases held actions and recenters the stick")
 touch(controller,5,Vector2(910,110),true)
 check(not game.pause_open,"touch pause resumes")
 touch(controller,6,Vector2(55,450),true)
 controller._notification(controller.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(not Input.is_action_pressed("move_left") and controller.stick_finger==-1 and controller.stick_offset==Vector2.ZERO,"focus loss clears touch action and stick capture")
 game.player.position = Vector2(100,414)
 game.player.velocity = Vector2.ZERO
 for tick in range(3): await physics_frame
 var initial: Vector2 = game.player.position
 touch(controller,8,Vector2(145,450),true)
 touch(controller,9,Vector2(885,430),true)
 for tick in range(8): await physics_frame
 check(game.player.position.x > initial.x and game.player.position.y < initial.y,"touch actions move and jump the character")
 controller.release_all()
 game.music_player.play()
 game._notification(game.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(game.pause_open and game.music_player.stream_paused,"background pauses gameplay and music")
 game._notification(game.NOTIFICATION_APPLICATION_FOCUS_IN)
 game._toggle_pause()
 game._notification(game.NOTIFICATION_WM_GO_BACK_REQUEST)
 check(game.pause_open,"Android back request opens pause")
 if "--capture" in OS.get_cmdline_user_args():
  game._toggle_pause()
  touch(controller,15,controller.STICK_CENTER+Vector2(35,0),true)
  await process_frame
  await RenderingServer.frame_post_draw
  var capture_path := ProjectSettings.globalize_path("res://../docs/qa_touch_analog_037.png")
  check(get_root().get_texture().get_image().save_png(capture_path)==OK,"rendered analog screenshot saved")
  controller.release_all()
 game.queue_free()
 await process_frame
 print("TOUCH_FAILURES=",failures)
 quit(1 if failures else 0)

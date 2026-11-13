extends SceneTree
var checks := 0
var failures := 0
func check(value: bool,label: String) -> void:
 checks += 1
 if not value:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func ticks(count: int) -> void:
 for i in range(count):
  await process_frame
  await physics_frame
func key(code: int,pressed := true) -> InputEventKey:
 var event := InputEventKey.new()
 event.physical_keycode = code
 event.pressed = pressed
 return event
func capture(label: String) -> void:
 await RenderingServer.frame_post_draw
 var path := ProjectSettings.globalize_path("user://qa_opening_"+label+"_053.png")
 check(root.get_texture().get_image().save_png(path)==OK,"saved "+label)
 print("OPENING_CAPTURE=",path)
func _run() -> void:
 var packed = load("res://opening.tscn")
 var opening = packed.instantiate()
 opening.enter_title = false
 opening.settings_file = "user://qa_opening_settings.cfg"
 var cfg := ConfigFile.new()
 cfg.set_value("audio","master",.8)
 cfg.set_value("audio","music",0.0)
 cfg.save(opening.settings_file)
 root.add_child(opening)
 opening.set_process(false)
 await ticks(2)
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://opening.tscn","opening is project entry scene")
 check(not ProjectSettings.get_setting("application/boot_splash/show_image"),"engine splash disabled")
 check(opening.music.playing and opening.music.stream.resource_path=="","opening has its own looping stream instance")
 check(opening.music.stream.loop and opening.music.bus=="Music","birds loop on Music bus")
 check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")),"opening respects saved zero music volume")
 check(get_nodes_in_group("player").is_empty(),"no gameplay player/attempt during opening")
 var source: Texture2D = opening.STORY
 check(source.get_size()==Vector2(1374,1145),"approved corrected storyboard unchanged")
 for i in range(6):
  check(opening.slide_index==i,"slide ordered "+str(i))
  var frame: AtlasTexture = opening.picture.texture
  check(frame.region==opening.REGIONS[i] and Rect2(Vector2.ZERO,source.get_size()).encloses(frame.region),"panel crop excludes gutters and stays in atlas "+str(i))
  opening._process(.4)
  check(opening.picture.modulate.a==1,"crossfade completes "+str(i))
  if "--capture" in OS.get_cmdline_user_args(): await capture(str(i+1))
  opening.advance()
 check(opening.completed,"sixth panel completes opening")
 var completions := [0]
 opening.finished.connect(func():completions[0]+=1)
 opening.finish()
 check(completions[0]==0,"finish is idempotent")
 var isolated_music = opening.music
 opening.queue_free()
 await ticks(2)
 check(not is_instance_valid(isolated_music),"isolated opening frees audio with scene")
 opening = packed.instantiate()
 opening.enter_title = false
 root.add_child(opening)
 opening.set_process(false)
 await ticks(1)
 var touch := InputEventScreenTouch.new()
 touch.pressed = true
 touch.position = Vector2(300,200)
 opening._unhandled_input(touch)
 var mouse := InputEventMouseButton.new()
 mouse.button_index = MOUSE_BUTTON_LEFT
 mouse.pressed = true
 opening._unhandled_input(mouse)
 check(opening.slide_index==1,"touch plus emulated mouse advances once")
 opening.last_navigation = -1000
 opening._unhandled_input(key(KEY_SPACE))
 check(opening.slide_index==2,"Space advances")
 opening._unhandled_input(key(KEY_SPACE,false))
 check(opening.slide_index==2,"release does not advance")
 var repeat := key(KEY_ENTER)
 repeat.echo = true
 opening._unhandled_input(repeat)
 check(opening.slide_index==2,"key repeat ignored")
 opening.focused = false
 var before: float = opening.elapsed
 opening._process(5)
 check(opening.elapsed==before,"focus loss freezes slide clock")
 opening.focused = true
 opening._process(opening.SLIDE_SECONDS)
 check(opening.slide_index==3,"automatic progression resumes")
 opening._unhandled_input(key(KEY_ESCAPE))
 check(opening.completed,"Escape skips to end")
 opening.queue_free()
 await ticks(2)
 # Exercise real scene replacement and the same AudioStreamPlayer handoff.
 var error := change_scene_to_packed(packed)
 check(error==OK,"real opening starts")
 await ticks(2)
 opening = current_scene
 opening.set_process(false)
 var music = opening.music
 var music_id: int = music.get_instance_id()
 for step in range(6): opening._process(opening.SLIDE_SECONDS)
 await ticks(5)
 var game = current_scene
 check(game.scene_file_path=="res://main.tscn" and is_instance_valid(game.title_screen),"completion enters existing title")
 check(game.menu_music.get_instance_id()==music_id and music.playing,"same birds player continues into title without restart")
 check(not game.game_started and not game.player.controls_enabled and not game.music_player.playing,"title does not start gameplay/theme")
 if "--capture" in OS.get_cmdline_user_args(): await capture("title")
 game._show_records()
 check(music.playing,"title submenu keeps birds")
 game._show_title()
 check(game.menu_music.get_instance_id()==music_id and music.playing,"returning from submenu preserves music instance")
 game._begin_game()
 check(not music.playing and game.music_player.playing,"new game stops birds and starts gameplay theme")
 check(game.game_started and game.player.health==3 and game.carrot_count==0 and game.wood_count==0,"new game starts with original inventory/health")
 game._on_player_died()
 check(not music.playing and not game.music_player.playing and game.death_player.playing,"death audio remains isolated")
 game._show_title()
 check(music.playing and not game.music_player.playing,"title starts birds again")
 current_scene = null
 game.queue_free()
 await ticks(2)
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://qa_opening_settings.cfg"))
 print("OPENING_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures==0 else 1)

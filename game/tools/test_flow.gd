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
 var scene = load("res://main.tscn")
 var game = scene.instantiate()
 game.records_file = "user://qa_flow_records.cfg"
 game.controls_file = "user://qa_flow_controls.cfg"
 game.settings_file = "user://qa_flow_audio.cfg"
 root.add_child(game)
 await process_frame
 check(not game.game_started and game.player.health == 3, "title and initial health")
 game._begin_game()
 check(game.game_started and game.player.controls_enabled, "start")
 game._show_pause()
 check(not game.player.controls_enabled and game.pause_open, "pause")
 game._toggle_pause()
 check(game.player.controls_enabled and not game.pause_open, "resume")
 game.carrot_count = 12
 game._finish(false)
 game.record_input.text = "A1!"
 game._save_record()
 check(game.records.is_empty(), "invalid initials rejected")
 game.record_input.text = "ABC"
 game._save_record()
 game._save_record()
 check(game.records.size() == 1 and game.record_saved, "single record per attempt")
 game._load_records()
 game._load_records()
 check(game.records.size() == 1 and game.records[0]["carrots"] == 12, "reload does not duplicate")
 var cfg := ConfigFile.new()
 cfg.load(game.records_file)
 check(cfg.get_sections().size() == 1 and cfg.has_section("ranking"), "record file contains no progress")
 cfg.clear()
 cfg.set_value("ranking", "entries", "bad type")
 cfg.save(game.records_file)
 game._load_records()
 check(game.records.is_empty(), "invalid ranking container recovered")
 cfg.set_value("ranking", "entries", [{"name":"ABC","carrots":5}, {"name":"ABC","carrots":"bad"}, {"name":"123","carrots":7}])
 cfg.save(game.records_file)
 game._load_records()
 check(game.records.size() == 1, "malformed entries ignored")
 game.records.clear()
 for i in range(10): game.records.append({"name":"AAA", "carrots":10+i})
 game._sort_records()
 game.record_saved = false
 game.carrot_count = 10
 check(not game._qualifies(), "tie at tenth rejected")
 game.carrot_count = 11
 check(game._qualifies(), "score above tenth qualifies")
 var event := InputEventKey.new()
 event.physical_keycode = KEY_L
 game.rebind_action = "attack"
 game._apply_binding(event)
 game._load_controls()
 check(InputMap.action_get_events("attack")[0].physical_keycode == KEY_L, "binding survives reload")
 cfg.clear()
 cfg.set_value("keys", "attack", [])
 cfg.save(game.controls_file)
 game._load_controls()
 check(InputMap.action_get_events("attack")[0].physical_keycode == KEY_L, "invalid binding ignored")
 game.queue_free()
 await process_frame
 var fresh = scene.instantiate()
 fresh.records_file = "user://qa_flow_records.cfg"
 fresh.controls_file = "user://qa_flow_controls.cfg"
 fresh.settings_file = "user://qa_flow_audio.cfg"
 root.add_child(fresh)
 await process_frame
 check(fresh.player.health == 3 and fresh.wood_count == 0 and fresh.carrot_count == 0 and not fresh.is_finished, "fresh scene resets attempt")
 fresh._begin_game()
 fresh._finish(true)
 check(fresh.is_finished and not fresh.player.controls_enabled, "victory finishes attempt")
 fresh.queue_free()
 await process_frame
 for path in ["user://qa_flow_records.cfg", "user://qa_flow_controls.cfg", "user://qa_flow_audio.cfg"]:
  if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("FLOW_FAILURES=", failures)
 quit(1 if failures else 0)

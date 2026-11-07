extends SceneTree

var failures := 0

func check(condition: bool, message: String) -> void:
 if not condition:
  failures += 1
  push_error(message)
 else:
  print("PASS: ", message)

func _initialize() -> void:
 call_deferred("_run")

func _run() -> void:
 var game = load("res://main.tscn").instantiate()
 # Dedicated file: never overwrite the player's preferences or records.
 game.settings_file = "user://craft_bunny_audio_test.cfg"
 root.add_child(game)
 await process_frame
 for node_name in ["MusicPlayer", "PickupPlayer", "DeathPlayer", "HammerPlayer"]:
  var node = game.get_node(node_name)
  check(node.stream != null and node.stream.get_length() > 0, node_name + " loads")
 check(game.music_player.bus == "Music" and game.pickup_player.bus == "SFX", "bus routing")
 check(game.music_player.stream.loop, "theme loop enabled")
 game._change_volume(0.0, "sfx")
 check(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "zero volume mutes SFX")
 game._change_volume(0.35, "music")
 game.settings["music"] = 1.0
 game._load_settings()
 check(is_equal_approx(game.settings["music"], 0.35), "volume survives reload")
 var cfg := ConfigFile.new()
 cfg.set_value("audio", "master", "invalid")
 cfg.set_value("audio", "music", 12.0)
 cfg.set_value("audio", "sfx", -4.0)
 cfg.save(game.settings_file)
 game._load_settings()
 check(is_equal_approx(game.settings["master"], 0.8), "invalid value restores default")
 check(game.settings["music"] == 1.0 and game.settings["sfx"] == 0.0, "out of range values clamped")
 game._reset_volumes()
 check(game.settings == game.DEFAULT_VOLUMES, "restore defaults")
 check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "restore defaults unmutes")
 game._begin_game()
 check(game.music_player.playing, "theme starts with game")
 game._on_player_died()
 check(not game.music_player.playing, "theme stops on death")
 check(game.death_player.playing, "death effect starts after theme stops")
 # Only remove the dedicated test file created above.
 DirAccess.remove_absolute(ProjectSettings.globalize_path(game.settings_file))
 game.queue_free()
 game = null
 await process_frame
 await process_frame
 print("AUDIO_FAILURES=", failures)
 quit(1 if failures else 0)

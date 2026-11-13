extends AudioStreamPlayer
## Owned by the opening, then handed to main without restarting playback.
const TRACK = preload("res://music/forest-birds.mp3")
func _ready() -> void:
 name = "OpeningMusic"
 process_mode = Node.PROCESS_MODE_ALWAYS
 if AudioServer.get_bus_index("Music")<0:
  AudioServer.add_bus()
  AudioServer.set_bus_name(AudioServer.bus_count-1,"Music")
 bus = "Music"
 stream = TRACK.duplicate()
 stream.loop = true

func apply_saved_volumes(path: String) -> void:
 var cfg := ConfigFile.new()
 var loaded := cfg.load(path)==OK
 for key in ["master","music"]:
  var fallback := .8 if key=="master" else .65
  var raw: Variant = cfg.get_value("audio",key,fallback) if loaded else fallback
  var value := float(raw) if typeof(raw) in [TYPE_FLOAT,TYPE_INT] else fallback
  value = clampf(value,0,1) if is_finite(value) else fallback
  var index := AudioServer.get_bus_index("Master" if key=="master" else "Music")
  AudioServer.set_bus_mute(index,value<=0)
  AudioServer.set_bus_volume_db(index,linear_to_db(maxf(value,.0001)))

func start_menu() -> void:
 if not playing: play()

func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT: stream_paused = true
 elif what==NOTIFICATION_APPLICATION_FOCUS_IN: stream_paused = false

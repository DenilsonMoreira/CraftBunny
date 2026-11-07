extends SceneTree
var failures := 0
func check(value: bool,label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func find_button(node: Node,text: String) -> Button:
 for child in node.get_children():
  if child is Button and child.text==text: return child
  var found := find_button(child,text)
  if found != null: return found
 return null
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var path := "user://qa_local_reset_%d.cfg" % Time.get_ticks_usec()
 var seed := ConfigFile.new()
 seed.set_value("ranking","entries",[{"name":"ABC","carrots":50},{"name":"XYZ","carrots":20}])
 check(seed.save(path)==OK,"isolated ranking fixture saved")
 var game = load("res://main.tscn").instantiate()
 game.records_file = path
 root.add_child(game)
 await process_frame
 game.music_player.stop()
 game.game_started = true
 game.pause_open = true
 game.player.controls_enabled = false
 game.wood_count = 11
 game.carrot_count = 9
 game.record_saved = true
 game.global_ranking.run_id = "isolated-test-run"
 game.global_ranking.submitted = true
 game._show_records()
 check(game.records.size()==2,"saved local records loaded")
 var reset := find_button(game.overlay_panel,"ZERAR RANKING LOCAL")
 check(reset!=null and not reset.disabled,"clear action available in local ranking")
 reset.pressed.emit()
 await process_frame
 check(game.local_reset_pending and game.records.size()==2,"opening confirmation does not clear records")
 var cancel := find_button(game.overlay_panel,"CANCELAR")
 check(cancel!=null and cancel.has_focus(),"cancel receives initial keyboard focus")
 cancel.pressed.emit()
 check(not game.local_reset_pending and game.records.size()==2,"cancel preserves records")
 var disk := ConfigFile.new()
 disk.load(path)
 check(disk.get_value("ranking","entries").size()==2,"cancel leaves persisted records intact")
 game._confirm_local_reset()
 check(game.records.size()==2,"confirmation callback cannot clear outside dialog")
 game._show_local_reset_confirmation()
 find_button(game.overlay_panel,"SIM, APAGAR OS RECORDES").pressed.emit()
 check(game.records.is_empty(),"explicit confirmation clears memory")
 disk.load(path)
 check(disk.get_value("ranking","entries").is_empty(),"empty ranking persisted")
 check(game.wood_count==11 and game.carrot_count==9 and game.record_saved and game.pause_open and not game.player.controls_enabled,"attempt and pause preserved")
 check(game.global_ranking.run_id=="isolated-test-run" and game.global_ranking.submitted,"global session and submission untouched")
 game._load_records()
 check(game.records.is_empty(),"reload keeps ranking empty")
 check(find_button(game.overlay_panel,"ZERAR RANKING LOCAL").disabled,"clear action disabled for empty ranking")
 game.records.assign([{"name":"ABC","carrots":50}])
 game.records_file="user://qa_missing_reset_%d/records.cfg" % Time.get_ticks_usec()
 game._show_local_reset_confirmation()
 game._confirm_local_reset()
 check(game.records.size()==1 and not game.local_reset_pending,"write failure preserves memory and closes pending confirmation")
 game.queue_free()
 await process_frame
 DirAccess.remove_absolute(path)
 print("LOCAL_RESET_FAILURES=",failures)
 quit(1 if failures else 0)

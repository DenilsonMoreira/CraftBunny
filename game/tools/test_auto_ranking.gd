extends SceneTree

class FakeRanking extends "res://scripts/global_ranking.gd":
 var reply: Dictionary = {"_ok":true,"total":0,"entries":[]}
 var requests: Array = []
 var restart_on_read := false
 func _call(path: String, method: int, payload: Dictionary) -> Dictionary:
  requests.append({"path":path,"method":method,"payload":payload.duplicate(true)})
  await get_tree().process_frame
  if path.begins_with("/api/leaderboard"):
   if restart_on_read: begin_attempt()
   return reply
  if path == "/api/scores": return {"_ok":true,"accepted":true}
  return {"_ok":false}

var failures := 0
func check(value: bool,label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func client() -> FakeRanking:
 var result := FakeRanking.new()
 root.add_child(result)
 result.api_url = "https://example.test"
 result.run_id = "test-run"
 result.run_token = "test-token"
 result.ended = true
 result.duration_ms = 2000
 return result
func posts(value: FakeRanking) -> int:
 return value.requests.filter(func(request): return request["path"] == "/api/scores").size()
func _run() -> void:
 var value := client()
 await value.submit_local_record("ABC",5)
 check(value.submitted and posts(value)==1,"empty global ranking accepts a local record automatically")
 await value.submit_local_record("ABC",5)
 await value.submit_score("ABC",5)
 check(posts(value)==1,"automatic and manual attempts cannot duplicate a successful submission")
 value.free()
 for count in [99,100]:
  for score in [19,20,21]:
   value = client()
   var rows: Array = []
   for index in range(count): rows.append({"carrots":20})
   value.reply = {"_ok":true,"total":count,"entries":rows}
   await value.submit_local_record("ABC",score)
   var expected: bool = count < 100 or score > 20
   check((posts(value)==1)==expected,"TOP %d with score %d respects vacancies and tie cutoff" % [count,score])
   value.free()
 for reply in [{"_ok":false},{"_ok":true,"total":100,"entries":[]},{"_ok":true,"total":1,"entries":[{"carrots":"bad"}]}]:
  value = client()
  value.reply = reply
  await value.submit_local_record("ABC",25)
  check(posts(value)==0 and not value.auto_checking,"unavailable or malformed leaderboard never authorizes automatic upload")
  value.free()
 value = client()
 value.api_url = ""
 await value.submit_local_record("ABC",25)
 check(value.requests.is_empty(),"offline record causes no network request")
 value.free()
 value = client()
 value.restart_on_read = true
 await value.submit_local_record("ABC",25)
 await process_frame
 check(posts(value)==0,"restart during eligibility check cancels the previous result")
 value.free()
 value = client()
 value.submit_local_record("ABC",25)
 value.submit_local_record("ABC",25)
 value.submit_score("ABC",25)
 for frame in range(4): await process_frame
 check(posts(value)==1,"rapid save and manual clicks produce one upload")
 value.free()

 var path := "user://qa_auto_%d.cfg" % Time.get_ticks_usec()
 var game = load("res://main.tscn").instantiate()
 game.records_file = path
 root.add_child(game)
 await process_frame
 game.global_ranking.free()
 value = client()
 game.global_ranking = value
 game.is_finished = true
 game.carrot_count = 25
 game._show_results("Teste","Teste")
 game.record_input.text = "A1!"
 game._save_record()
 check(not game.record_saved and value.requests.is_empty(),"invalid initials never save or upload")
 game.record_input.text = "ABC"
 game.records_file = "user://missing_auto_%d/records.cfg" % Time.get_ticks_usec()
 game._save_record()
 check(not game.record_saved and value.requests.is_empty(),"failed local write never triggers upload")
 game.records_file = path
 game._save_record()
 for frame in range(4): await process_frame
 var disk := ConfigFile.new()
 check(disk.load(path)==OK and game.record_saved and posts(value)==1,"successful local save triggers automatic upload with its initials")
 check(value.pending_payload.get("initials")=="ABC" and value.pending_payload.get("carrots")==25,"automatic payload uses the saved local record")
 game._save_record()
 check(posts(value)==1,"repeated save is ignored")
 game.record_saved = false
 game.record_input.editable = true
 game.records.clear()
 for index in range(10): game.records.append({"name":"AAA","carrots":30})
 value.requests.clear()
 value.submitted = false
 game._save_record()
 check(not game.record_saved and value.requests.is_empty(),"score outside the local TOP 10 never triggers automatic submission")
 game._show_records()
 check(game.overlay_panel.find_children("*","Button",true,false).any(func(button): return button.text=="RANKING GLOBAL"),"local records retain one global website button")
 game.free()
 value.free()
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("AUTO_RANKING_FAILURES=",failures)
 quit(1 if failures else 0)

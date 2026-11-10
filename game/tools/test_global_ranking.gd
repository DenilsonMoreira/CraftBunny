extends SceneTree
var failures := 0
func check(value: bool,label: String) -> void:
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 var client = load("res://scripts/global_ranking.gd").new()
 root.add_child(client)
 client.api_url = ""
 check(not client.configured(),"global disabled without URL")
 client.begin_attempt()
 client.finish_attempt(false)
 client.submit_score("ABC",10)
 check(client.run_id.is_empty() and not client.submitted,"offline attempt cannot publish")
 check(client.status_text.contains("local"),"offline status preserves local ranking")
 var game = load("res://main.tscn").instantiate()
 game.records_file = "user://qa_global_records.cfg"
 root.add_child(game)
 await process_frame
 game.global_ranking.api_url = ""
 var carrots := 0
 for child in game.get_children():
  if child.get_script() == game.PICKUP_SCRIPT and child.kind=="carrot": carrots += 1
  if child.get_script() == game.ENEMY_SCRIPT: carrots += int(child.DATA[child.kind]["reward"])
 check(carrots==client.MAX_CARROTS,"global score ceiling equals all carrots and drops in current phase")
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 game.carrot_count = 10
 game._finish(false)
 check(game.is_finished and game.global_ranking.ended,"finished run closes online duration without blocking game")
 game._show_records()
 var source := FileAccess.get_file_as_string("res://scripts/main.gd")
 check(source.contains('OS.shell_open("https://craftbunny-web.vercel.app/")'),"global button opens the website instead of an embedded ranking")
 if not OS.get_environment("CRAFT_BUNNY_API_URL").is_empty():
  client.api_url = OS.get_environment("CRAFT_BUNNY_API_URL")
  client.begin_attempt()
  while client.starting: await process_frame
  check(not client.run_id.is_empty() and not client.run_token.is_empty(),"HTTP start obtains server run and token")
  await create_timer(1.1).timeout
  client.finish_attempt(false)
  await client.submit_local_record("NET",12)
  check(client.submitted,"HTTP automatically publishes qualifying local record")
  var rows: Array = []
  client.leaderboard_loaded.connect(func(entries): rows.assign(entries))
  await client.fetch_leaderboard()
  check(rows.any(func(row): return row["initials"]=="NET" and int(row["carrots"])==12),"HTTP ranking returns published score")
  check(not client.pending_payload.is_empty(),"retry payload retained unchanged in memory")
 client.queue_free()
 game.queue_free()
 await process_frame
 print("GLOBAL_RANKING_FAILURES=",failures)
 quit(1 if failures else 0)

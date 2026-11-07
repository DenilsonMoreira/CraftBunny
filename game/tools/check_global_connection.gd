extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
 if not "--online" in OS.get_cmdline_user_args():
  push_error("Use -- --online to explicitly check production. No scores are submitted.")
  quit(1)
  return
 var client = load("res://scripts/global_ranking.gd").new()
 root.add_child(client)
 var loaded := [false]
 client.leaderboard_loaded.connect(func(_rows): loaded[0] = true)
 await client.fetch_leaderboard()
 print("PRODUCTION_LEADERBOARD=",loaded[0])
 client.begin_attempt()
 while client.starting: await process_frame
 var started: bool = not client.run_id.is_empty() and not client.run_token.is_empty()
 print("PRODUCTION_SESSION=",started)
 print("PUBLIC_SCORES_SUBMITTED=0")
 if not started: print("CONNECTION_STATUS=",client.status_text)
 client.queue_free()
 await process_frame
 quit(0 if loaded[0] and started else 1)

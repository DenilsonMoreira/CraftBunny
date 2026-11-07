extends Node

signal status_changed(message: String)
signal leaderboard_loaded(entries: Array)
const GAME_VERSION := "0.3.4"
const MAX_CARROTS := 139
var api_url := ""
var run_id := ""
var run_token := ""
var generation := 0
var starting := false
var submitting := false
var submitted := false
var ended := false
var won := false
var started_ms := 0
var duration_ms := 0
var pending_payload: Dictionary = {}
var status_text := ""

func _ready() -> void:
 api_url = str(ProjectSettings.get_setting("craft_bunny/ranking/api_url","")).strip_edges().trim_suffix("/")
 var override := OS.get_environment("CRAFT_BUNNY_API_URL").strip_edges().trim_suffix("/")
 if not override.is_empty(): api_url = override
 if not _valid_url(api_url): api_url = ""

func _valid_url(value: String) -> bool:
 return (value.begins_with("https://") and value.length() > 10) or (OS.is_debug_build() and (value.begins_with("http://127.0.0.1:") or value.begins_with("http://localhost:")))

func configured() -> bool: return not api_url.is_empty()

func _status(message: String) -> void:
 status_text = message
 status_changed.emit(message)

func begin_attempt() -> void:
 generation += 1
 var current := generation
 run_id = ""
 run_token = ""
 pending_payload.clear()
 submitted = false
 submitting = false
 starting = false
 ended = false
 duration_ms = 0
 started_ms = Time.get_ticks_msec()
 if not configured():
  _status("Ranking global ainda indisponível. O ranking local continua funcionando.")
  return
 starting = true
 _status("Iniciando tentativa online…")
 var response := await _call("/api/runs",HTTPClient.METHOD_POST,{"game_version":GAME_VERSION})
 if current != generation: return
 starting = false
 if response.get("_ok",false) and typeof(response.get("run_id")) == TYPE_STRING and typeof(response.get("token")) == TYPE_STRING:
  run_id = response["run_id"]
  run_token = response["token"]
  _status("Tentativa online pronta. Você escolhe se deseja compartilhar ao terminar.")
 else:
  _status("Esta tentativa ficará apenas no ranking local: não foi possível iniciar o envio online.")

func finish_attempt(victory: bool) -> void:
 if ended: return
 ended = true
 won = victory
 duration_ms = int(Time.get_ticks_msec()-started_ms)

func submit_score(initials: String, carrots: int) -> void:
 if submitting or submitted: return
 if not configured() or run_id.is_empty():
  _status("Tentativa online não disponível. Seu recorde local permanece no aparelho.")
  return
 if not ended or initials.length()!=3 or carrots<1 or carrots>MAX_CARROTS:
  _status("Use três letras A-Z para compartilhar uma tentativa encerrada.")
  return
 for character in initials:
  if character.unicode_at(0)<65 or character.unicode_at(0)>90:
   _status("Use somente três letras A-Z.")
   return
 if pending_payload.is_empty():
  pending_payload = {"run_id":run_id,"token":run_token,"game_version":GAME_VERSION,"initials":initials,"carrots":carrots,"won":won,"duration_ms":duration_ms}
 # Keep exactly the same payload for safe retries after a lost response.
 var current := generation
 submitting = true
 _status("Enviando recorde global…")
 var response := await _call("/api/scores",HTTPClient.METHOD_POST,pending_payload)
 if current != generation: return
 submitting = false
 if response.get("_ok",false) and response.get("accepted",false):
  submitted = true
  _status("Recorde publicado! Consulte os recordes globais.")
 else:
  _status(str(response.get("message","Não foi possível enviar. Tente novamente; o ranking local permanece salvo.")))

func fetch_leaderboard() -> void:
 if not configured():
  _status("Ranking global ainda indisponível. O ranking local continua funcionando.")
  return
 _status("Buscando recordes globais…")
 var response := await _call("/api/leaderboard",HTTPClient.METHOD_GET,{})
 if not response.get("_ok",false) or not response.get("entries") is Array:
  _status("Não foi possível consultar o ranking global. Tente novamente.")
  return
 var valid: Array = []
 for row in response["entries"].slice(0,100):
  if row is Dictionary and typeof(row.get("initials"))==TYPE_STRING and row["initials"].length()==3 and typeof(row.get("carrots")) in [TYPE_INT,TYPE_FLOAT]:
   valid.append(row)
 _status("Ranking global atualizado." if not valid.is_empty() else "Nenhum recorde global publicado ainda.")
 leaderboard_loaded.emit(valid)

func _call(path: String, method: int, payload: Dictionary) -> Dictionary:
 var request := HTTPRequest.new()
 request.timeout = 8
 request.body_size_limit = 262144
 add_child(request)
 var headers := PackedStringArray(["Content-Type: application/json"])
 var error := request.request(api_url+path,headers,method,JSON.stringify(payload) if method!=HTTPClient.METHOD_GET else "")
 if error != OK:
  request.queue_free()
  return {"message":"Sem conexão com o ranking global."}
 var result: Array = await request.request_completed
 request.queue_free()
 if result[0] != HTTPRequest.RESULT_SUCCESS: return {"message":"Sem conexão com o ranking global."}
 var parsed: Variant = JSON.parse_string((result[3] as PackedByteArray).get_string_from_utf8())
 if not parsed is Dictionary: return {"message":"Resposta inválida do ranking global."}
 parsed["_ok"] = int(result[1]) >= 200 and int(result[1]) < 300
 return parsed

extends Node2D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const ENEMY_SCRIPT = preload("res://scripts/enemy.gd")
const BOX_SCRIPT = preload("res://scripts/box.gd")
const PICKUP_SCRIPT = preload("res://scripts/pickup.gd")
const RECORD_FILE := "user://records.cfg"
const CONFIG_FILE := "user://settings.cfg"
const DEFAULT_VOLUMES := {"master": 0.8, "music": 0.65, "sfx": 0.8}
const RECORD_LIMIT := 10
const LEVEL_WIDTH := preload("res://scripts/wide_level.gd").WIDTH
const FINISH_X := 23600.0
const FLOOR_Y := 435.0
const BOX_SIZE := 42.0
const BUILD_OFFSET := 40.0
const BUILD_REACH := 56.0

var player: CharacterBody2D
var wood_count := 0
var carrot_count := 0
var defeated_count := 0
var records: Array[Dictionary] = []
var records_file := RECORD_FILE
var record_saved := false
var settings := {"master": 0.8, "music": 0.65, "sfx": 0.8}
var settings_file := CONFIG_FILE
var record_input: LineEdit
var is_finished := false
var game_started := false
var pause_open := false
var hud: Control
var health_label: Label
var info: Label
var menu_panel: PanelContainer
var overlay_panel: PanelContainer
var ui_layer: CanvasLayer
var ground_segments: Array[Vector2] = []
var rocks: Array[Array] = []
var ledges: Array[Array] = []
var status_timer := 0.0
var rebind_action := ""
var controls_file := "user://controls.cfg"
var music_player: AudioStreamPlayer
var pickup_player: AudioStreamPlayer
var death_player: AudioStreamPlayer
var hammer_player: AudioStreamPlayer
var scream_player: AudioStreamPlayer
var pit_audio_started := false
var status_hud: Control
var impact_player: AudioStreamPlayer
var title_screen: Control
var mobile_controls: Control
var global_ranking: Node
var global_status: Label
var local_reset_pending := false
var level: Node2D

func _ready() -> void:
	if OS.has_feature("android"): get_tree().quit_on_go_back = false
	_setup_inputs()
	_load_controls()
	_load_records()
	_prepare_audio()
	_load_settings()
	_generate_level()
	_create_parallax()
	for span in ground_segments:
		if level==null: _add_solid(Vector2((span.x+span.y)/2.0,FLOOR_Y+52),Vector2(span.y-span.x,104))
	for data in rocks:
		if level==null: _add_solid(Vector2(data[0],data[1]),Vector2(data[2],data[3]))
	for data in ledges:
		_add_solid(Vector2(data[0],data[1]),Vector2(data[2],20))
	_create_tile_visuals()
	player = PLAYER_SCRIPT.new()
	player.add_to_group("player")
	player.position = Vector2(100,FLOOR_Y-21)
	add_child(player)
	if level != null:
		player.global_position = level.get_node("InicioJogador").global_position
		player.pit_warning_y = 1170.0
		player.fall_death_y = 1260.0
		for child in player.get_children():
			if child is Camera2D:
				child.limit_right = int(LEVEL_WIDTH)
				child.limit_top = -1000
				child.limit_bottom = 1420
		level.get_node("InicioJogador").hide()
	player.health_changed.connect(_on_health_changed)
	player.hammer_used.connect(_on_hammer_used)
	player.box_requested.connect(_on_box_requested)
	player.died.connect(_on_player_died)
	player.pit_falling.connect(_on_pit_falling)
	player.stomped.connect(_on_player_stomped)
	_populate_level()
	_create_hud()
	global_ranking = preload("res://scripts/global_ranking.gd").new()
	add_child(global_ranking)
	global_ranking.status_changed.connect(_on_global_status)
	_show_title()
	queue_redraw()

func _prepare_audio() -> void:
	for name in ["Music","SFX"]:
		if AudioServer.get_bus_index(name)<0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,name)
	music_player = _create_audio_player("MusicPlayer",load("res://music/music-theme.mp3") as AudioStream,"Music")
	pickup_player = _create_audio_player("PickupPlayer",load("res://music/collect-itens.mp3") as AudioStream,"SFX")
	death_player = _create_audio_player("DeathPlayer",load("res://music/game-over.mp3") as AudioStream,"SFX")
	hammer_player = _create_audio_player("HammerPlayer",load("res://music/hammer-atack.mp3") as AudioStream,"SFX")
	scream_player = _create_audio_player("ScreamPlayer",load("res://music/funny-scream.mp3") as AudioStream,"SFX")
	impact_player = _create_audio_player("ImpactPlayer",load("res://music/impact-thud.mp3") as AudioStream,"SFX")
	if music_player.stream is AudioStreamMP3:
		(music_player.stream as AudioStreamMP3).loop = true

func _create_audio_player(player_name: String, stream: AudioStream, bus_name: String) -> AudioStreamPlayer:
	var player_node := AudioStreamPlayer.new()
	player_node.name = player_name
	player_node.stream = stream
	player_node.bus = bus_name
	add_child(player_node)
	return player_node

func _setup_inputs() -> void:
	var bindings := {"move_left": [KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],"jump":[KEY_SPACE,KEY_W,KEY_UP],"dash":[KEY_I],"attack":[KEY_J],"craft":[KEY_K],"pause_game":[KEY_ESCAPE,KEY_P]}
	for action in bindings.keys():
		if not InputMap.has_action(action): InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action,event): InputMap.action_add_event(action,event)

func _generate_level() -> void:
	level = load("res://scenes/level_wide/fase_compacta.tscn").instantiate()
	add_child(level)
	for rect in level.solid_rects():
		rocks.append([rect.get_center().x,rect.get_center().y,rect.size.x,rect.size.y])
		if is_equal_approx(rect.position.y,FLOOR_Y): ground_segments.append(Vector2(rect.position.x,rect.end.x))
	return

func _legacy_generate_level() -> void:
	# Five progressive areas: meadow, forest, rocks, treetops, final crossing.
	# First segment is forgiving. Later segments have gaps and more enemies.
	var start := 0.0
	var section := 0
	while start < LEVEL_WIDTH:
		var width := 950.0 if section == 0 else 700.0 + float(section%3)*90.0
		var right := minf(start+width,LEVEL_WIDTH)
		ground_segments.append(Vector2(start,right))
		if section > 0:
				# Obstacles stay within the validated jump + crate envelope.
				# Low enough to cross in both directions without requiring a crate.
				rocks.append([start+245.0,417.0,54.0,36.0])
				ledges.append([start+420.0,360.0,120.0])
		if section > 3:
				ledges.append([start+560.0,325.0,95.0])
		start = right + (78.0 if section < 3 else 95.0)
		section += 1

func _ground_under(x: float) -> bool:
	for span in ground_segments:
		if x>span.x+24 and x<span.y-24: return true
	return false

func _populate_level() -> void:
	if level != null:
		for marker in level.get_node("Itens").get_children():
			_spawn_pickup(str(marker.get_meta("kind")),marker.global_position)
		for marker in level.get_node("Inimigos").get_children():
			_spawn_enemy(str(marker.get_meta("kind")),marker.global_position)
		level.get_node("Itens").hide()
		level.get_node("Inimigos").hide()
		return
	for x in range(180,11800,160):
		if _ground_under(float(x)):
			_spawn_pickup("carrot",Vector2(x,398))
	for x in range(260,11700,270):
		if _ground_under(float(x)):
			_spawn_pickup("wood",Vector2(x,392))
	for x in [1600,3900,6900,9900]:
		if _ground_under(x): _spawn_pickup("heart",Vector2(x,390))
	for x in range(580,11600,335):
		if not _ground_under(float(x)): continue
		var progress := float(x)/LEVEL_WIDTH
		# Increase encounter density later in the level.
		if progress < 0.15 and (int(x/335)%2 == 0): continue
		var kind := "cobra" if int(x/335)%3 == 0 else ("guaxinim" if int(x/335)%3 == 1 else "ave")
		if progress < 0.3 and kind == "ave": kind = "cobra"
		_spawn_enemy(kind,Vector2(x,245 if kind=="ave" else FLOOR_Y-13))
		if progress > 0.65 and _ground_under(float(x+105)) and int(x/335)%2 == 0:
			_spawn_enemy("cobra",Vector2(x+105,FLOOR_Y-13))

func _create_parallax() -> void:
	if level != null: return
	var sky := Parallax2D.new()
	sky.name = "CloudParallax"
	sky.scroll_scale = Vector2(0.15,0.6)
	var clouds := Node2D.new()
	clouds.set_script(preload("res://scripts/sky_clouds.gd"))
	sky.add_child(clouds)
	add_child(sky)
	var layer := Parallax2D.new()
	layer.scroll_scale = Vector2(0.38,1.0)
	var art := Node2D.new()
	art.set_script(preload("res://scripts/parallax.gd"))
	layer.add_child(art)
	add_child(layer)

func _add_solid(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	add_child(body)

func _create_tile_visuals() -> void:
	if level != null: return
	var forest := Node2D.new()
	forest.set_script(preload("res://scripts/forest_visuals.gd"))
	forest.name = "ForestVisuals"
	add_child(forest)
	forest.build(ground_segments, rocks, ledges, FLOOR_Y)

func _spawn_pickup(kind: String, pos: Vector2, count: int = 1) -> void:
	for i in range(count):
		var pickup := PICKUP_SCRIPT.new()
		pickup.setup(kind)
		pickup.position = pos + (Vector2.ZERO if count==1 else Vector2((i%3-1)*22, -int(i/3)*26))
		pickup.collected.connect(_on_pickup)
		add_child(pickup)

func _on_pickup(pickup: Area2D) -> void:
	if is_finished or not game_started or not is_instance_valid(pickup): return
	match pickup.kind:
		"carrot": carrot_count += 1
		"wood":
			wood_count += 1
		"heart":
			if player.health >= 3: return
			player.health += 1
			player.health_changed.emit(player.health)
	pickup._claimed = true
	pickup.queue_free()
	if is_instance_valid(pickup_player): pickup_player.play()
	_update_hud()

func _spawn_enemy(kind: String,pos: Vector2) -> void:
	var enemy: CharacterBody2D = ENEMY_SCRIPT.new()
	enemy.setup(kind,pos,player)
	enemy.active = false
	add_child(enemy)
	enemy.add_to_group("enemy")
	enemy.attack_landed.connect(_on_enemy_attack)
	enemy.defeated.connect(_on_enemy_defeated)

func _on_enemy_attack(damage: int, from_x: float) -> void:
	if game_started and not is_finished:
		player.take_damage(damage,from_x)

func _on_player_stomped() -> void:
	if not is_finished: impact_player.play()

func _on_enemy_defeated(enemy: CharacterBody2D,reward: int) -> void:
	defeated_count += 1
	_spawn_pickup("carrot",enemy.global_position + Vector2(0,-30),reward)
	show_message("Inimigo derrotado! Recolha as cenouras.",1.2)

func _on_box_requested() -> void:
	if is_finished or not game_started: return
	if wood_count < 3:
		show_message("Você tem %d tábua(s). Precisa de 3; cenouras não constroem caixas." % wood_count,2.7)
		return
	var candidate: Variant = _find_box_position()
	if candidate == null:
		show_message("Sem espaço: aproxime-se de um apoio; afaste-se ou salte para empilhar.",2.5)
		return
	var pos: Vector2 = candidate
	var crate := BOX_SCRIPT.new()
	crate.position = pos
	add_child(crate)
	crate.add_to_group("crates")
	wood_count -= 3
	_update_hud()
	show_message("Caixa construída! (2 HP)",1.2)

func _find_box_position() -> Variant:
	var aim_x: float = player.global_position.x + float(player.facing)*BUILD_OFFSET
	var feet: float = player.global_position.y+21
	var supports: Array[Dictionary] = []
	for span in ground_segments:
		supports.append({"rect": Rect2(span.x,FLOOR_Y,span.y-span.x,104), "snap": false})
	for rock in rocks:
		supports.append({"rect": Rect2(rock[0]-rock[2]/2.0,rock[1]-rock[3]/2.0,rock[2],rock[3]), "snap": false})
	for ledge in ledges:
		supports.append({"rect": Rect2(ledge[0]-ledge[2]/2.0,ledge[1]-10,ledge[2],20), "snap": false})
	for crate in get_tree().get_nodes_in_group("crates"):
		if not is_instance_valid(crate) or crate.is_queued_for_deletion(): continue
		supports.append({"rect": Rect2(crate.global_position-Vector2.ONE*BOX_SIZE/2,Vector2.ONE*BOX_SIZE), "snap": true})
	supports.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a["rect"].position.y < b["rect"].position.y)
	for support in supports:
		var rect: Rect2 = support["rect"]
		if absf(rect.position.y-feet) > BUILD_REACH: continue
		if aim_x < rect.position.x or aim_x > rect.end.x: continue
		var x: float = rect.get_center().x if support["snap"] else aim_x
		if x-BOX_SIZE/2 < rect.position.x-0.01 or x+BOX_SIZE/2 > rect.end.x+0.01: continue
		var pos := Vector2(x,rect.position.y-BOX_SIZE/2)
		var area := Rect2(pos-Vector2.ONE*BOX_SIZE/2,Vector2.ONE*BOX_SIZE)
		var player_area := Rect2(player.global_position-Vector2(13,21),Vector2(26,42))
		if area.intersects(player_area): continue
		var blocked := false
		# Explicit geometry also protects against two build requests in the same tick.
		for solid in supports:
			if area.grow(-0.05).intersects(solid["rect"]):
				blocked = true
				break
		if blocked: continue
		var shape := RectangleShape2D.new()
		shape.size = Vector2.ONE*(BOX_SIZE-0.1)
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0,pos)
		query.collision_mask = 1
		if not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty(): continue
		return pos
	return null

func _on_hammer_used(hitbox: Rect2) -> void:
	if not game_started or is_finished: return
	if is_instance_valid(hammer_player): hammer_player.play()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy) or not enemy.alive: continue
		var bounds: Rect2 = enemy.get_hurtbox()
		if hitbox.intersects(bounds):
			enemy.take_hit(1,player.global_position.x)
	for crate in get_tree().get_nodes_in_group("crates"):
		if not is_instance_valid(crate): continue
		var bounds := Rect2(crate.global_position-Vector2(21,21),Vector2(42,42))
		if hitbox.intersects(bounds): crate.take_hammer_hit()

func _on_health_changed(_hp: int) -> void: _update_hud()

func _physics_process(delta: float) -> void:
	if not game_started or is_finished: return
	if status_timer>0:
		status_timer -= delta
		if status_timer<=0 and is_instance_valid(info): info.text = ""
	if player.health>0 and ((level != null and level.goal_rect().has_point(player.global_position)) or (level==null and player.global_position.x>=FINISH_X)):
		_finish(true)

func _on_player_died() -> void:
	if is_finished: return
	if is_instance_valid(music_player): music_player.stop()
	is_finished = true
	global_ranking.finish_attempt(false)
	player.controls_enabled = false
	_set_enemies_active(false)
	if player.death_cause == "pit":
		if not pit_audio_started: _start_pit_audio()
		if scream_player.playing: await scream_player.finished
	if is_instance_valid(death_player): death_player.play()
	var remaining: float = maxf(0.0, player.DEATH_VISUAL_DURATION-player.death_elapsed)
	if remaining > 0: await get_tree().create_timer(remaining).timeout
	_show_results("FIM DE JOGO", "A tentativa terminou.")

func _start_pit_audio() -> void:
	if pit_audio_started: return
	pit_audio_started = true
	music_player.stop()
	scream_player.play()

func _on_pit_falling() -> void:
	if game_started and not is_finished: _start_pit_audio()

func _finish(won: bool) -> void:
	if is_finished: return
	is_finished = true
	global_ranking.finish_attempt(won)
	player.controls_enabled = false
	_set_enemies_active(false)
	_show_results("CHEGADA À CASINHA!" if won else "FIM DE JOGO", "Percurso concluído!" if won else "A tentativa terminou.")

func _set_enemies_active(enabled: bool) -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy): enemy.active = enabled

func _unhandled_input(event: InputEvent) -> void:
	if rebind_action != "" and event is InputEventKey and event.pressed and not event.echo:
		_apply_binding(event)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause_game") and game_started and not is_finished:
		_toggle_pause()
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R and game_started:
		_restart()

func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func show_message(message: String, seconds: float) -> void:
	status_timer = seconds
	if is_instance_valid(info): info.text = message

func _notification(what: int) -> void:
	if not is_instance_valid(mobile_controls): return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		mobile_controls.release_all()
		if game_started and not is_finished and not pause_open: _show_pause()
		if is_instance_valid(music_player): music_player.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if is_instance_valid(music_player): music_player.stream_paused = false
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if game_started and not is_finished: _toggle_pause()

func _create_hud() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	hud = Control.new()
	hud.theme = preload("res://scripts/ui_theme.gd").create()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud)
	status_hud = Control.new()
	status_hud.set_script(preload("res://scripts/pixel_hud.gd"))
	status_hud.position = Vector2(12,6)
	status_hud.size = Vector2(936,76)
	hud.add_child(status_hud)
	info = Label.new()
	info.position = Vector2(20,80)
	info.add_theme_font_size_override("font_size",17)
	info.add_theme_color_override("font_color",Color("382c26"))
	info.add_theme_color_override("font_outline_color",Color("fff0d4"))
	info.add_theme_constant_override("outline_size",4)
	hud.add_child(info)
	var instructions := Label.new()
	instructions.text = "A/D mover · Espaço pulo / 2 toques planar · I dash · J martelo · K caixa · ESC opções"
	instructions.position = Vector2(20,504)
	instructions.add_theme_color_override("font_color",Color("ffffff"))
	instructions.add_theme_color_override("font_outline_color",Color("30251f"))
	instructions.add_theme_constant_override("outline_size",4)
	instructions.add_theme_font_size_override("font_size",13)
	hud.add_child(instructions)
	if OS.has_feature("android") or DisplayServer.is_touchscreen_available() or "--touch" in OS.get_cmdline_user_args():
		instructions.visible = false
		mobile_controls = Control.new()
		mobile_controls.set_script(preload("res://scripts/touch_controls.gd"))
		mobile_controls.game = self
		hud.add_child(mobile_controls)
		mobile_controls.pause_requested.connect(_toggle_pause)
	_update_hud()

func _update_hud() -> void:
	if not is_instance_valid(status_hud) or not is_instance_valid(player): return
	status_hud.update_values(player.health, carrot_count, wood_count)

func _clear_overlay() -> void:
	local_reset_pending = false
	if is_instance_valid(title_screen):
		title_screen.queue_free()
		title_screen = null
	if is_instance_valid(overlay_panel):
		overlay_panel.queue_free()
		overlay_panel = null

func _create_overlay(title: String) -> VBoxContainer:
	_clear_overlay()
	overlay_panel = PanelContainer.new()
	overlay_panel.position = Vector2(230,64)
	overlay_panel.custom_minimum_size = Vector2(500,470)
	overlay_panel.size = Vector2(500,470)
	overlay_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud.add_child(overlay_panel)
	var margin := MarginContainer.new()
	for side in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,4)
	overlay_panel.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",7)
	scroll.add_child(content)
	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size",24)
	heading.add_theme_color_override("font_color",Color("ffb34f"))
	content.add_child(heading)
	return content

func _button(parent: Node, label: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(260,48)
	parent.add_child(btn)
	btn.pressed.connect(callback)
	return btn

func _show_title() -> void:
	game_started = false
	player.controls_enabled = false
	_clear_overlay()
	title_screen = Control.new()
	title_screen.name = "TitleScreen"
	title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(title_screen)
	var artwork := TextureRect.new()
	artwork.name = "TitleArt"
	artwork.texture = preload("res://assets/production/v2/title_pixel.png")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_screen.add_child(artwork)
	var start := _title_button("NovoJogo","NOVO JOGO",0,_begin_game)
	_title_button("Recordes","RECORDES",1,_show_records)
	_title_button("Opcoes","OPÇÕES",2,_show_settings)
	_title_button("Controles","CONTROLES",3,_show_controls)
	var build_label := Label.new()
	build_label.name = "BuildVersion"
	build_label.text = "v%s | LOCAL + GLOBAL" % str(ProjectSettings.get_setting("application/config/version",global_ranking.GAME_VERSION))
	build_label.position = Vector2(500,500)
	build_label.size = Vector2(304,24)
	build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_label.add_theme_font_size_override("font_size",12)
	title_screen.add_child(build_label)
	start.call_deferred("grab_focus")

func _title_button(button_name: String, label: String, index: int, callback: Callable) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = label
	button.tooltip_text = label
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.position = Vector2(500,228+index*64)
	button.size = Vector2(304,58)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	title_screen.add_child(button)
	button.pressed.connect(callback)
	return button

func _begin_game() -> void:
	if game_started: return
	game_started = true
	global_ranking.begin_attempt()
	player.controls_enabled = true
	_set_enemies_active(true)
	if is_instance_valid(music_player) and not music_player.playing: music_player.play()
	_clear_overlay()
	show_message("Alcance a casa do coelho e colete muitas cenouras!",4)

func _show_records() -> void:
	var content := _create_overlay("LOCAL — TOP 10")
	var ranking := Label.new()
	ranking.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ranking.text = _ranking_text()
	content.add_child(ranking)
	var reset_button := _button(content,"ZERAR RANKING LOCAL",_show_local_reset_confirmation)
	reset_button.disabled = records.is_empty()
	_button(content,"RANKING GLOBAL",_show_global_records)
	_button(content,"VOLTAR",_show_title if not game_started else _show_pause)

func _show_local_reset_confirmation() -> void:
	if records.is_empty(): return
	var content := _create_overlay("ZERAR RANKING LOCAL?")
	local_reset_pending = true
	var explanation := Label.new()
	explanation.text = "Apagar todos os recordes salvos neste aparelho?\n\nEsta ação não pode ser desfeita. O ranking global e a tentativa atual não serão alterados."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(explanation)
	var cancel := _button(content,"CANCELAR",_show_records)
	_button(content,"SIM, APAGAR OS RECORDES",_confirm_local_reset)
	cancel.call_deferred("grab_focus")

func _confirm_local_reset() -> void:
	if not local_reset_pending: return
	local_reset_pending = false
	var cfg := ConfigFile.new()
	cfg.set_value("ranking","entries",[])
	if cfg.save(records_file) != OK:
		var content := _create_overlay("NÃO FOI POSSÍVEL APAGAR")
		var message := Label.new()
		message.text = "Falha ao salvar no aparelho. Os recordes continuam na memória. Tente novamente."
		message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(message)
		_button(content,"VOLTAR",_show_records)
		return
	records.clear()
	_show_records()

func _show_global_records() -> void:
	OS.shell_open("https://craftbunny-web.vercel.app/")

func _on_global_status(message: String) -> void:
	if is_instance_valid(global_status): global_status.text = message

func _ranking_text() -> String:
	var lines := ""
	for i in range(RECORD_LIMIT):
		if i<records.size():
			lines += "%02d   %s   %d 🥕\n" % [i+1,records[i]["name"],records[i]["carrots"]]
		else:
			lines += "%02d   ---   --\n" % [i+1]
	return lines

func _toggle_pause() -> void:
	if pause_open:
		pause_open = false
		player.controls_enabled = true
		_set_enemies_active(true)
		_clear_overlay()
	else:
		_show_pause()

func _show_pause() -> void:
	pause_open = true
	player.controls_enabled = false
	_set_enemies_active(false)
	var content := _create_overlay("PAUSA")
	_button(content,"CONTINUAR",_toggle_pause)
	_button(content,"OPÇÕES",_show_settings)
	_button(content,"RECORDES",_show_records)
	_button(content,"REINICIAR",_restart)

func _show_settings() -> void:
	var content := _create_overlay("OPÇÕES")
	for key in ["master","music","sfx"]:
		var label := Label.new()
		label.text = {"master":"Volume geral","music":"Música de fundo","sfx":"Efeitos sonoros"}[key]
		content.add_child(label)
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = settings[key]
		content.add_child(slider)
		slider.value_changed.connect(_change_volume.bind(key))
	_button(content,"CONFIGURAR CONTROLES",_show_controls)
	_button(content,"RESTAURAR VOLUMES",_reset_volumes)
	_button(content,"VOLTAR",_show_pause if game_started else _show_title)

func _show_controls() -> void:
	if is_instance_valid(mobile_controls):
		var content := _create_overlay("CONTROLES DE TOQUE")
		var help := Label.new()
		help.text = "ANALÓGICO: andar\nPULO: saltar; toque novamente e segure para planar\nDASH: arrancada\nGOLPE: martelo\nCAIXA: construir (3 tábuas)\nII: pausar e retomar\n\nUse vários dedos para combinar as ações."
		content.add_child(help)
		_button(content,"VOLTAR",_show_settings)
		return
	var content := _create_overlay("CONTROLES")
	var keys := {"move_left":"Mover esquerda","move_right":"Mover direita","jump":"Pular / planar (2 toques)","dash":"Dash","attack":"Martelar","craft":"Construir","pause_game":"Pausar"}
	for action in keys:
		var control_button := Button.new()
		control_button.custom_minimum_size.y = 40
		control_button.text = str(keys[action])+" : "+_display_key(action)+" (alterar)"
		content.add_child(control_button)
		control_button.pressed.connect(_request_binding.bind(action,control_button))
	_button(content,"VOLTAR",_show_settings)

func _request_binding(action: String, button: Button) -> void:
	rebind_action = action
	button.text = "Pressione a nova tecla..."

func _display_key(action: String) -> String:
	var events := InputMap.action_get_events(action)
	if events.size()>0 and events[0] is InputEventKey: return OS.get_keycode_string(events[0].physical_keycode)
	return "?"

func _apply_binding(event: InputEventKey) -> void:
	var action := rebind_action
	rebind_action = ""
	if event.physical_keycode == KEY_ESCAPE:
		_show_controls()
		return
	if not InputMap.has_action(action) or event.physical_keycode <= 0: return
	InputMap.action_erase_events(action)
	var chosen := InputEventKey.new()
	chosen.physical_keycode = event.physical_keycode
	InputMap.action_add_event(action,chosen)
	_save_controls()
	_show_controls()

func _save_controls() -> void:
	var cfg := ConfigFile.new()
	for action in ["move_left","move_right","jump","dash","attack","craft","pause_game"]:
		var events := InputMap.action_get_events(action)
		if events.size()>0 and events[0] is InputEventKey:
			cfg.set_value("keys",action,events[0].physical_keycode)
	cfg.save(controls_file)

func _load_controls() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(controls_file)!=OK: return
	for action in ["move_left","move_right","jump","dash","attack","craft","pause_game"]:
		if not cfg.has_section_key("keys",action): continue
		var raw: Variant = cfg.get_value("keys",action)
		if typeof(raw) != TYPE_INT: continue
		var physical := int(raw)
		if physical <= 0: continue
		InputMap.action_erase_events(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = physical
		InputMap.action_add_event(action,ev)

func _change_volume(value: float, key: String) -> void:
	if not DEFAULT_VOLUMES.has(key): return
	settings[key] = clampf(value, 0.0, 1.0) if is_finite(value) else DEFAULT_VOLUMES[key]
	_apply_volume(key)
	_save_settings()

func _apply_volume(key: String) -> void:
	var bus: String = {"master":"Master","music":"Music","sfx":"SFX"}.get(key, "Master")
	var index := AudioServer.get_bus_index(bus)
	if index < 0: return
	var value: float = settings[key]
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index,linear_to_db(maxf(value,0.0001)))

func _reset_volumes() -> void:
	settings = DEFAULT_VOLUMES.duplicate()
	for key in settings: _apply_volume(key)
	_save_settings()
	_show_settings()

func _show_results(title: String,detail: String) -> void:
	var content := _create_overlay(title)
	var desc := Label.new()
	desc.text = "%s\nCenouras: %d   |   Inimigos: %d" % [detail,carrot_count,defeated_count]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(desc)
	if _qualifies():
		var prompt := Label.new()
		prompt.text = "Registre exatamente 3 letras A-Z:"
		content.add_child(prompt)
		record_input = LineEdit.new()
		record_input.max_length = 3
		record_input.placeholder_text = "AAA"
		content.add_child(record_input)
		if _qualifies(): _button(content,"REGISTRAR RECORDE",_save_record)
		if global_ranking.configured():
			var sharing := Label.new()
			sharing.text = "Ao registrar no TOP 10 local, enviamos automaticamente se entrar no TOP 100 global. Apelido e pontuação ficam públicos."
			sharing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			content.add_child(sharing)
			global_status = Label.new()
			global_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			global_status.text = global_ranking.status_text
			content.add_child(global_status)
	var listing := Label.new()
	listing.name = "Ranking"
	listing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	listing.text = _ranking_text()
	content.add_child(listing)
	_button(content,"REINICIAR DO INÍCIO",_restart)

func _qualifies() -> bool:
	return not record_saved and carrot_count>0 and (records.size()<RECORD_LIMIT or carrot_count>int(records[records.size()-1]["carrots"]))

func _valid_initials(value: String) -> bool:
	if value.length() != 3: return false
	for character in value:
		if character.unicode_at(0) < 65 or character.unicode_at(0) > 90: return false
	return true

func _load_records() -> void:
	records.clear()
	var cfg := ConfigFile.new()
	if cfg.load(records_file)!=OK: return
	var entries: Variant = cfg.get_value("ranking","entries",[])
	if not entries is Array: return
	for item in entries:
		if typeof(item)==TYPE_DICTIONARY and item.has("name") and item.has("carrots"):
			if typeof(item["name"]) != TYPE_STRING or typeof(item["carrots"]) != TYPE_INT: continue
			if not _valid_initials(item["name"]) or item["carrots"] < 0: continue
			records.append({"name":item["name"],"carrots":item["carrots"]})
	_sort_records()

func _sort_records() -> void:
	records.sort_custom(func(a: Dictionary,b: Dictionary)->bool: return int(a["carrots"])>int(b["carrots"]))
	if records.size()>RECORD_LIMIT: records.resize(RECORD_LIMIT)

func _save_record() -> void:
	if not is_finished or not _qualifies() or not is_instance_valid(record_input) or not record_input.editable: return
	var name := record_input.text.strip_edges().to_upper()
	if name.length()!=3:
		record_input.placeholder_text = "Use 3 letras!"
		return
	for i in range(3):
		if name.unicode_at(i)<65 or name.unicode_at(i)>90:
			record_input.text = ""
			record_input.placeholder_text = "Apenas A-Z"
			return
	var previous_records := records.duplicate(true)
	records.append({"name":name,"carrots":carrot_count})
	_sort_records()
	var cfg := ConfigFile.new()
	cfg.set_value("ranking","entries",records)
	if cfg.save(records_file)!=OK:
		records = previous_records
		record_input.placeholder_text = "Falha ao salvar"
		return
	record_saved = true
	record_input.editable = false
	global_ranking.submit_local_record(name,carrot_count)
	var listing := overlay_panel.find_child("Ranking",true,false) as Label
	if is_instance_valid(listing): listing.text = _ranking_text()

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var loaded := cfg.load(settings_file) == OK
	for key in settings.keys():
		var raw: Variant = cfg.get_value("audio", key, DEFAULT_VOLUMES[key]) if loaded else DEFAULT_VOLUMES[key]
		var value: float = float(raw) if typeof(raw) in [TYPE_FLOAT, TYPE_INT] else DEFAULT_VOLUMES[key]
		settings[key] = clampf(value, 0.0, 1.0) if is_finite(value) else DEFAULT_VOLUMES[key]
		_apply_volume(key)

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	for key in settings.keys(): cfg.set_value("audio",key,settings[key])
	if cfg.save(settings_file) != OK:
		push_warning("Não foi possível salvar as preferências de áudio.")

func _draw() -> void:
	if level != null: return
	# Prototype environment; art can be replaced by the provided tileset sheets.
	draw_rect(Rect2(0,-490,LEVEL_WIDTH,1280),Color("b9e9ec"))
	for span in ground_segments:
		draw_rect(Rect2(span.x,FLOOR_Y,span.y-span.x,140),Color("a7774e"))
		draw_rect(Rect2(span.x,FLOOR_Y,span.y-span.x,13),Color("74b85f"))
		for x in range(int(span.x)+14,int(span.y)-8,48):
			draw_rect(Rect2(x,FLOOR_Y+33,12,7),Color("c59666"))
	for data in rocks:
		var r := Rect2(Vector2(data[0]-data[2]/2,data[1]-data[3]/2),Vector2(data[2],data[3]))
		draw_rect(r,Color("828181"))
		draw_rect(Rect2(r.position.x+5,r.position.y+4,r.size.x-10,9),Color("a9aba4"))
	for data in ledges:
		draw_rect(Rect2(data[0]-data[2]/2,data[1]-10,data[2],20),Color("986d4d"))
		draw_rect(Rect2(data[0]-data[2]/2,data[1]-10,data[2],7),Color("67b264"))
	# Goal is the bunny's house, not a checkpoint.
	draw_rect(Rect2(11800,335,125,100),Color("c28c52"))
	draw_colored_polygon(PackedVector2Array([Vector2(11782,338),Vector2(11863,260),Vector2(11944,338)]),Color("8f543b"))
	draw_rect(Rect2(11850,375,34,60),Color("654330"))
	draw_rect(Rect2(11813,355,24,24),Color("e8d3a0"))

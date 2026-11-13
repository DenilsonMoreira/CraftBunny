extends SceneTree
const TOOLS = preload("res://scripts/tool_catalog.gd")
var game: Node2D
var p: CharacterBody2D
var failures := 0
var checks := 0
func check(value: bool, label: String) -> void:
 checks += 1
 if value: print("PASS: ",label)
 else:
  failures += 1
  push_error(label)
func _initialize() -> void: call_deferred("_run")
func ticks(count: int) -> void:
 for index in range(count):
  await physics_frame
  await process_frame
func action(name: String, pressed: bool) -> void:
 var event := InputEventAction.new()
 event.action = name
 event.pressed = pressed
 Input.parse_input_event(event)
func key_input(code: int,pressed: bool) -> void:
 var event := InputEventKey.new()
 event.physical_keycode = code
 event.pressed = pressed
 Input.parse_input_event(event)
func reset(tool := 0) -> void:
 for name in ["attack","jump","dash","switch_tool","move_right","move_left","craft"]: action(name,false)
 p._cancel_mobility()
 p.health = 3
 p.invincible_timer = 0
 p.hammer_timer = 0
 p.attack_active = 0
 p.attack_visual_timer = 0
 p.switch_remaining = 0
 p.queued_switch = false
 p.equipped_tool = tool
 p.position = Vector2(100,414)
 p.velocity = Vector2.ZERO
 p.facing = 1
 p.controls_enabled = true
 await ticks(3)
func target(kind: String, at: Vector2, hp := 20) -> CharacterBody2D:
 var enemy: CharacterBody2D = game.ENEMY_SCRIPT.new()
 enemy.setup(kind,at,p)
 enemy.hp = hp
 game.add_child(enemy)
 enemy.add_to_group("enemy")
 enemy.defeated.connect(game._on_enemy_defeated)
 return enemy
func parry_case(active: bool, side: bool) -> void:
 var rabbit: CharacterBody2D = game.PLAYER_SCRIPT.new()
 rabbit.position = Vector2(100,-500)
 root.add_child(rabbit)
 rabbit.set_physics_process(false)
 rabbit.controls_enabled = true
 rabbit.attack_tool = TOOLS.Type.PICKAXE
 rabbit.attack_total = 1
 rabbit.attack_visual_timer = .65 if active else .85
 rabbit.attack_active = .15 if active else 0
 var bird: CharacterBody2D = game.ENEMY_SCRIPT.new()
 bird.setup("ave",rabbit.position+Vector2(20,0 if side else -25),rabbit)
 root.add_child(bird)
 bird.set_physics_process(false)
 bird.attack_landed.connect(rabbit.take_damage)
 bird.active = true
 bird.state = "attack"
 bird.dive_direction = Vector2.LEFT if side else Vector2.DOWN
 bird._physics_process(1.0/60)
 if active and not side:
  check(bird.hp==4 and bird.state=="recover" and bird.knockback.length()>0,"active pickaxe intercepts descending front bird for 3 damage and knockback")
  check(rabbit.health==3 and rabbit.invincible_timer==0,"parry prevents this collision without general invulnerability")
  rabbit.take_damage(1,rabbit.position.x)
  check(rabbit.health==2,"other damage remains possible immediately after parry")
 else:
  check(rabbit.health==0,"side dive not blocked" if side else "pickaxe windup does not block bird damage")
 bird.queue_free()
 rabbit.queue_free()
 await process_frame
func _run() -> void:
 game = load("res://main.tscn").instantiate()
 game.records_file = "user://qa_tools_records.cfg"
 game.controls_file = "user://qa_tools_controls.cfg"
 game.settings_file = "user://qa_tools_settings.cfg"
 var legacy := ConfigFile.new()
 legacy.set_value("keys","dash",KEY_I)
 legacy.save(game.controls_file)
 root.add_child(game)
 game._begin_game()
 game.music_player.stop()
 game._set_enemies_active(false)
 p = game.player
 for enemy in get_nodes_in_group("enemy"): enemy.queue_free()
 await ticks(2)
 var key := InputEventKey.new()
 key.physical_keycode = KEY_L
 check(InputMap.action_has_event("dash",key),"official dash binding is L")
 key = InputEventKey.new()
 key.physical_keycode = KEY_I
 check(InputMap.action_has_event("switch_tool",key),"official switch binding is I")
 for expected in [1,2,3,0]:
  if expected==1: key_input(KEY_I,true)
  else: action("switch_tool",true)
  await ticks(1)
  if expected==1: key_input(KEY_I,false)
  else: action("switch_tool",false)
  check(p.equipped_tool==expected and p.switch_remaining>0,"cyclic switch selects "+TOOLS.NAMES[expected])
  await ticks(1)
  check(game.status_hud.equipped_tool==expected and p.switch_audio.stream.resource_path.ends_with("item-switch.mp3"),"HUD and supplied switch sound match tool")
  await ticks(16)
 check(p.tool_visual.available_animations.size()==33,"four tools expose eight states plus dedicated slingshot aim")
 var template := load("res://assets/production/tools/tool_frames_template.tres") as SpriteFrames
 check(template.get_animation_names().size()==32,"editable SpriteFrames template contains all named slots")
 var custom_frames := template.duplicate() as SpriteFrames
 custom_frames.add_frame("axe/fall",p.animated_sprite.sprite_frames.get_frame_texture("idle",0))
 var custom: CharacterBody2D = game.PLAYER_SCRIPT.new()
 custom.equipped_tool = 1
 custom.final_tool_frames = custom_frames
 custom.controls_enabled = true
 root.add_child(custom)
 custom.set_physics_process(false)
 custom.tool_visual.set_physics_process(false)
 custom.tool_visual._physics_process(1.0/60)
 check(custom.tool_visual.final_sprite.visible and not custom.tool_visual.draw_placeholder,"supplied final SpriteFrames replace provisional poses")
 custom.queue_free()
 await process_frame
 for tool in range(3):
  await reset(tool)
  var enemy := target("guaxinim",Vector2(134,422))
  action("attack",true)
  await ticks(1)
  action("attack",false)
  if tool==2:
   await ticks(15)
   check(enemy.hp==20 and p.attack_active==0,"pickaxe preparation is vulnerable for .30 s")
   await ticks(4)
   check(p.attack_active>0 and enemy.hp==17,"pickaxe active window starts after .30 s and deals 3 once")
   await ticks(12)
   check(p.attack_active==0 and p.attack_visual_timer>0,"pickaxe active window ends at .50 s with recovery remaining")
   p.take_damage(1,0)
   check(p.health==2,"pickaxe recovery takes normal damage")
   await ticks(34)
  else: await ticks(36)
  check(enemy.hp==20-int(TOOLS.DATA[tool]["damage"]),"single swing damage for "+TOOLS.NAMES[tool])
  check(p.hammer_timer==0,"tool recovery finishes for "+TOOLS.NAMES[tool])
  enemy.queue_free()
  await process_frame
 await parry_case(true,false)
 await parry_case(false,false)
 await parry_case(true,true)
 await reset(2)
 action("attack",true)
 await ticks(1)
 action("attack",false)
 action("switch_tool",true)
 await ticks(1)
 action("switch_tool",false)
 check(p.queued_switch and p.equipped_tool==2,"switch requested during heavy attack waits instead of cancelling recovery")
 await ticks(63)
 check(p.equipped_tool==3,"queued switch runs after heavy recovery")
 await reset(3)
 game.carrot_count = 2
 action("attack",true)
 await ticks(2)
 action("switch_tool",true)
 await ticks(1)
 action("switch_tool",false)
 action("attack",false)
 await ticks(2)
 check(not p.aiming and game.carrot_count==2 and get_nodes_in_group("carrot_projectiles").is_empty(),"switch cancels aiming without an accidental shot")
 await reset(3)
 game.carrot_count = 2
 p.hammer_timer = .20
 action("attack",true)
 await ticks(2)
 check(p.aiming and p.tool_visual.trajectory_points.size()>2,"holding J can aim during shot cooldown and displays a predicted parabola")
 var start_x: float = p.position.x
 action("move_right",true)
 await ticks(10)
 check(p.position.x>start_x and p.aiming,"rabbit walks freely while aiming")
 action("move_right",false)
 action("attack",false)
 await ticks(1)
 check(game.carrot_count==1 and get_nodes_in_group("carrot_projectiles").size()==1,"release J consumes one carrot and creates one projectile")
 for projectile in get_nodes_in_group("carrot_projectiles"): projectile.queue_free()
 await reset(3)
 game.carrot_count = 0
 action("attack",true)
 await ticks(2)
 action("attack",false)
 await ticks(1)
 check(game.carrot_count==0 and get_nodes_in_group("carrot_projectiles").is_empty(),"no ammunition means no projectile or negative score")
 await reset(3)
 game.carrot_count = 1
 var victim := target("guaxinim",Vector2(345,422),5)
 game._on_sling_released(p.sling_origin(),p.sling_velocity())
 await ticks(50)
 check(victim.hp==2 and game.carrot_count==0,"ballistic projectile hits enemy for 3 damage")
 victim.queue_free()
 await ticks(2)
 game._add_solid(Vector2(200,350),Vector2(20,400))
 var behind := target("guaxinim",Vector2(345,422),5)
 game.carrot_count = 1
 game._on_sling_released(Vector2(122,402),Vector2(390,-230))
 await ticks(50)
 check(behind.hp==5 and get_nodes_in_group("carrot_projectiles").is_empty(),"projectile stops on scenery without damaging target behind wall")
 behind.queue_free()
 await ticks(2)
 var trees := get_nodes_in_group("tool_obstacles").filter(func(n): return n.kind=="tree")
 var rocks := get_nodes_in_group("tool_obstacles").filter(func(n): return n.kind=="rock")
 check(trees.size()==2 and rocks.size()==2,"native phase contains two tree and two rock challenges")
 for tree in trees:
  check(not tree.apply_tool(0) and not tree.apply_tool(2) and tree.hp==3,"tree requires axe")
  for hit in range(3): tree.apply_tool(1)
  await ticks(45)
  check(tree.bridge_ready and not tree.collider.disabled,"felled tree finishes animation and enables solid bridge")
  var rect: Rect2 = tree.bridge_rect()
  var query := PhysicsRayQueryParameters2D.create(rect.get_center()+Vector2(0,-60),rect.get_center()+Vector2(0,60),1)
  var result := game.get_world_2d().direct_space_state.intersect_ray(query)
  check(not result.is_empty() and result["collider"]==tree,"fallen trunk has traversable collision across the middle of chasm")
 for rock in rocks:
  check(not rock.apply_tool(0) and not rock.apply_tool(1) and rock.hp==3,"rock requires pickaxe")
  rock.apply_tool(2)
  check(rock.hp==2 and not rock.broken,"rock cracks before breaking")
  rock.apply_tool(2)
  rock.apply_tool(2)
  await ticks(2)
  check(rock.broken and rock.collider.disabled,"broken rock opens passage collision")
 var carrot_markers: Array = game.level.get_node("Itens").get_children().filter(func(n):return n.get_meta("kind","")=="carrot")
 check(carrot_markers.size()==140,"map carrot budget preserved at 140")
 var covered := 0
 for marker in carrot_markers:
  if (marker.position.x>6244-1 and marker.position.x<6500 and marker.position.y>800) or (marker.position.x>18532-1 and marker.position.x<18800 and marker.position.y>800): covered+=1
 check(covered==12,"twelve existing carrots are in visible rock passages")
 await reset(0)
 var before_wood: int = game.wood_count
 game.wood_count = 6
 game._on_box_requested()
 check(game.wood_count==3,"hammer builds crate for three boards")
 var crate = get_nodes_in_group("crates")[-1]
 check(crate.hp==2,"new crate retains two HP")
 crate.queue_free()
 p.equipped_tool = 1
 game._on_box_requested()
 check(game.wood_count==3,"other tools cannot spend wood to build")
 game.wood_count = before_wood
 for kind in ["cobra","guaxinim","ave"]:
  var reward := [0]
  var enemy := target(kind,Vector2(800,400),1)
  enemy.defeated.connect(func(_enemy,value): reward[0]=value)
  var old_defeated: int = game.defeated_count
  enemy.take_hit(3,0)
  check(game.defeated_count==old_defeated+1,"enemy reward event still fires for "+kind)
  check(reward[0]==int(game.ENEMY_SCRIPT.DATA[kind]["reward"]),"enemy drop count remains exact for "+kind)
  await ticks(1)
 await reset(0)
 key_input(KEY_L,true)
 await ticks(1)
 check(p.dash_timer>0 and p.velocity.x==600,"dash remains functional with tool system")
 key_input(KEY_L,false)
 await ticks(60)
 action("jump",true)
 await ticks(2)
 action("jump",false)
 await ticks(2)
 action("jump",true)
 await ticks(20)
 check(p.gliding and p.velocity.y<=70,"double-tap glide preserved")
 action("jump",false)
 await reset(0)
 p.take_damage(1)
 p.take_damage(1)
 check(p.health==2,"damage immunity still rejects a simultaneous second hit")
 await ticks(31)
 p.take_damage(1)
 check(p.health==1,"damage can occur again after the official half-second immunity")
 await reset(3)
 game.carrot_count = 4
 game._on_sling_released(p.sling_origin(),p.sling_velocity())
 check(game.carrot_count==3,"ammunition subtracts from remaining ranking score")
 game._finish(true)
 game.records.clear()
 game.record_saved = false
 game.record_input.text = "TST"
 game._save_record()
 check(game.records.size()==1 and game.records[0]["carrots"]==3,"local ranking stores remaining carrots, not total collected")
 check(is_equal_approx(p.INVULNERABILITY,.5) and p.COYOTE_TIME==.12 and p.JUMP_BUFFER_TIME==.12,"official .5 s damage protection and .12 s jump grace preserved")
 game.queue_free()
 await process_frame
 print("TOOLS_CHECKS=",checks," FAILURES=",failures)
 quit(0 if failures==0 else 1)

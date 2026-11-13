extends Control

signal pause_requested()
var game: Node
var fingers: Dictionary = {}
const STICK_CENTER := Vector2(106,450)
const STICK_RADIUS := 74.0
const STICK_KNOB_RADIUS := 27.0
const STICK_TRAVEL := STICK_RADIUS-STICK_KNOB_RADIUS
const STICK_DEADZONE := 0.22
var stick_finger := -1
var stick_offset := Vector2.ZERO
const BUTTONS := [
 {"area": Rect2(842,394,92,92), "action":"jump", "label":"PULO"},
 {"area": Rect2(742,446,78,78), "action":"attack", "label":"GOLPE"},
 {"area": Rect2(650,446,78,78), "action":"craft", "label":"CAIXA"},
 {"area": Rect2(742,350,78,78), "action":"dash", "label":"DASH"},
 {"area": Rect2(650,350,78,78), "action":"switch_tool", "label":""},
 {"area": Rect2(886,90,50,44), "action":"pause", "label":"II"}
]

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 visible = false

func _process(_delta: float) -> void:
 visible = is_instance_valid(game) and game.game_started and not game.is_finished
 if not visible or game.pause_open: release_all()
 queue_redraw()

func release_all() -> void:
 for action in fingers.values(): _send_action(action,false)
 fingers.clear()
 stick_finger = -1
 stick_offset = Vector2.ZERO
 queue_redraw()

func release_stick() -> void:
 if stick_finger != -1: set_finger(stick_finger,"")
 stick_finger = -1
 stick_offset = Vector2.ZERO
 queue_redraw()

func update_stick(point: Vector2) -> void:
 stick_offset = (point-STICK_CENTER).limit_length(STICK_TRAVEL)
 var axis := stick_offset.x/STICK_TRAVEL
 # Preserve the existing movement speed; the stick chooses direction only.
 set_finger(stick_finger,"move_left" if axis < -STICK_DEADZONE else ("move_right" if axis > STICK_DEADZONE else ""))
 queue_redraw()

func set_finger(index: int, action: String) -> void:
 var previous: String = fingers.get(index,"")
 if previous == action: return
 fingers.erase(index)
 if previous != "" and previous not in fingers.values(): _send_action(previous,false)
 if action != "":
  var already_held := action in fingers.values()
  fingers[index] = action
  if not already_held: _send_action(action,true)
 queue_redraw()

func _send_action(action: String, pressed: bool) -> void:
 # Keep touch state immediate, then deliver its explicit edge to the movement
 # adapter. parse_input_event is buffered and can reorder rapid touch releases.
 var event := InputEventAction.new()
 event.action = action
 event.pressed = pressed
 if pressed: Input.action_press(action)
 else: Input.action_release(action)
 if is_instance_valid(game) and is_instance_valid(game.player):
  game.player.handle_movement_input(event)

func _input(event: InputEvent) -> void:
 if not visible: return
 if event is InputEventScreenTouch:
  if not event.pressed:
   if event.index == stick_finger:
    release_stick()
    get_viewport().set_input_as_handled()
   elif fingers.has(event.index):
    set_finger(event.index,"")
    get_viewport().set_input_as_handled()
   return
  handle_touch(event.index,event.position,true)
 elif event is InputEventScreenDrag:
  if event.index == stick_finger or fingers.has(event.index): handle_touch(event.index,event.position,false)

func handle_touch(index: int, point: Vector2, pressed: bool) -> void:
 var local := get_global_transform_with_canvas().affine_inverse()*point
 if index == stick_finger:
  if game.pause_open: release_stick()
  else: update_stick(local)
  get_viewport().set_input_as_handled()
  return
 if pressed and local.distance_to(STICK_CENTER) <= STICK_RADIUS and not game.pause_open:
  if stick_finger == -1:
   stick_finger = index
   update_stick(local)
  get_viewport().set_input_as_handled()
  return
 for button in BUTTONS:
  var area: Rect2 = button["area"]
  if local.distance_to(area.get_center()) > minf(area.size.x,area.size.y)/2.0: continue
  var action: String = button["action"]
  if action == "pause":
   if pressed:
    release_all()
    pause_requested.emit()
  elif not game.pause_open:
   set_finger(index,action)
  get_viewport().set_input_as_handled()
  return
 set_finger(index,"")

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT: release_all()

func _exit_tree() -> void:
 release_all()

func _draw() -> void:
 _draw_stick()
 for button in BUTTONS:
  var action: String = button["action"]
  var rect: Rect2 = button["area"]
  var pressed: bool = action in fingers.values()
  var ring := _pixel_ring(rect.get_center(),minf(rect.size.x,rect.size.y)/2.0-2)
  draw_colored_polygon(ring,Color(.14,.24,.17,.80) if pressed else Color(.15,.19,.14,.60))
  var edge := ring.duplicate()
  edge.append(ring[0])
  draw_polyline(edge,Color("f0cf87"),2)
  var icon := action
  if action=="attack" and is_instance_valid(game):
   icon = preload("res://scripts/tool_catalog.gd").KEYS[game.player.equipped_tool]
   if game.player.aiming: draw_polyline(edge,Color("ffe867"),4)
  preload("res://scripts/tool_icons.gd").draw_icon(self,icon,rect.get_center(),1.0)

func _pixel_ring(center: Vector2, radius: float) -> PackedVector2Array:
 var points := PackedVector2Array()
 for index in range(12):
  var angle := TAU*float(index)/12.0
  points.append(center+(Vector2(cos(angle),sin(angle))*radius).snapped(Vector2(2,2)))
 return points

func _draw_stick() -> void:
 var base := _pixel_ring(STICK_CENTER,STICK_RADIUS)
 draw_colored_polygon(base,Color(0.10,0.18,0.13,0.16))
 var outline := base.duplicate()
 outline.append(base[0])
 draw_polyline(outline,Color(0.92,0.96,0.83,0.42),2.0)
 var knob := _pixel_ring(STICK_CENTER+stick_offset.snapped(Vector2(2,2)),STICK_KNOB_RADIUS)
 draw_colored_polygon(knob,Color(0.80,0.88,0.71,0.30 if stick_finger==-1 else 0.45))
 var knob_outline := knob.duplicate()
 knob_outline.append(knob[0])
 draw_polyline(knob_outline,Color(0.97,0.97,0.85,0.64),2.0)
 for direction in [-1,1]:
  var tip := STICK_CENTER+Vector2(direction*57,0)
  draw_polyline(PackedVector2Array([tip+Vector2(-direction*6,-5),tip,tip+Vector2(-direction*6,5)]),Color(1,1,0.9,0.40),2.0)

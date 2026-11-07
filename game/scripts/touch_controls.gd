extends Control

signal pause_requested()
var game: Node
var fingers: Dictionary = {}
const BUTTONS := [
 {"area": Rect2(20,414,78,78), "action":"move_left", "label":"ESQ"},
 {"area": Rect2(110,414,78,78), "action":"move_right", "label":"DIR"},
 {"area": Rect2(842,394,92,92), "action":"jump", "label":"PULO"},
 {"area": Rect2(742,446,78,78), "action":"attack", "label":"GOLPE"},
 {"area": Rect2(650,446,78,78), "action":"craft", "label":"CAIXA"},
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
 for action in fingers.values(): Input.action_release(action)
 fingers.clear()

func set_finger(index: int, action: String) -> void:
 var previous: String = fingers.get(index,"")
 if previous == action: return
 fingers.erase(index)
 if previous != "" and previous not in fingers.values(): Input.action_release(previous)
 if action != "":
  fingers[index] = action
  Input.action_press(action)
 queue_redraw()

func _input(event: InputEvent) -> void:
 if not visible: return
 if event is InputEventScreenTouch:
  if not event.pressed:
   if fingers.has(event.index):
    set_finger(event.index,"")
    get_viewport().set_input_as_handled()
   return
  handle_touch(event.index,event.position,true)
 elif event is InputEventScreenDrag:
  if fingers.has(event.index): handle_touch(event.index,event.position,false)

func handle_touch(index: int, point: Vector2, pressed: bool) -> void:
 var local := get_global_transform_with_canvas().affine_inverse()*point
 for button in BUTTONS:
  if not button["area"].has_point(local): continue
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
 for button in BUTTONS:
  var action: String = button["action"]
  var rect: Rect2 = button["area"]
  var pressed: bool = action in fingers.values()
  var style := preload("res://scripts/ui_theme.gd").wood(true,Color(0.65,0.90,0.55) if pressed else Color(1,1,1,0.90))
  draw_style_box(style,rect)
  var font := preload("res://scripts/ui_theme.gd").pixel_font()
  var label: String = button["label"]
  var text_size := font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,16)
  draw_string(font,Vector2(rect.get_center().x-text_size.x/2,rect.get_center().y+6),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("fff0cf"))

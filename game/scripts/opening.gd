extends Control
signal finished
const STORY = preload("res://assets/production/intro/storyboard.png")
const REGIONS := [Rect2(6,6,676,372),Rect2(694,6,674,372),Rect2(6,388,676,370),Rect2(694,388,674,370),Rect2(6,768,676,371),Rect2(694,768,674,371)]
const SLIDE_SECONDS := 3.6
const FADE_SECONDS := .32
@export var enter_title := true
var settings_file := "user://settings.cfg"
var slide_index := 0
var elapsed := 0.0
var completed := false
var focused := true
var last_navigation := -1000
var music: AudioStreamPlayer
var picture: TextureRect
var previous: TextureRect
var counter: Label
var next_button: Button

func _ready() -> void:
 if OS.has_feature("android"): get_tree().quit_on_go_back = false
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 theme = preload("res://scripts/ui_theme.gd").create()
 var bg := ColorRect.new()
 bg.color = Color("211a14")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(bg)
 previous = _picture("PreviousSlide")
 picture = _picture("CurrentSlide")
 var footer := MarginContainer.new()
 footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 footer.offset_top = -60
 footer.offset_left = 12
 footer.offset_right = -12
 footer.offset_bottom = -8
 add_child(footer)
 var controls := HBoxContainer.new()
 controls.add_theme_constant_override("separation",8)
 footer.add_child(controls)
 var skip := Button.new()
 skip.name = "Skip"
 skip.text = "PULAR"
 skip.custom_minimum_size = Vector2(110,46)
 skip.pressed.connect(finish)
 controls.add_child(skip)
 counter = Label.new()
 counter.name = "SlideCounter"
 counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 counter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
 counter.mouse_filter = Control.MOUSE_FILTER_IGNORE
 counter.add_theme_font_size_override("font_size",14)
 controls.add_child(counter)
 next_button = Button.new()
 next_button.name = "Next"
 next_button.custom_minimum_size = Vector2(160,46)
 next_button.tooltip_text = "Espaço, Enter ou toque para avançar"
 next_button.pressed.connect(_request_advance)
 controls.add_child(next_button)
 music = preload("res://scripts/menu_music.gd").new()
 add_child(music)
 music.apply_saved_volumes(settings_file)
 music.start_menu()
 _show_slide()

func _picture(node_name: String) -> TextureRect:
 var rect := TextureRect.new()
 rect.name = node_name
 rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 rect.offset_bottom = -64
 rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(rect)
 return rect

func _show_slide() -> void:
 previous.texture = picture.texture
 previous.visible = previous.texture!=null
 var frame := AtlasTexture.new()
 frame.atlas = STORY
 frame.region = REGIONS[slide_index]
 frame.filter_clip = true
 picture.texture = frame
 picture.modulate.a = 0
 counter.text = "%d / 6" % (slide_index+1)
 next_button.text = "COMEÇAR >" if slide_index==5 else "PRÓXIMO >"

func _process(delta: float) -> void:
 if completed or not focused: return
 elapsed += delta
 picture.modulate.a = minf(1,elapsed/FADE_SECONDS)
 previous.visible = elapsed<FADE_SECONDS and previous.texture!=null
 if elapsed>=SLIDE_SECONDS: advance()

func advance() -> void:
 if completed: return
 if slide_index==5:
  finish()
  return
 slide_index += 1
 elapsed = 0
 _show_slide()

func _request_advance() -> void:
 var now := Time.get_ticks_msec()
 # Touch may also synthesize a mouse click; advance once per physical gesture.
 if now-last_navigation<180: return
 last_navigation = now
 advance()

func _unhandled_input(event: InputEvent) -> void:
 if completed: return
 if event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_ESCAPE:
   finish()
  elif event.physical_keycode in [KEY_SPACE,KEY_ENTER,KEY_RIGHT]:
   _request_advance()
  else: return
 elif (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT):
  _request_advance()
 else: return
 get_viewport().set_input_as_handled()

func finish() -> void:
 if completed: return
 completed = true
 set_process(false)
 finished.emit()
 if enter_title: _enter_title.call_deferred()

func _enter_title() -> void:
 music.reparent(get_tree().root)
 var error := get_tree().change_scene_to_file("res://main.tscn")
 if error!=OK: push_error("Não foi possível abrir a tela de título: "+str(error))

func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT: focused = false
 elif what==NOTIFICATION_APPLICATION_FOCUS_IN: focused = true
 elif what==NOTIFICATION_WM_GO_BACK_REQUEST: finish()

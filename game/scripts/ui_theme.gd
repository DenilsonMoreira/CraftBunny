extends RefCounted

static func box(fill: String, border: String, width: int = 3) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = Color(fill)
 style.border_color = Color(border)
 style.set_border_width_all(width)
 style.set_corner_radius_all(0)
 style.content_margin_left = 14
 style.content_margin_right = 14
 style.content_margin_top = 8
 style.content_margin_bottom = 8
 return style

static func wood(panel := false, tint := Color.WHITE) -> StyleBoxTexture:
 var style := StyleBoxTexture.new()
 style.texture = preload("res://assets/production/v2/menu_panel.png") if panel else preload("res://assets/production/v2/hud_wood.png")
 style.modulate_color = tint
 style.content_margin_left = 26 if panel else 20
 style.content_margin_right = 26 if panel else 20
 style.content_margin_top = 52 if panel else 10
 style.content_margin_bottom = 28 if panel else 10
 return style

static func pixel_font() -> Font:
 var font := preload("res://assets/production/v2/fonts/Silkscreen-Regular.ttf") as FontFile
 font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
 font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
 return font

static func create() -> Theme:
 var theme := Theme.new()
 theme.default_font = pixel_font()
 theme.default_font_size = 16
 theme.set_color("font_color", "Label", Color("fff0d4"))
 theme.set_stylebox("panel", "PanelContainer", wood(true))
 theme.set_stylebox("normal", "Button", wood())
 theme.set_stylebox("hover", "Button", wood(false,Color(1.25,1.2,1.05)))
 theme.set_stylebox("pressed", "Button", wood(false,Color(0.65,0.82,0.58)))
 theme.set_stylebox("focus", "Button", box("00000000", "ffcc71", 2))
 for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
  theme.set_color(state, "Button", Color("fff2da"))
 theme.set_font_size("font_size", "Button", 16)
 theme.set_color("font_outline_color", "Button", Color("24170f"))
 theme.set_constant("outline_size", "Button", 3)
 theme.set_constant("outline_size", "Label", 2)
 theme.set_color("font_outline_color", "Label", Color("24170f"))
 theme.set_stylebox("disabled", "Button", wood(false,Color(0.5,0.5,0.5)))
 theme.set_stylebox("normal", "LineEdit", box("30251f", "ba874d", 2))
 theme.set_stylebox("focus", "LineEdit", box("00000000", "ffcc71", 2))
 theme.set_color("font_color", "LineEdit", Color("fff2da"))
 theme.set_color("font_placeholder_color", "LineEdit", Color("c9b49a"))
 theme.set_stylebox("slider", "HSlider", box("30251f", "765236", 1))
 theme.set_stylebox("grabber_area", "HSlider", box("70934b", "a0ba65", 1))
 theme.set_stylebox("grabber_area_highlight", "HSlider", box("a0ba65", "e9bd73", 1))
 var knob := GradientTexture2D.new()
 var gradient := Gradient.new()
 gradient.colors = PackedColorArray([Color("e8ad51"),Color("e8ad51")])
 knob.gradient = gradient
 knob.width = 14
 knob.height = 20
 theme.set_icon("grabber","HSlider",knob)
 theme.set_icon("grabber_highlight","HSlider",knob)
 theme.set_stylebox("scroll","VScrollBar",box("271d16","765236",1))
 theme.set_stylebox("grabber","VScrollBar",box("af783c","e9bd73",2))
 theme.set_stylebox("grabber_highlight","VScrollBar",box("cf984e","ffdfa3",2))
 return theme

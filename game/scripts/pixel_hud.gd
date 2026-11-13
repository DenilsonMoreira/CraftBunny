extends Control

const BACK = preload("res://assets/production/v2/hud_wood.png")
const ART = preload("res://scripts/prop_art.gd")
var hp := 3
var carrots := 0
var wood := 0
var carrot_icon: Texture2D
var wood_icon: Texture2D
var full_heart: Texture2D
var empty_heart: Texture2D
var equipped_tool := 0
var aiming := false
var switch_flash := 0.0

func update_equipment(tool: int, is_aiming: bool, flash: float) -> void:
 equipped_tool = tool
 aiming = is_aiming
 switch_flash = flash
 queue_redraw()

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 carrot_icon = ART.texture("carrot")
 wood_icon = ART.texture("wood")
 full_heart = ART.texture("heart")
 empty_heart = ART.texture("heart_empty")
 queue_redraw()

func update_values(health: int, score: int, planks: int) -> void:
 hp = health
 carrots = score
 wood = planks
 queue_redraw()

func text_at(value: String, point: Vector2, size: int, color := Color("fff0cf")) -> void:
 var font := ThemeDB.fallback_font
 draw_string_outline(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 3, Color("301b12"))
 draw_string(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func heart(origin: Vector2, filled: bool) -> void:
 var texture: Texture2D = full_heart if filled else empty_heart
 if texture == null: return
 var size: Vector2 = ART.fit(texture,Vector2(28,26))
 draw_texture_rect(texture, Rect2(origin,size), false)

func _draw() -> void:
 var panels := [Rect2(0,0,228,76), Rect2(230,0,190,76), Rect2(422,0,234,76), Rect2(658,0,278,76)]
 for panel in panels: draw_texture_rect(BACK, panel, false)
 text_at("VIDA", Vector2(30,31), 12, Color("ddb77b"))
 for i in range(3): heart(Vector2(30+i*43,39), i < hp)
 text_at("CENOURAS", Vector2(273,31), 12, Color("ddb77b"))
 if carrot_icon != null: draw_texture_rect(carrot_icon, Rect2(256,36,20,26), false)
 text_at(str(carrots).pad_zeros(3), Vector2(287,58), 21)
 text_at("TÁBUAS", Vector2(471,31), 12, Color("ddb77b"))
 if wood_icon != null: draw_texture_rect(wood_icon, Rect2(451,41,28,17), false)
 text_at(str(wood), Vector2(495,58), 21 if wood < 100000 else 15)
 text_at("SEM LIMITE", Vector2(557,30), 9, Color("b5d36a"))
 var tools = preload("res://scripts/tool_catalog.gd")
 text_at(tools.NAMES[equipped_tool].to_upper(), Vector2(714,31), 12, Color("ffe4a0") if switch_flash>0 else Color("ddb77b"))
 preload("res://scripts/tool_icons.gd").draw_icon(self,tools.KEYS[equipped_tool],Vector2(697,49),.85)
 var mobile := OS.has_feature("android") or DisplayServer.is_touchscreen_available() or "--touch" in OS.get_cmdline_user_args()
 text_at("MIRANDO" if aiming else (("Caixa: 3 tábuas" if mobile else "K: caixa / 3 tábuas") if equipped_tool==0 else ("Trocar ferramenta" if mobile else "I: trocar")), Vector2(720,57), 12,Color("ffe388") if aiming else Color("cfb69a"))

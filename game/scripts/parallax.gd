extends Node2D

const ART = preload("res://scripts/prop_art.gd")
const EARTH = preload("res://assets/production/tiles/forest_ground_v2.png")
var tree: Texture2D
var pine: Texture2D

func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 tree = ART.texture("tree")
 pine = ART.texture("pine")
 queue_redraw()

func _draw() -> void:
 if tree == null: return
 # A continuous distant bank supports the trees behind foreground gaps.
 for x in range(-800,15000,128):
  draw_texture_rect_region(EARTH, Rect2(x,415,128,500), Rect2(0,180,EARTH.get_width(),EARTH.get_height()-180), Color(0.48,0.62,0.52))
 # Two depth bands, muted so enemies and collectibles remain legible.
 for x in range(-700, 14500, 240):
  var texture: Texture2D = pine if posmod(x, 480) == 0 else tree
  var size: Vector2 = ART.fit(texture, Vector2(220,310))
  draw_texture_rect(texture, Rect2(x,415-size.y,size.x,size.y), false, Color(0.70,0.86,0.80,0.48))
 for x in range(-350, 14500, 370):
  var texture: Texture2D = tree if posmod(x, 740) == 390 else pine
  var size: Vector2 = ART.fit(texture, Vector2(185,245))
  draw_texture_rect(texture, Rect2(x,415-size.y,size.x,size.y), false, Color(0.82,0.92,0.80,0.78))

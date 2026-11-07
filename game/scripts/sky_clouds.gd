extends Node2D
const ART = preload("res://scripts/prop_art.gd")
var clouds: Array[Texture2D] = []

func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 clouds = [ART.texture("cloud"), ART.texture("cloud_small")]
 queue_redraw()

func _draw() -> void:
 if clouds.is_empty(): return
 for index in range(50):
  var x := -750.0 + index*310.0
  var cloud: Texture2D = clouds[index % 2]
  var size: Vector2 = ART.fit(cloud, Vector2(165,65) if index % 3 else Vector2(215,82))
  draw_texture_rect(cloud, Rect2(x,105+(index%3)*29,size.x,size.y), false, Color(1,1,1,0.9))

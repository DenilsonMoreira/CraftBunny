extends StaticBody2D

var hp := 2

func _ready() -> void:
 collision_layer = 1
 collision_mask = 1
 var col := CollisionShape2D.new()
 var shape := RectangleShape2D.new()
 shape.size = Vector2(42,42)
 col.shape = shape
 add_child(col)

func take_hammer_hit() -> void:
 hp -= 1
 if hp <= 0:
  queue_free()
 else:
  queue_redraw()

func _draw() -> void:
 var texture: Texture2D = preload("res://scripts/prop_art.gd").texture("crate" if hp > 1 else "crate_damaged")
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 draw_texture_rect(texture, Rect2(-21,-21,42,42), false)

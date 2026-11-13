extends RefCounted
## Native pixel-shaped placeholder icons, shared by HUD, touch and tools.
static func draw_icon(canvas: CanvasItem, action: String, center: Vector2, factor := 1.0, angle := 0.0) -> void:
 canvas.draw_set_transform(center,angle,Vector2.ONE*factor)
 var ink := Color("392a25")
 var wood := Color("b87938")
 var metal := Color("c3d2c9")
 match action:
  "hammer","axe","pickaxe":
   canvas.draw_rect(Rect2(-3,-6,6,22),ink)
   canvas.draw_rect(Rect2(-1,-5,3,19),wood)
   if action=="hammer":
    canvas.draw_rect(Rect2(-12,-15,24,12),ink)
    canvas.draw_rect(Rect2(-10,-13,20,8),Color("d9a050"))
   elif action=="axe":
    canvas.draw_colored_polygon(PackedVector2Array([Vector2(-3,-13),Vector2(11,-18),Vector2(15,-5),Vector2(2,-5)]),ink)
    canvas.draw_colored_polygon(PackedVector2Array([Vector2(-1,-11),Vector2(10,-15),Vector2(12,-7),Vector2(2,-7)]),metal)
   else:
    canvas.draw_polyline(PackedVector2Array([Vector2(-15,-5),Vector2(-6,-14),Vector2(5,-14),Vector2(15,-5)]),ink,6)
    canvas.draw_polyline(PackedVector2Array([Vector2(-14,-6),Vector2(-5,-13),Vector2(5,-13),Vector2(14,-6)]),metal,3)
  "slingshot":
   canvas.draw_polyline(PackedVector2Array([Vector2(-12,-13),Vector2(0,0),Vector2(12,-13)]),ink,7)
   canvas.draw_polyline(PackedVector2Array([Vector2(-12,-13),Vector2(0,0),Vector2(12,-13)]),wood,4)
   canvas.draw_line(Vector2(0,0),Vector2(0,15),wood,5)
   canvas.draw_polyline(PackedVector2Array([Vector2(-12,-13),Vector2(0,-5),Vector2(12,-13)]),Color("e9d3a5"),2)
  "jump":
   canvas.draw_polyline(PackedVector2Array([Vector2(-12,-2),Vector2(0,-14),Vector2(12,-2)]),Color("fff0cf"),5)
   canvas.draw_line(Vector2(0,-12),Vector2(0,14),Color("fff0cf"),5)
  "dash":
   for x in [-6,7]: canvas.draw_polyline(PackedVector2Array([Vector2(x-8,-12),Vector2(x+3,0),Vector2(x-8,12)]),Color("fff0cf"),4)
  "craft":
   canvas.draw_rect(Rect2(-14,-13,28,27),Color("d5a15b"),false,3)
   canvas.draw_line(Vector2(-11,-10),Vector2(11,11),wood,4)
   canvas.draw_line(Vector2(11,-10),Vector2(-11,11),wood,4)
  "switch_tool":
   canvas.draw_polyline(PackedVector2Array([Vector2(-14,-4),Vector2(-9,-12),Vector2(11,-12),Vector2(6,-17)]),Color("fff0cf"),3)
   canvas.draw_line(Vector2(11,-12),Vector2(6,-7),Color("fff0cf"),3)
   canvas.draw_polyline(PackedVector2Array([Vector2(14,4),Vector2(9,12),Vector2(-11,12),Vector2(-6,17)]),Color("fff0cf"),3)
   canvas.draw_line(Vector2(-11,12),Vector2(-6,7),Color("fff0cf"),3)
  "pause":
   canvas.draw_rect(Rect2(-9,-12,6,24),Color("fff0cf"))
   canvas.draw_rect(Rect2(4,-12,6,24),Color("fff0cf"))
 canvas.draw_set_transform(Vector2.ZERO)

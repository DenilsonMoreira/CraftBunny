extends Area2D

signal collected(pickup: Area2D)
var kind := "carrot"
var amount := 1
var age := 0.0
var _claimed := false
var art: Sprite2D

func setup(item_kind: String, count: int = 1) -> void:
 kind = item_kind
 amount = count

func _ready() -> void:
 collision_layer = 0
 collision_mask = 1
 var col := CollisionShape2D.new()
 var circle := CircleShape2D.new()
 circle.radius = 16
 col.shape = circle
 add_child(col)
 body_entered.connect(_on_body_entered)
 if kind in ["carrot", "wood", "heart"]:
  var factory = preload("res://scripts/prop_art.gd")
  art = Sprite2D.new()
  art.texture = factory.texture(kind)
  var limits := {"carrot": Vector2(20,26), "wood": Vector2(26,16), "heart": Vector2(24,24)}
  var size: Vector2 = factory.fit(art.texture, limits[kind])
  art.scale = size / art.texture.get_size()
  art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  add_child(art)

func _on_body_entered(body: Node2D) -> void:
 if not _claimed and body.is_in_group("player"):
  collected.emit(self)

func _process(delta: float) -> void:
 age += delta
 if is_instance_valid(art): art.position.y = sin(age*4.0)*3.0
 queue_redraw()

func _draw() -> void:
 if is_instance_valid(art): return
 var bob := sin(age*4.0)*3.0
 if kind == "carrot":
  draw_colored_polygon(PackedVector2Array([Vector2(-9,-9+bob),Vector2(10,-8+bob),Vector2(1,16+bob)]),Color("ed8a32"))
  draw_line(Vector2(0,-10+bob),Vector2(-5,-20+bob),Color("5eac50"),4)
  draw_line(Vector2(0,-10+bob),Vector2(6,-21+bob),Color("5eac50"),4)
 elif kind == "wood":
  draw_set_transform(Vector2(0,bob),0)
  draw_rect(Rect2(-12,-9,24,18),Color("8c542c"))
  draw_rect(Rect2(-10,-7,20,13),Color("c88a46"))
  draw_line(Vector2(-7,-5),Vector2(7,-5),Color("e5af63"),3)
 elif kind == "heart":
  var red := Color("eb5158")
  draw_circle(Vector2(-6,-5+bob),8,red)
  draw_circle(Vector2(6,-5+bob),8,red)
  draw_colored_polygon(PackedVector2Array([Vector2(-14,-4+bob),Vector2(14,-4+bob),Vector2(0,14+bob)]),red)

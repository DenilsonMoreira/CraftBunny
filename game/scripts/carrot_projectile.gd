extends CharacterBody2D
const CATALOG = preload("res://scripts/tool_catalog.gd")
var owner_player: CharacterBody2D
var game: Node
var age := 0.0
var spent := false
var hit_damage: int = CATALOG.DATA[CATALOG.Type.SLINGSHOT]["damage"]

func _ready() -> void:
 add_to_group("carrot_projectiles")
 collision_layer = 8
 collision_mask = 1
 var shape := CollisionShape2D.new()
 var circle := CircleShape2D.new()
 circle.radius = 4
 shape.shape = circle
 add_child(shape)
 if is_instance_valid(owner_player): add_collision_exception_with(owner_player)

func _physics_process(delta: float) -> void:
 if spent: return
 if is_instance_valid(game) and (game.is_finished or not owner_player.controls_enabled): return
 age += delta
 var displacement := velocity*delta+Vector2(0,CATALOG.PROJECTILE_GRAVITY*0.5*delta*delta)
 velocity.y += CATALOG.PROJECTILE_GRAVITY*delta
 rotation = velocity.angle()+PI/2
 var collision := move_and_collide(displacement)
 if collision != null:
  spent = true
  var body = collision.get_collider()
  if is_instance_valid(body) and body.is_in_group("enemy") and body.alive:
   body.take_hit(hit_damage,global_position.x-velocity.x*0.01)
  queue_free()
 elif age > 4 or global_position.y > 1500: queue_free()
 queue_redraw()

func _draw() -> void:
 var texture := preload("res://scripts/prop_art.gd").texture("carrot")
 draw_texture_rect(texture,Rect2(-5,-9,10,18),false)

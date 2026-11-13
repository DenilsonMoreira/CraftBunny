extends Node2D
## Cosmetic only: at most three world-space snapshots and a short dust puff.
var ghosts: Array[Sprite2D] = []
var ghost_clock := 0.0
var dust_time := 0.0
var dust_origin := Vector2.ZERO
var dust_direction := 1

func _ready() -> void:
 show_behind_parent = true

func start_dash(grounded: bool) -> void:
 ghost_clock = 0.0
 if grounded:
  dust_time = 0.24
  dust_origin = get_parent().global_position+Vector2(0,18)
  dust_direction = get_parent().facing

func _physics_process(delta: float) -> void:
 var player = get_parent()
 if not player.controls_enabled or player.health <= 0:
  for ghost in ghosts: ghost.free()
  ghosts.clear()
  dust_time = 0.0
  queue_redraw()
  return
 for index in range(ghosts.size()-1,-1,-1):
  ghosts[index].modulate.a -= delta*2.0
  if ghosts[index].modulate.a <= 0.0:
   ghosts[index].free()
   ghosts.remove_at(index)
 if player.dash_timer > 0:
  ghost_clock -= delta
  if ghost_clock <= 0.0:
   ghost_clock = 0.05
   var source: AnimatedSprite2D = player.mobility_sprite
   if is_instance_valid(source):
    var ghost := Sprite2D.new()
    ghost.texture = source.sprite_frames.get_frame_texture(source.animation,source.frame)
    ghost.flip_h = source.flip_h
    ghost.modulate = Color(1.0,0.76,0.65,0.32)
    ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    # Same world layer: z=-1 would hide the trail behind the level backdrop.
    ghost.z_index = 0
    add_child(ghost)
    ghost.top_level = true
    ghost.global_transform = source.global_transform
    ghosts.append(ghost)
    if ghosts.size() > 3: ghosts.pop_front().free()
 dust_time = maxf(0.0,dust_time-delta)
 queue_redraw()

func _draw() -> void:
 if dust_time <= 0: return
 var age := 0.24-dust_time
 var origin := to_local(dust_origin)
 for index in range(6):
  var point := origin+Vector2(-dust_direction*(index*3+age*50),-sin(age*8)*float(2+index))
  draw_rect(Rect2(point.snapped(Vector2(2,2)),Vector2(4,4)),Color(0.77,0.61,0.39,dust_time/0.24*0.65))

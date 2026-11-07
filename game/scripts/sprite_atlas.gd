extends RefCounted
static var bounds_cache: Dictionary = {}

# Use alpha bounds and a shared scale: never stretch a pose to fit its collider.
static func create(path: String, actions: Dictionary, target_size: Vector2, feet_y: float, flying := false, grid := Vector2i(4,4), foot_anchors := PackedVector2Array()) -> AnimatedSprite2D:
 var texture := load(path) as Texture2D
 if texture == null: return null
 var cell := Vector2i(texture.get_width() / grid.x, texture.get_height() / grid.y)
 var bounds: Array[Rect2i] = []
 var maximum := Vector2.ZERO
 var cache_key := path+str(grid)
 if bounds_cache.has(cache_key):
  bounds.assign(bounds_cache[cache_key]["bounds"])
  maximum = bounds_cache[cache_key]["maximum"]
 else:
  var image := texture.get_image()
  for index in range(grid.x * grid.y):
   var rect := Rect2i(Vector2i(index % grid.x, index / grid.x) * cell, cell)
   var used := visible_bounds(image, rect)
   bounds.append(used)
   maximum.x = maxf(maximum.x, used.size.x)
   maximum.y = maxf(maximum.y, used.size.y)
  bounds_cache[cache_key] = {"bounds": bounds, "maximum": maximum}
 var factor := minf(target_size.x / maxf(maximum.x, 1), target_size.y / maxf(maximum.y, 1))
 var frames := SpriteFrames.new()
 frames.remove_animation("default")
 for action in actions:
  frames.add_animation(action)
  frames.set_animation_loop(action, action in ["idle", "walk", "run", "move"])
  frames.set_animation_speed(action, 10.0)
  for index in actions[action]:
   var used: Rect2i = bounds[index]
   var atlas := AtlasTexture.new()
   atlas.atlas = texture
   atlas.region = Rect2(used)
   var offset := Vector2((cell.x - used.size.x) / 2.0, (cell.y - used.size.y) / 2.0 if flying else cell.y - used.size.y)
   if foot_anchors.size() == grid.x * grid.y:
    # Authored sole anchors keep the body stable while a large weapon swings.
    var origin := Vector2i(index % grid.x, index / grid.x) * cell
    offset = Vector2(cell.x / 2.0, cell.y) + Vector2(used.position-origin) - foot_anchors[index]
   atlas.margin = Rect2(offset, Vector2(cell - used.size))
   frames.add_frame(action, atlas)
 var sprite := AnimatedSprite2D.new()
 sprite.sprite_frames = frames
 sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 sprite.scale = Vector2.ONE * factor
 sprite.position.y = 0.0 if flying else feet_y - cell.y * factor / 2.0
 sprite.play("idle")
 return sprite

static func visible_bounds(image: Image, region: Rect2i) -> Rect2i:
 var first := region.end
 var last := region.position
 for y in range(region.position.y, region.end.y):
  for x in range(region.position.x, region.end.x):
   if image.get_pixel(x, y).a < 0.65: continue
   first.x = mini(first.x, x)
   first.y = mini(first.y, y)
   last.x = maxi(last.x, x + 1)
   last.y = maxi(last.y, y + 1)
 return Rect2i(first, last-first) if last.x > first.x and last.y > first.y else region

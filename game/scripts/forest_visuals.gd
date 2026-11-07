extends Node2D

# Regions inspected in the official 1448 x 1086 reference.
const ART = preload("res://scripts/prop_art.gd")
const GROUND = preload("res://assets/production/tiles/forest_ground_v2.png")
const PIT = preload("res://assets/production/v2/forest_pit.png")
var grass: Texture2D
var bush: Texture2D
var rocks: Array[Array] = []
var ledges: Array[Array] = []
var spans: Array[Vector2] = []
var floor_y := 435.0

func build(ground: Array[Vector2], obstacles: Array[Array], platforms: Array[Array], surface_y: float) -> void:
 spans = ground
 rocks = obstacles
 ledges = platforms
 floor_y = surface_y
 grass = ART.texture("grass")
 bush = ART.texture("bush")
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 var tiles := TileSet.new()
 var tile_size := Vector2i(GROUND.get_width(), GROUND.get_height())
 tiles.tile_size = tile_size
 var source := TileSetAtlasSource.new()
 source.texture = GROUND
 source.texture_region_size = tile_size
 source.create_tile(Vector2i.ZERO)
 tiles.add_source(source, 0)
 for span in spans:
  var count := ceili((span.y - span.x) / 128.0)
  var layer := TileMapLayer.new()
  layer.tile_set = tiles
  layer.collision_enabled = false
  layer.position = Vector2(span.x, floor_y)
  layer.scale = Vector2((span.y - span.x) / float(count * tile_size.x), 140.0 / tile_size.y)
  for column in range(count):
   # Alternating reflection makes both sides of each seam sample the same edge.
   layer.set_cell(Vector2i(column, 0), 0, Vector2i.ZERO, TileSetAtlasSource.TRANSFORM_FLIP_H if column % 2 else 0)
  add_child(layer)
 queue_redraw()

func _draw() -> void:
 for index in range(spans.size()-1):
  var left := spans[index].y
  var right := spans[index+1].x
  if right > left:
   draw_texture_rect(PIT, Rect2(left, floor_y, right-left, 440), false)
 var full_ground := Rect2(Vector2.ZERO, GROUND.get_size())
 for span in spans:
  # Continue the earth below the surface; no sky-colored holes under the floor.
  var count := ceili((span.y-span.x) / 128.0)
  var width := (span.y-span.x) / count
  for row in range(3):
   for column in range(count):
    var flip := column % 2 != 0
    draw_set_transform(Vector2(span.x + column*width + (width if flip else 0.0), floor_y+139+row*100), 0.0, Vector2(-1 if flip else 1,1))
    draw_texture_rect_region(GROUND, Rect2(0,0,width,101), Rect2(0,200,GROUND.get_width(),GROUND.get_height()-200))
  draw_set_transform(Vector2.ZERO)
 for rock in rocks:
  draw_texture_rect_region(GROUND, Rect2(rock[0]-rock[2]/2.0, rock[1]-rock[3]/2.0, rock[2], rock[3]), full_ground)
 for ledge in ledges:
  draw_texture_rect_region(GROUND, Rect2(ledge[0]-ledge[2]/2.0, ledge[1]-10, ledge[2], 20), full_ground)
 # Decorative props stand on the surface, without collision or covering gaps.
 for span in spans:
  for x in range(int(span.x)+60, int(span.y)-40, 180):
   var texture: Texture2D = grass if x % 360 < 180 else bush
   var size: Vector2 = ART.fit(texture, Vector2(24,10) if texture == grass else Vector2(30,14))
   draw_texture_rect(texture, Rect2(x, floor_y-size.y, size.x, size.y), false)

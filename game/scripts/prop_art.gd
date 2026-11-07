extends RefCounted

const FOLIAGE = preload("res://assets/production/v2/forest_props.png")
const ITEMS = preload("res://assets/production/v2/collectibles.png")
const CRATES = preload("res://assets/production/v2/crate_states.png")
const HEARTS = preload("res://assets/production/v2/hearts.png")
const CLOUDS = preload("res://assets/production/v2/clouds.png")
static var cache: Dictionary = {}

static func texture(kind: String) -> Texture2D:
 if cache.has(kind): return cache[kind]
 var sheet: Texture2D = ITEMS if kind in ["carrot", "wood"] else FOLIAGE
 if kind in ["crate", "crate_damaged"]: sheet = CRATES
 if kind in ["heart", "heart_empty"]: sheet = HEARTS
 if kind in ["cloud", "cloud_small"]: sheet = CLOUDS
 var width := sheet.get_width()
 var height := sheet.get_height()
 # The generated foliage has a tall tree band and a separate low foliage band.
 var regions := {
  "tree": Rect2i(0, 0, width/2, int(height*0.66)),
  "pine": Rect2i(width/2, 0, width-width/2, int(height*0.66)),
  "grass": Rect2i(0, int(height*0.72), width/2, height-int(height*0.72)),
  "bush": Rect2i(width/2, int(height*0.72), width-width/2, height-int(height*0.72)),
  "carrot": Rect2i(0, 0, width/2, height),
  "wood": Rect2i(width/2, 0, width-width/2, height),
  "crate": Rect2i(0,0,width/2,height),
  "crate_damaged": Rect2i(width/2,0,width-width/2,height),
  "heart": Rect2i(0,0,width/2,height),
  "heart_empty": Rect2i(width/2,0,width-width/2,height),
  "cloud": Rect2i(0,0,width/2,height),
  "cloud_small": Rect2i(width/2,0,width-width/2,height)
 }
 var atlas := AtlasTexture.new()
 atlas.atlas = sheet
 atlas.region = Rect2(preload("res://scripts/sprite_atlas.gd").visible_bounds(sheet.get_image(), regions[kind]))
 cache[kind] = atlas
 return atlas

static func fit(texture: Texture2D, size: Vector2) -> Vector2:
 return texture.get_size() * minf(size.x / texture.get_width(), size.y / texture.get_height())

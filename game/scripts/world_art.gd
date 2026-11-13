extends RefCounted
const TREE = preload("res://assets/production/v4/tree_kit.png")
const ROCK = preload("res://assets/production/v4/rock_states.png")
static var cache: Dictionary = {}
static func texture(kind: String, index: int) -> Texture2D:
 var key := kind+str(index)
 if cache.has(key): return cache[key]
 var sheet: Texture2D = TREE if kind=="tree" else ROCK
 var grid := Vector2i(4,2) if kind=="tree" else Vector2i(2,2)
 var cell := Vector2i(sheet.get_width()/grid.x,sheet.get_height()/grid.y)
 var bounds := preload("res://scripts/sprite_atlas.gd").visible_bounds(sheet.get_image(),Rect2i(Vector2i(index%grid.x,index/grid.x)*cell,cell))
 var atlas := AtlasTexture.new()
 atlas.atlas = sheet
 atlas.region = Rect2(bounds)
 cache[key] = atlas
 return atlas

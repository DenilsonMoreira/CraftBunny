extends RefCounted
const SOURCE := "res://assets/production/v4/equipment.png"
const GRIPS := [Vector2(.48,.80),Vector2(.22,.80),Vector2(.5,.82),Vector2(.5,.82)]
static var cache: Dictionary = {}
static func texture(tool: int) -> Texture2D:
 if cache.has(tool): return cache[tool]
 var sheet := load(SOURCE) as Texture2D
 if sheet==null: return null
 var cell := Vector2i(sheet.get_width()/2,sheet.get_height()/2)
 var region := Rect2i(Vector2i(tool%2,tool/2)*cell,cell)
 var atlas := AtlasTexture.new()
 atlas.atlas = sheet
 atlas.region = Rect2(preload("res://scripts/sprite_atlas.gd").visible_bounds(sheet.get_image(),region))
 cache[tool] = atlas
 return atlas

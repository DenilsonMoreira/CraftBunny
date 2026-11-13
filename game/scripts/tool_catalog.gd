extends RefCounted
enum Type {HAMMER, AXE, PICKAXE, SLINGSHOT}
const NAMES := ["Martelo","Machado","Picareta","Estilingue"]
const KEYS := ["hammer","axe","pickaxe","slingshot"]
const DATA := [
 {"damage":1,"windup":0.0,"active":0.12,"total":0.35},
 {"damage":2,"windup":0.10,"active":0.12,"total":0.55},
 {"damage":3,"windup":0.30,"active":0.20,"total":1.00},
 {"damage":3,"windup":0.0,"active":0.0,"total":0.35}
]
const SWITCH_DURATION := 0.24
const PROJECTILE_SPEED := Vector2(390,-230)
const PROJECTILE_GRAVITY := 900.0
const ANIMATION_FRAMES := 12
const STATES := ["idle","run","jump","fall","attack","dash","switch","glide"]

static func animation_names() -> PackedStringArray:
 var names := PackedStringArray()
 for tool in KEYS:
  for state in STATES: names.append(tool+"/"+state)
 return names

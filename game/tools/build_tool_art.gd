extends SceneTree
const FACTORY = preload("res://scripts/sprite_atlas.gd")
const TOOLS = preload("res://scripts/tool_catalog.gd")
const RIG = preload("res://scripts/equipment_rig.gd")
const ROOT := "res://assets/production/v4/"
const BODY := ["idle","run","jump","fall","dash","glide","switch"]
const SOCKETS := {"idle":Vector2(12,7),"run":Vector2(14,7),"jump":Vector2(13,7),"fall":Vector2(13,7),"dash":Vector2(19,9),"glide":Vector2(-10,10),"switch":Vector2(12,7)}
var output: SpriteFrames
var layouts: Dictionary = {}
var reference_height := 53.172413793
func _initialize() -> void: call_deferred("_run")

func foot_anchors(texture: Texture2D) -> PackedVector2Array:
 var image := texture.get_image()
 var cell := Vector2i(image.get_width()/4,image.get_height()/3)
 var anchors := PackedVector2Array()
 for index in range(12):
  var origin := Vector2i(index%4,index/4)*cell
  var bottom := -1
  var left := cell.x
  var right := 0
  for y in range(int(cell.y*.55),cell.y):
   for x in range(int(cell.x*.16),int(cell.x*.84)):
    var c := image.get_pixelv(origin+Vector2i(x,y))
    # Cream feet, not the metal/wood of a lowered weapon, define the pivot.
    if c.a>.65 and c.r>.74 and c.g>.58 and c.b>.44 and c.r>=c.g and c.g>=c.b and c.g-c.b<.24:
     if y>bottom:
      bottom = y
      left = x
      right = x
     elif y==bottom:
      left = mini(left,x)
      right = maxi(right,x)
  if bottom<0:
   var box := FACTORY.visible_bounds(image,Rect2i(origin,cell))
   anchors.append(Vector2(cell.x*.5,box.end.y-origin.y))
  else:
   left = cell.x
   right = 0
   for y in range(maxi(int(cell.y*.55),bottom-7),bottom+1):
    for x in range(int(cell.x*.16),int(cell.x*.84)):
     var c := image.get_pixelv(origin+Vector2i(x,y))
     if c.a>.65 and c.r>.74 and c.g>.58 and c.b>.44 and c.r>=c.g and c.g>=c.b and c.g-c.b<.24:
      left = mini(left,x)
      right = maxi(right,x)
   anchors.append(Vector2((left+right)*.5,mini(cell.y-1,bottom+3)))
 return anchors

func make_sheet(file: String, body_only: bool) -> AnimatedSprite2D:
 var path := ROOT+file+".png"
 var texture := load(path) as Texture2D
 assert(texture!=null,"Missing generated sheet: "+path)
 var sprite := FACTORY.create(path,{"idle":[0],"poses":range(12)},Vector2(1000,1000),21,false,Vector2i(4,3),foot_anchors(texture),reference_height)
 if body_only:
  var maximum := 0.0
  for index in range(12):
   var frame := sprite.sprite_frames.get_frame_texture("poses",index) as AtlasTexture
   maximum = maxf(maximum,frame.region.size.y*sprite.scale.y)
  if maximum>56:
   var ratio := 56/maximum
   sprite.scale *= ratio
   sprite.position = Vector2(0,21)+(sprite.position-Vector2(0,21))*ratio
 return sprite

func add_sequence(key: String, sprite: AnimatedSprite2D, source: String, layered: bool, state: String) -> void:
 output.add_animation(key)
 output.set_animation_loop(key,state in ["idle","run","glide"])
 output.set_animation_speed(key,20)
 for index in range(12): output.add_frame(key,sprite.sprite_frames.get_frame_texture(source,index))
 layouts[key] = {"scale":sprite.scale,"position":sprite.position,"layered":layered,"socket":SOCKETS.get(state,Vector2(12,7))}
 if layered:
  var points := PackedVector2Array()
  var angles := PackedFloat32Array()
  for index in range(12):
   var frame := sprite.sprite_frames.get_frame_texture(source,index) as AtlasTexture
   var cell := Vector2i(frame.atlas.get_width()/4,frame.atlas.get_height()/3)
   var source_point: Vector2 = RIG.HANDS[state][index]+Vector2(Vector2i(index%4,index/4)*cell)
   var on_canvas := frame.margin.position+source_point-frame.region.position
   points.append(sprite.position+(on_canvas-frame.get_size()/2)*sprite.scale)
   angles.append(RIG.angle(state,index))
  layouts[key]["attachments"] = points
  layouts[key]["angles"] = angles
  layouts[key]["stowed"] = state=="glide"

func _run() -> void:
 var normal := FACTORY.create("res://assets/production/v2/bunny.png",{"idle":[0]},Vector2(48,60),21)
 var pose := normal.sprite_frames.get_frame_texture("idle",0) as AtlasTexture
 reference_height = pose.region.size.y*normal.scale.y
 normal.free()
 output = SpriteFrames.new()
 output.remove_animation("default")
 for state in BODY:
  # The opened scarf extends above the body; never shrink the rabbit to fit it.
  var sheet := make_sheet("body_glide_wing" if state=="glide" else "body_"+state,state!="glide")
  for tool in TOOLS.KEYS: add_sequence(tool+"/"+state,sheet,"poses",true,state)
  sheet.free()
 for tool in ["axe","pickaxe","slingshot"]:
  var sheet := make_sheet("attack_"+tool,false)
  add_sequence(tool+"/attack",sheet,"poses",false,"attack")
  sheet.free()
 var aim := make_sheet("aim_slingshot",false)
 add_sequence("slingshot/aim",aim,"poses",false,"aim")
 aim.free()
 var hammer := FACTORY.create("res://assets/production/v2/bunny_attack_12.png",{"idle":[0],"attack":range(12)},Vector2(88,60),21,false,Vector2i(4,3),PackedVector2Array([
  Vector2(171,326),Vector2(170,326),Vector2(179,327),Vector2(184,328),Vector2(184,327),Vector2(180,327),
  Vector2(119,327),Vector2(107,327),Vector2(118,327),Vector2(122,328),Vector2(140,329),Vector2(160,330)]))
 add_sequence("hammer/attack",hammer,"attack",false,"attack")
 hammer.free()
 output.set_meta("layout",layouts)
 output.set_meta("reference_height",reference_height)
 output.set_meta("art_version","v4")
 output.set_meta("equipment_rig_version",2)
 assert(output.get_animation_names().size()==33)
 assert(ResourceSaver.save(output,ROOT+"tool_frames.tres")==OK)
 print("FINAL_TOOL_ANIMATIONS=",output.get_animation_names().size()," FRAMES_PER_ANIMATION=12")
 quit(0)

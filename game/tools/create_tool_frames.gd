extends SceneTree
func _initialize() -> void:
 var path := "res://assets/production/tools/tool_frames_template.tres"
 if FileAccess.file_exists(path):
  push_error("Refusing to overwrite animation template.")
  quit(1)
  return
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/production/tools"))
 var frames := SpriteFrames.new()
 frames.remove_animation("default")
 for key in preload("res://scripts/tool_catalog.gd").animation_names():
  frames.add_animation(key)
  frames.set_animation_loop(key,key.ends_with("/idle") or key.ends_with("/run") or key.ends_with("/glide"))
  frames.set_animation_speed(key,12)
 assert(ResourceSaver.save(frames,path)==OK)
 print("TOOL_ANIMATION_SLOTS=",frames.get_animation_names().size())
 quit(0)

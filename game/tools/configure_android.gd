extends SceneTree

func _initialize() -> void:
 call_deferred("_configure")

func _configure() -> void:
 var cache := OS.get_environment("LOCALAPPDATA").path_join("CraftBunnyAndroid")
 var java_path := ""
 for folder in DirAccess.get_directories_at(cache):
  if folder.begins_with("jdk-17"): java_path = cache.path_join(folder)
 if java_path.is_empty():
  push_error("JDK 17 not installed")
  quit(1)
  return
 var config_path := OS.get_config_dir().path_join("Godot/editor_settings-4.7.tres")
 var settings = load(config_path)
 if settings == null:
  push_error("Editor settings not found")
  quit(1)
  return
 settings.set_setting("export/android/java_sdk_path", java_path)
 settings.set_setting("export/android/android_sdk_path", cache.path_join("android-sdk"))
 var error := ResourceSaver.save(settings,config_path)
 if error != OK:
  push_error("Cannot save Android SDK paths")
  quit(1)
  return
 var cfg := ConfigFile.new()
 cfg.load("res://export_presets.cfg")
 cfg.set_value("preset.1.options","custom_template/debug",cache.path_join("android_debug.apk"))
 cfg.set_value("preset.1.options","custom_template/release",cache.path_join("android_release.apk"))
 cfg.set_value("preset.1.options","keystore/debug",cache.path_join("debug.keystore"))
 cfg.set_value("preset.1.options","keystore/debug_user","androiddebugkey")
 cfg.set_value("preset.1.options","keystore/debug_password","android")
 error = cfg.save("res://export_presets.cfg")
 print("ANDROID_CONFIG=",error)
 await process_frame
 var filesystem = EditorInterface.get_resource_filesystem()
 if filesystem != null:
  while filesystem.is_scanning(): await process_frame
 quit(0 if error == OK else 1)

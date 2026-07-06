extends Node

const MOD_TAG := "[NARK's Flannels]"
const LOG_PATH := "user://nark_flannel_pack_log.txt"

const ITEMS := [
	{
		"id": "NARK_Flannel_Red",
		"name": "Red Flannel",
		"short_name": "Flannel",
		"weight": 2.1,
		"value": 180,
		"rarity": 2,
		"capacity": 6,
		"insulation": 39,
		"size": [
			2,
			2
		],
		"civilian": true,
		"military": false,
		"traders": [
			"Generalist",
			"Gunsmith"
		],
		"loot_tables": [
			"LT_Master"
		],
		"item_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Red/NARK_Flannel_Red.tres",
		"scene_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Red/NARK_Flannel_Red.tscn",
		"icon_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Red/Files/Icon_NARK_Flannel_Red.png",
		"world_texture_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Red/Files/TX_NARK_Flannel_Red_AL.png",
		"sleeves_texture_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Red/Files/TX_NARK_Flannel_Red_Sleeves_AL.png"
	},
	{
		"id": "NARK_Flannel_Blue",
		"name": "Blue Flannel",
		"short_name": "Flannel",
		"weight": 2.1,
		"value": 180,
		"rarity": 2,
		"capacity": 6,
		"insulation": 39,
		"size": [
			2,
			2
		],
		"civilian": true,
		"military": false,
		"traders": [
			"Generalist",
			"Gunsmith"
		],
		"loot_tables": [
			"LT_Master"
		],
		"item_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Blue/NARK_Flannel_Blue.tres",
		"scene_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Blue/NARK_Flannel_Blue.tscn",
		"icon_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Blue/Files/Icon_NARK_Flannel_Blue.png",
		"world_texture_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Blue/Files/TX_NARK_Flannel_Blue_AL.png",
		"sleeves_texture_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Blue/Files/TX_NARK_Flannel_Blue_Sleeves_AL.png"
	},
	{
		"id": "NARK_Flannel_Black",
		"name": "Black Flannel",
		"short_name": "Flannel",
		"weight": 2.1,
		"value": 180,
		"rarity": 2,
		"capacity": 6,
		"insulation": 39,
		"size": [
			2,
			2
		],
		"civilian": true,
		"military": false,
		"traders": [
			"Generalist",
			"Gunsmith"
		],
		"loot_tables": [
			"LT_Master"
		],
		"item_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Black/NARK_Flannel_Black.tres",
		"scene_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Black/NARK_Flannel_Black.tscn",
		"icon_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Black/Files/Icon_NARK_Flannel_Black.png",
		"world_texture_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Black/Files/TX_NARK_Flannel_Black_AL.png",
		"sleeves_texture_path": "res://NARK_Flannel_Pack/Items/Clothing/NARK_Flannel_Black/Files/TX_NARK_Flannel_Black_Sleeves_AL.png"
	}
]

var _log_lines: Array[String] = []
var _registered := false


func _ready() -> void:
	name = "NARK_Flannel_Pack"
	_log("autoload loaded")
	call_deferred("_register_mod_content")


func _log(message: String) -> void:
	var line := MOD_TAG + " " + message
	print(line)
	_log_lines.append(line)

	var file := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if file == null:
		return

	for log_line in _log_lines:
		file.store_line(log_line)

	file.close()


func _register_mod_content() -> void:
	if _registered:
		return

	_log("register start")
	_log("Godot user data folder: " + OS.get_user_data_dir())

	if not Engine.has_meta("RTVModLib"):
		_log("ERROR: RTVModLib not found")
		return

	var lib = Engine.get_meta("RTVModLib")

	if not bool(lib.get("_is_ready")):
		_log("waiting for RTVModLib")
		await lib.frameworks_ready

	_log("RTVModLib ready")

	for cfg in ITEMS:
		_register_clothing_item(lib, cfg)

	_registered = true
	_log("finished all registration")


func _register_clothing_item(lib, cfg: Dictionary) -> void:
	var item_id := str(cfg.get("id", ""))
	if item_id == "":
		_log("ERROR: skipped item with empty id")
		return

	_log("registering item: " + item_id)

	var item_data = _safe_load(str(cfg.get("item_path", "")))
	var item_scene = _safe_load(str(cfg.get("scene_path", "")))

	if item_data == null:
		_log("ERROR: item data failed to load for " + item_id)
		return

	if item_scene == null:
		_log("ERROR: item scene failed to load for " + item_id)
		return

	var icon = _load_png_texture(str(cfg.get("icon_path", "")))
	var world_tex = _load_png_texture(str(cfg.get("world_texture_path", "")))
	var sleeves_tex = _load_png_texture(str(cfg.get("sleeves_texture_path", "")))

	_log("icon loaded for " + item_id + ": " + str(icon != null))
	_log("world texture loaded for " + item_id + ": " + str(world_tex != null))
	_log("sleeves texture loaded for " + item_id + ": " + str(sleeves_tex != null))

	var world_mat = _make_standard_material(world_tex, false)
	var sleeves_mat = _make_standard_material(sleeves_tex, true)

	_apply_item_values(item_data, cfg, icon, sleeves_mat)

	if icon != null:
		item_data.set("tetris", _make_tetris_scene(str(cfg.get("id", item_id)), icon, int(cfg.get("size", [2,2])[0]), int(cfg.get("size", [2,2])[1])))

	if world_mat != null and item_scene is PackedScene:
		item_scene = _patch_pickup_scene(item_scene, world_mat)

	var item_ok := bool(lib.register(lib.Registry.ITEMS, item_id, item_data))
	_log("register ITEMS " + item_id + ": " + str(item_ok))

	var scene_ok := bool(lib.register(lib.Registry.SCENES, item_id, item_scene))
	_log("register SCENES " + item_id + ": " + str(scene_ok))

	for table in cfg.get("loot_tables", []):
		var loot_key := item_id + "_" + str(table)
		var loot_ok := bool(lib.register(lib.Registry.LOOT, loot_key, {
			"item": item_data,
			"table": str(table)
		}))
		_log("register LOOT " + loot_key + ": " + str(loot_ok))

	for trader in cfg.get("traders", []):
		var trader_name := str(trader)
		var trader_key := item_id + "_" + trader_name
		var trader_ok := bool(lib.register(lib.Registry.TRADER_POOLS, trader_key, {
			"item": item_data,
			"trader": trader_name
		}))
		_log("register TRADER_POOLS " + trader_key + ": " + str(trader_ok))

	var confirmed = lib.get_entry(lib.Registry.ITEMS, item_id)
	_log("confirmed item in registry " + item_id + ": " + str(confirmed != null))


func _apply_item_values(item_data, cfg: Dictionary, icon, sleeves_mat) -> void:
	item_data.set("file", str(cfg.get("id", "")))
	item_data.set("name", str(cfg.get("name", "")))
	item_data.set("inventory", str(cfg.get("short_name", "")))
	item_data.set("rotated", str(cfg.get("short_name", "")))
	item_data.set("equipment", str(cfg.get("short_name", "")))
	item_data.set("display", str(cfg.get("short_name", "")))
	item_data.set("type", "Clothing")
	item_data.set("weight", float(cfg.get("weight", 0.0)))
	item_data.set("value", int(cfg.get("value", 0)))
	item_data.set("rarity", int(cfg.get("rarity", 0)))
	item_data.set("capacity", float(cfg.get("capacity", 0.0)))
	item_data.set("insulation", float(cfg.get("insulation", 0.0)))
	item_data.set("slots", ["Torso"])
	item_data.set("civilian", bool(cfg.get("civilian", false)))
	item_data.set("military", bool(cfg.get("military", false)))

	for trader in cfg.get("traders", []):
		var prop := str(trader).to_lower()
		item_data.set(prop, true)

	if icon != null:
		item_data.set("icon", icon)

	if sleeves_mat != null:
		item_data.set("material", sleeves_mat)

	var size_arr = cfg.get("size", [2, 2])
	item_data.set("size", Vector2(int(size_arr[0]), int(size_arr[1])))


func _safe_load(path: String):
	_log("trying load: " + path)

	if ResourceLoader.exists(path):
		var res = ResourceLoader.load(path)
		_log("ResourceLoader.exists true: " + path + " / loaded=" + str(res != null))
		return res

	if FileAccess.file_exists(path):
		var res2 = load(path)
		_log("FileAccess.exists true: " + path + " / loaded=" + str(res2 != null))
		return res2

	_log("path missing: " + path)
	return null


func _load_png_texture(path: String) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		return null

	var image := Image.new()
	var err := image.load(path)

	if err != OK:
		_log("ERROR: image.load failed for " + path + " err=" + str(err))
		return null

	return ImageTexture.create_from_image(image)


func _make_standard_material(albedo: Texture2D, sleeves: bool) -> Material:
	if albedo == null:
		return null

	var shader = ResourceLoader.load("res://Shaders/Standard.gdshader")
	var material := ShaderMaterial.new()

	if shader != null:
		material.shader = shader

	material.set_shader_parameter("albedo", albedo)
	material.set_shader_parameter("normal", ResourceLoader.load("res://Items/0 - Shared/TX_Fleece_Tactical_Sleeves_NR.png") if sleeves else null)
	material.set_shader_parameter("tint", Color(1, 1, 1, 1))
	material.set_shader_parameter("limiter", 0.0 if sleeves else 0.1)
	material.set_shader_parameter("dynamic", true if sleeves else false)
	material.set_shader_parameter("fractional", false)
	material.set_shader_parameter("enableRain", true if sleeves else false)
	material.set_shader_parameter("enableSnow", false)
	material.set_shader_parameter("snowTop", 0.0)
	material.set_shader_parameter("snowSide", 0.0)
	material.set_shader_parameter("snowBottom", 0.0)
	material.set_shader_parameter("occlusion", false)
	material.set_shader_parameter("noise", false)
	material.set_shader_parameter("metal", false)
	material.set_shader_parameter("super", false)
	material.set_shader_parameter("glow", false)
	material.set_shader_parameter("viewmodel", false)
	material.set_shader_parameter("fresnel", 0.5)

	return material


func _patch_pickup_scene(scene: PackedScene, material: Material) -> PackedScene:
	var instance = scene.instantiate()

	if instance == null:
		return scene

	var mesh_node = instance.get_node_or_null("Mesh") as MeshInstance3D

	if mesh_node != null:
		mesh_node.material_override = material
		if mesh_node.mesh != null:
			for i in range(mesh_node.mesh.get_surface_count()):
				mesh_node.set_surface_override_material(i, material)

	var packed := PackedScene.new()
	return packed if packed.pack(instance) == OK else scene


func _make_tetris_scene(item_id: String, icon: Texture2D, size_x: int, size_y: int) -> PackedScene:
	var sprite := Sprite2D.new()
	sprite.name = item_id
	sprite.texture = icon
	sprite.material = ResourceLoader.load("res://UI/Effects/MT_Item.tres")
	sprite.position = Vector2(64.0 * max(size_x, 1), 64.0 * max(size_y, 1)) / 2.0
	sprite.scale = Vector2(0.5, 0.5)

	var packed := PackedScene.new()
	packed.pack(sprite)
	return packed

extends RefCounted

const SAVE_PATH := "user://kopalnia_save.json"
const SAVE_VERSION := 1
const FLOOR_COUNT := 30
const MAX_BALANCE := 9000000000000

func default_state() -> Dictionary:
	var levels: Array[int] = []
	var completed: Array[bool] = []
	for _i in range(FLOOR_COUNT):
		levels.append(0)
		completed.append(false)
	return {
		"save_version": SAVE_VERSION,
		"coins": 50,
		"crystals": 0,
		"chests": 0,
		"miners": {"helper": 1, "miner": 0, "drill": 0},
		"global_upgrades": {"power": 0, "speed": 0, "value": 0, "crystal": 0},
		"floor_upgrade_levels": levels,
		"floor_completed": completed,
		"unlocked_floor": 0,
		"current_floor": 0,
		"blocks_remaining": 8,
		"block_health_remaining": 80.0
	}

func normalize_state(raw: Dictionary) -> Dictionary:
	var result := default_state()
	result["coins"] = _safe_int(raw.get("coins", 50), 50, 0, MAX_BALANCE)
	result["crystals"] = _safe_int(raw.get("crystals", 0), 0, 0, MAX_BALANCE)
	result["chests"] = _safe_int(raw.get("chests", 0), 0, 0, MAX_BALANCE)

	var raw_miners: Variant = raw.get("miners", {})
	if raw_miners is Dictionary:
		var miners: Dictionary = result["miners"]
		for miner_id in miners.keys():
			miners[miner_id] = _safe_int(raw_miners.get(miner_id, miners[miner_id]), miners[miner_id], 0, 1000000)
		result["miners"] = miners

	var raw_upgrades: Variant = raw.get("global_upgrades", {})
	if raw_upgrades is Dictionary:
		var upgrades: Dictionary = result["global_upgrades"]
		for upgrade_id in upgrades.keys():
			upgrades[upgrade_id] = _safe_int(raw_upgrades.get(upgrade_id, 0), 0, 0, 100)
		result["global_upgrades"] = upgrades

	var raw_levels: Variant = raw.get("floor_upgrade_levels", [])
	if raw_levels is Array:
		var levels: Array[int] = []
		for i in range(FLOOR_COUNT):
			var value: Variant = raw_levels[i] if i < raw_levels.size() else 0
			levels.append(_safe_int(value, 0, 0, 800))
		result["floor_upgrade_levels"] = levels

	var raw_completed: Variant = raw.get("floor_completed", [])
	if raw_completed is Array:
		var completed: Array[bool] = []
		for i in range(FLOOR_COUNT):
			var value: Variant = raw_completed[i] if i < raw_completed.size() else false
			completed.append(value == true)
		result["floor_completed"] = completed

	var unlocked := _safe_int(raw.get("unlocked_floor", 0), 0, 0, FLOOR_COUNT - 1)
	result["unlocked_floor"] = unlocked
	result["current_floor"] = _safe_int(raw.get("current_floor", 0), 0, 0, unlocked)
	result["blocks_remaining"] = _safe_int(raw.get("blocks_remaining", 8), 8, 0, 10000)
	var health_value: Variant = raw.get("block_health_remaining", 80.0)
	if health_value is int or health_value is float:
		result["block_health_remaining"] = clampf(float(health_value), 0.0, 1.0e15)
	return result

func save_state(state: Dictionary) -> bool:
	var normalized := normalize_state(state)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(normalized))
	file.close()
	return FileAccess.get_open_error() == OK

func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_state()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return default_state()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		return normalize_state(parsed)
	return default_state()

func _safe_int(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not (value is int or value is float):
		return fallback
	return clampi(int(value), minimum, maximum)

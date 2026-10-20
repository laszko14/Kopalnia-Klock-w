extends Node

signal changed

const FLOOR_COUNT := 30
const FloorCatalogScript = preload("res://scripts/floor_catalog.gd")
const GameRulesScript = preload("res://scripts/game_rules.gd")
const SaveManagerScript = preload("res://scripts/save_manager.gd")

var coins: int = 50
var crystals: int = 0
var chests: int = 0
var miners: Dictionary = {"helper": 1, "miner": 0, "drill": 0}
var global_upgrades: Dictionary = {"power": 0, "speed": 0, "value": 0, "crystal": 0}
var floor_upgrade_levels: Array[int] = []
var floor_completed: Array[bool] = []
var unlocked_floor: int = 0
var current_floor: int = 0
var blocks_remaining: int = 0
var block_health_remaining: float = 0.0
var _rng := RandomNumberGenerator.new()
var _catalog = FloorCatalogScript.new()
var _autosave_elapsed := 0.0

func _init() -> void:
	_rng.randomize()
	reset_game()

func _ready() -> void:
	var manager = SaveManagerScript.new()
	load_from_save(manager.load_state())

func _process(delta: float) -> void:
	_autosave_elapsed += delta
	if _autosave_elapsed >= 10.0:
		_autosave_elapsed = 0.0
		save_progress()

func _exit_tree() -> void:
	save_progress()

func reset_game() -> void:
	coins = 50
	crystals = 0
	chests = 0
	miners = {"helper": 1, "miner": 0, "drill": 0}
	global_upgrades = {"power": 0, "speed": 0, "value": 0, "crystal": 0}
	floor_upgrade_levels = []
	floor_completed = []
	for _i in range(FLOOR_COUNT):
		floor_upgrade_levels.append(0)
		floor_completed.append(false)
	unlocked_floor = 0
	current_floor = 0
	_load_floor(0)
	emit_signal("changed")

func _load_floor(floor_index: int) -> void:
	current_floor = clampi(floor_index, 0, FLOOR_COUNT - 1)
	var data: Dictionary = _catalog.floor_data(current_floor)
	if floor_completed[current_floor]:
		blocks_remaining = 0
		block_health_remaining = 0.0
	else:
		blocks_remaining = int(data.get("block_count", 8))
		block_health_remaining = float(data.get("health", 80.0))

func select_floor(floor_index: int) -> bool:
	if floor_index < 0 or floor_index >= FLOOR_COUNT or floor_index > unlocked_floor:
		return false
	_load_floor(floor_index)
	emit_signal("changed")
	return true

func get_floor_upgrade_cost(floor_index: int) -> int:
	if floor_index < 0 or floor_index >= FLOOR_COUNT:
		return 0
	return GameRulesScript.floor_upgrade_cost(floor_upgrade_levels[floor_index])

func buy_floor_upgrade(floor_index: int) -> bool:
	if floor_index < 0 or floor_index >= FLOOR_COUNT or floor_index > unlocked_floor:
		return false
	var level: int = floor_upgrade_levels[floor_index]
	if level >= 800:
		return false
	var cost := GameRulesScript.floor_upgrade_cost(level)
	if coins < cost:
		return false
	coins -= cost
	floor_upgrade_levels[floor_index] = level + 1
	save_progress()
	emit_signal("changed")
	return true

func get_miner_cost(miner_id: String) -> int:
	return GameRulesScript.miner_cost(miner_id, int(miners.get(miner_id, -1)))

func buy_miner(miner_id: String) -> bool:
	if not miners.has(miner_id):
		return false
	var cost := get_miner_cost(miner_id)
	if cost <= 0 or coins < cost:
		return false
	coins -= cost
	miners[miner_id] = int(miners[miner_id]) + 1
	save_progress()
	emit_signal("changed")
	return true

func get_global_upgrade_cost(upgrade_id: String) -> int:
	if not global_upgrades.has(upgrade_id):
		return 0
	return GameRulesScript.global_upgrade_cost(upgrade_id, int(global_upgrades[upgrade_id]))

func buy_global_upgrade(upgrade_id: String) -> bool:
	if not global_upgrades.has(upgrade_id):
		return false
	var level: int = int(global_upgrades[upgrade_id])
	if level >= GameRulesScript.GLOBAL_UPGRADE_CAP:
		return false
	var cost := get_global_upgrade_cost(upgrade_id)
	if cost <= 0 or coins < cost:
		return false
	coins -= cost
	global_upgrades[upgrade_id] = level + 1
	save_progress()
	emit_signal("changed")
	return true

func attack_interval() -> float:
	return GameRulesScript.attack_interval(int(global_upgrades.get("speed", 0)))

func mining_power() -> float:
	var base_damage := int(miners.get("helper", 0)) + int(miners.get("miner", 0)) * 5 + int(miners.get("drill", 0)) * 18
	var power_multiplier := GameRulesScript.global_upgrade_multiplier("power", int(global_upgrades.get("power", 0)))
	var floor_multiplier := GameRulesScript.floor_upgrade_multiplier(floor_upgrade_levels[current_floor])
	return maxf(0.0, float(base_damage) * power_multiplier * floor_multiplier)

func apply_miner_hit() -> Dictionary:
	if floor_completed[current_floor] or blocks_remaining <= 0:
		return {"destroyed": false, "damage": 0.0}
	var damage := mining_power()
	block_health_remaining = maxf(0.0, block_health_remaining - damage)
	if block_health_remaining <= 0.0:
		var reward := complete_block()
		reward["damage"] = damage
		return reward
	return {"destroyed": false, "damage": damage}

func complete_block() -> Dictionary:
	if current_floor < 0 or current_floor >= FLOOR_COUNT or floor_completed[current_floor] or blocks_remaining <= 0 or block_health_remaining > 0.0:
		return {"destroyed": false}
	var finished_floor := current_floor
	var data: Dictionary = _catalog.floor_data(finished_floor)
	var payout_multiplier := GameRulesScript.global_upgrade_multiplier("value", int(global_upgrades.get("value", 0)))
	var coin_reward := maxi(1, roundi(float(data.get("reward", 10)) * payout_multiplier))
	coins = mini(coins + coin_reward, SaveManagerScript.MAX_BALANCE)
	var crystal_reward := 0
	if _rng.randf() < GameRulesScript.crystal_chance(int(global_upgrades.get("crystal", 0))):
		crystals += 1
		crystal_reward = 1
	var chest_reward := 0
	if _rng.randf() < 0.02 + finished_floor * 0.001:
		chests += 1
		chest_reward = 1
		coins = mini(coins + coin_reward, SaveManagerScript.MAX_BALANCE)
	blocks_remaining -= 1
	var completed_this_floor := false
	if blocks_remaining == 0:
		floor_completed[finished_floor] = true
		completed_this_floor = true
		if finished_floor < FLOOR_COUNT - 1:
			unlocked_floor = maxi(unlocked_floor, finished_floor + 1)
			_load_floor(finished_floor + 1)
		else:
			block_health_remaining = 0.0
	else:
		block_health_remaining = float(data.get("health", 80.0))
	save_progress()
	emit_signal("changed")
	return {
		"destroyed": true,
		"coins": coin_reward * (2 if chest_reward > 0 else 1),
		"crystals": crystal_reward,
		"chests": chest_reward,
		"floor_completed": completed_this_floor
	}

func first_mine_completed() -> bool:
	for completed in floor_completed:
		if not completed:
			return false
	return true

func save_progress() -> bool:
	var manager = SaveManagerScript.new()
	return manager.save_state(to_save_data())

func to_save_data() -> Dictionary:
	return {
		"coins": coins,
			"crystals": crystals,
			"chests": chests,
			"miners": miners.duplicate(true),
			"global_upgrades": global_upgrades.duplicate(true),
			"floor_upgrade_levels": floor_upgrade_levels.duplicate(),
			"floor_completed": floor_completed.duplicate(),
			"unlocked_floor": unlocked_floor,
			"current_floor": current_floor,
			"blocks_remaining": blocks_remaining,
			"block_health_remaining": block_health_remaining
	}

func load_from_save(raw: Dictionary) -> void:
	var manager = SaveManagerScript.new()
	var data: Dictionary = manager.normalize_state(raw)
	coins = int(data["coins"])
	crystals = int(data["crystals"])
	chests = int(data["chests"])
	miners = data["miners"].duplicate(true)
	global_upgrades = data["global_upgrades"].duplicate(true)
	floor_upgrade_levels = data["floor_upgrade_levels"].duplicate()
	floor_completed = data["floor_completed"].duplicate()
	unlocked_floor = int(data["unlocked_floor"])
	current_floor = int(data["current_floor"])
	blocks_remaining = int(data["blocks_remaining"])
	block_health_remaining = float(data["block_health_remaining"])
	if floor_completed[current_floor]:
		blocks_remaining = 0
		block_health_remaining = 0.0
	emit_signal("changed")

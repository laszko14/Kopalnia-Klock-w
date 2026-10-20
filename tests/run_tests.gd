extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_floor_catalog()
	_test_floor_upgrades()
	_test_block_rewards()
	_test_save_normalization()
	if failures == 0:
		print("PASS: %d checks" % checks)
		quit(0)
	else:
		push_error("FAIL: %d of %d checks failed" % [failures, checks])
		quit(1)

func _load_required(path: String):
	if not ResourceLoader.exists(path):
		_check(false, "required script exists: " + path)
		return null
	var script = load(path)
	_check(script != null, "script loads: " + path)
	return script

func _check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _test_floor_catalog() -> void:
	var script = _load_required("res://scripts/floor_catalog.gd")
	if script == null:
		return
	var catalog = script.new()
	_check(catalog.floor_count() == 30, "first mine has exactly 30 floors")
	var first: Dictionary = catalog.floor_data(0)
	var last: Dictionary = catalog.floor_data(29)
	_check(first.get("health", 0.0) > 0.0 and last.get("reward", 0) > 0, "floor data has positive health and reward")

func _test_floor_upgrades() -> void:
	var script = _load_required("res://scripts/game_state.gd")
	if script == null:
		return
	var state = script.new()
	_check(state.floor_upgrade_levels.size() == 30, "every floor has its own upgrade level")
	state.coins = 1000000000
	state.floor_upgrade_levels[0] = 799
	_check(state.buy_floor_upgrade(0), "upgrade from level 799 is purchasable")
	_check(state.floor_upgrade_levels[0] == 800, "upgrade reaches level 800")
	var balance_at_cap: int = state.coins
	_check(not state.buy_floor_upgrade(0), "level 800 is the maximum")
	_check(state.floor_upgrade_levels[0] == 800 and state.coins == balance_at_cap, "capped purchase changes neither level nor coins")
	_check(state.floor_upgrade_levels[1] == 0, "upgrading one floor does not upgrade another")
	_check(not state.buy_floor_upgrade(-1) and not state.buy_floor_upgrade(30), "invalid floor indices are rejected")
	state.coins = 0
	_check(not state.buy_floor_upgrade(0) and state.coins == 0, "unaffordable upgrade leaves balance unchanged")
	_check(not state.select_floor(1), "locked floor cannot be selected")

func _test_block_rewards() -> void:
	var script = _load_required("res://scripts/game_state.gd")
	if script == null:
		return
	var state = script.new()
	state.block_health_remaining = 0.5
	var before: int = state.coins
	var result: Dictionary = state.apply_miner_hit()
	_check(result.get("destroyed", false), "automatic miner hit can destroy a block")
	_check(state.coins > before, "destroyed block grants coins")
	var paid_balance: int = state.coins
	state.complete_block()
	_check(state.coins == paid_balance, "a block reward cannot be claimed twice")
	var miner_coins := state.coins + state.get_miner_cost("miner")
	state.coins = miner_coins
	_check(state.buy_miner("miner") and state.miners["miner"] == 1, "player can hire a miner")
	_check(not state.buy_miner("unknown"), "unknown miner cannot be purchased")

func _test_save_normalization() -> void:
	var script = _load_required("res://scripts/save_manager.gd")
	if script == null:
		return
	var manager = script.new()
	var fresh: Dictionary = manager.normalize_state({})
	_check(fresh.get("floor_upgrade_levels", []).size() == 30, "missing save data gets 30 upgrade slots")
	var malformed := {"coins": -5, "floor_upgrade_levels": [9999, -1]}
	var normalized: Dictionary = manager.normalize_state(malformed)
	_check(normalized.get("coins", -1) >= 0, "negative saved coins are clamped")
	var levels: Array = normalized.get("floor_upgrade_levels", [])
	_check(levels.size() == 30 and levels[0] == 800 and levels[1] == 0, "saved upgrade levels are normalized to 0–800 for 30 floors")

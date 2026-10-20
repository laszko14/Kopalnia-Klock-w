extends RefCounted

const FLOOR_UPGRADE_CAP := 800
const GLOBAL_UPGRADE_CAP := 100

static func floor_upgrade_cost(level: int) -> int:
	var safe_level := clampi(level, 0, FLOOR_UPGRADE_CAP - 1)
	return maxi(1, roundi(25.0 * pow(1.018, safe_level)))

static func floor_upgrade_multiplier(level: int) -> float:
	return 1.0 + clampi(level, 0, FLOOR_UPGRADE_CAP) * 0.02

static func miner_cost(miner_id: String, owned: int) -> int:
	var base_costs := {"helper": 50, "miner": 250, "drill": 1200}
	var base_cost: int = int(base_costs.get(miner_id, 0))
	if base_cost == 0:
		return 0
	return maxi(1, roundi(base_cost * pow(1.2, maxi(0, owned))))

static func global_upgrade_cost(upgrade_id: String, level: int) -> int:
	var base_costs := {"power": 100, "speed": 120, "value": 150, "crystal": 300}
	var base_cost: int = int(base_costs.get(upgrade_id, 0))
	if base_cost == 0:
		return 0
	return maxi(1, roundi(base_cost * pow(1.18, clampi(level, 0, GLOBAL_UPGRADE_CAP))))

static func global_upgrade_multiplier(upgrade_id: String, level: int) -> float:
	var safe_level := clampi(level, 0, GLOBAL_UPGRADE_CAP)
	match upgrade_id:
		"power":
			return 1.0 + safe_level * 0.12
		"value":
			return 1.0 + safe_level * 0.10
		_:
			return 1.0

static func crystal_chance(level: int) -> float:
	return clampf(0.01 + clampi(level, 0, GLOBAL_UPGRADE_CAP) * 0.005, 0.0, 0.51)

static func attack_interval(speed_level: int) -> float:
	return maxf(0.2, 1.0 / (1.0 + clampi(speed_level, 0, GLOBAL_UPGRADE_CAP) * 0.12))

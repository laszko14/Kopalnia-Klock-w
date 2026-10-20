extends RefCounted

const FLOOR_COUNT := 30

func floor_count() -> int:
	return FLOOR_COUNT

func floor_data(floor_index: int) -> Dictionary:
	if floor_index < 0 or floor_index >= FLOOR_COUNT:
		return {}
	return {
		"index": floor_index,
		"health": round(80.0 * pow(1.22, floor_index)),
		"reward": roundi(10.0 * pow(1.18, floor_index)),
		"block_count": 8 + (floor_index % 3),
		"name": "Piętro %02d" % (floor_index + 1)
	}

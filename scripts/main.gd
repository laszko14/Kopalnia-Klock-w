extends Control

const MINERS := [
	{"id": "helper", "name": "Pomocnik", "detail": "Tani i pracowity"},
	{"id": "miner", "name": "Górnik", "detail": "Silniejsze uderzenia"},
	{"id": "drill", "name": "Wiertacz", "detail": "Największa moc"}
]
const UPGRADES := [
	{"id": "power", "name": "Siła kilofa", "detail": "Mocniejsze uderzenia"},
	{"id": "speed", "name": "Tempo pracy", "detail": "Górnicy uderzają częściej"},
	{"id": "value", "name": "Wartość bloków", "detail": "Więcej monet za blok"},
	{"id": "crystal", "name": "Szczęście do kryształów", "detail": "Częstsze kryształy"}
]

var _state: Node
var _page := "mine"
var _page_body: VBoxContainer
var _coin_label: Label
var _crystal_label: Label
var _mine_timer: Timer
var _health_bar: ProgressBar
var _block_label: Label
var _floor_info: Label
var _upgrade_button: Button
var _mine_note: Label

func _ready() -> void:
	_state = get_node("/root/GameState")
	_build_shell()
	_state.changed.connect(_refresh)
	_refresh()
	_mine_timer.start()

func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = Color("#202d3a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "KOPALNIA KLOCKÓW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("#ffe49b"))
	layout.add_child(title)

	var wallet := HBoxContainer.new()
	wallet.alignment = BoxContainer.ALIGNMENT_CENTER
	wallet.add_theme_constant_override("separation", 24)
	_coin_label = Label.new()
	_crystal_label = Label.new()
	_coin_label.add_theme_color_override("font_color", Color("#fff3d3"))
	_crystal_label.add_theme_color_override("font_color", Color("#b9f1ff"))
	wallet.add_child(_coin_label)
	wallet.add_child(_crystal_label)
	layout.add_child(wallet)

	_page_body = VBoxContainer.new()
	_page_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_body.add_theme_constant_override("separation", 10)
	layout.add_child(_page_body)

	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 6)
	layout.add_child(navigation)
	_add_nav_button(navigation, "Kopalnia", "mine")
	_add_nav_button(navigation, "Górnicy", "miners")
	_add_nav_button(navigation, "Ulepszenia", "upgrades")
	_add_nav_button(navigation, "Mapa", "map")

	_mine_timer = Timer.new()
	_mine_timer.wait_time = 1.0
	_mine_timer.timeout.connect(_on_mine_tick)
	add_child(_mine_timer)

func _add_nav_button(parent: HBoxContainer, caption: String, page: String) -> void:
	var button := Button.new()
	button.text = caption
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 48
	button.add_theme_stylebox_override("normal", _style_box(Color("#34485a"), Color("#78899a")))
	button.add_theme_color_override("font_color", Color("#fff5dc"))
	button.pressed.connect(_open_page.bind(page))
	parent.add_child(button)

func _style_box(color: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

func _panel(parent: Control, color: Color = Color("#34485a")) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style_box(color, Color("#8293a1")))
	parent.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	return content

func _refresh() -> void:
	if not is_instance_valid(_state):
		return
	_coin_label.text = "● %s monet" % _format_number(_state.coins)
	_crystal_label.text = "◆ %s kryształów" % _format_number(_state.crystals)
	for child in _page_body.get_children():
		_page_body.remove_child(child)
		child.queue_free()
	match _page:
		"mine":
			_build_mine_page()
		"miners":
			_build_miners_page()
		"upgrades":
			_build_upgrades_page()
		"map":
			_build_map_page()

func _open_page(page: String) -> void:
	_page = page
	_refresh()

func _build_mine_page() -> void:
	var data: Dictionary = _state._catalog.floor_data(_state.current_floor)
	var heading := Label.new()
	heading.text = "Zielona Dolina  •  Piętro %02d / 30" % (_state.current_floor + 1)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("#fff5dc"))
	_page_body.add_child(heading)

	var mine_card := _panel(_page_body, Color("#566149"))
	var banner := Label.new()
	banner.text = "KAMIENNA KOPALNIA"
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_color_override("font_color", Color("#fff0c4"))
	mine_card.add_child(banner)

	_block_label = Label.new()
	_block_label.text = "▰  KAMIENNY BLOK  ▰"
	_block_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_block_label.add_theme_font_size_override("font_size", 28)
	_block_label.add_theme_color_override("font_color", Color("#f3cf9b"))
	mine_card.add_child(_block_label)

	_health_bar = ProgressBar.new()
	_health_bar.show_percentage = false
	_health_bar.custom_minimum_size.y = 20
	mine_card.add_child(_health_bar)

	_floor_info = Label.new()
	_floor_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_floor_info.add_theme_color_override("font_color", Color("#f5e9d3"))
	mine_card.add_child(_floor_info)

	var crew := Label.new()
	crew.text = "GÓRNICY PRACUJĄ AUTOMATYCZNIE"
	crew.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crew.add_theme_color_override("font_color", Color("#cce6c1"))
	mine_card.add_child(crew)

	_upgrade_button = Button.new()
	_upgrade_button.custom_minimum_size.y = 56
	_upgrade_button.add_theme_stylebox_override("normal", _style_box(Color("#cf8b38"), Color("#ffe4a7")))
	_upgrade_button.add_theme_color_override("font_color", Color("#241b13"))
	_upgrade_button.pressed.connect(_buy_current_floor_upgrade)
	_page_body.add_child(_upgrade_button)

	_mine_note = Label.new()
	_mine_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mine_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mine_note.add_theme_color_override("font_color", Color("#d2dce4"))
	_page_body.add_child(_mine_note)
	_update_mine_view(data)

func _update_mine_view(data: Dictionary) -> void:
	if not is_instance_valid(_health_bar) or not is_instance_valid(_floor_info):
		return
	var max_health := maxf(1.0, float(data.get("health", 80.0)))
	_health_bar.value = clampf(_state.block_health_remaining / max_health * 100.0, 0.0, 100.0)
	var total := int(data.get("block_count", 8))
	_floor_info.text = "Bloki pozostałe: %d    •    Siła: %s" % [_state.blocks_remaining, _format_number(roundi(_state.mining_power()))]
	if _state.floor_completed[_state.current_floor]:
		_mine_note.text = "To piętro jest ukończone. Wróć na mapę, by rozwijać inne piętra."
	elif _state.blocks_remaining == total:
		_mine_note.text = "Rozbudowa piętra: %d / 800" % _state.floor_upgrade_levels[_state.current_floor]
	else:
		_mine_note.text = "Rozbitych bloków: %d" % (total - _state.blocks_remaining)
	var level: int = _state.floor_upgrade_levels[_state.current_floor]
	var cost: int = _state.get_floor_upgrade_cost(_state.current_floor)
	_upgrade_button.text = "Rozbuduj piętro  •  %d / 800\nKoszt: %s monet" % [level, _format_number(cost)]
	_upgrade_button.disabled = level >= 800 or _state.current_floor > _state.unlocked_floor or _state.coins < cost

func _build_miners_page() -> void:
	var title := _section_title("Zatrudnij górników")
	_page_body.add_child(title)
	for miner in MINERS:
		var id: String = miner["id"]
		var content := _panel(_page_body)
		var label := Label.new()
		label.text = "%s  •  %s\nPosiadani: %d  •  %s" % [miner["name"], miner["detail"], _state.miners[id], _format_number(_state.get_miner_cost(id))]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", Color("#fff2da"))
		content.add_child(label)
		var hire := Button.new()
		hire.text = "Zatrudnij za %s monet" % _format_number(_state.get_miner_cost(id))
		hire.custom_minimum_size.y = 48
		hire.pressed.connect(_buy_miner.bind(id))
		content.add_child(hire)

func _build_upgrades_page() -> void:
	_page_body.add_child(_section_title("Ulepszenia całej ekipy"))
	for upgrade in UPGRADES:
		var id: String = upgrade["id"]
		var content := _panel(_page_body)
		var label := Label.new()
		label.text = "%s  •  poziom %d\n%s" % [upgrade["name"], _state.global_upgrades[id], upgrade["detail"]]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", Color("#fff2da"))
		content.add_child(label)
		var buy := Button.new()
		var cost: int = _state.get_global_upgrade_cost(id)
		buy.text = "Ulepsz za %s monet" % _format_number(cost)
		buy.disabled = _state.global_upgrades[id] >= 100 or _state.coins < cost
		buy.pressed.connect(_buy_global_upgrade.bind(id))
		content.add_child(buy)

func _build_map_page() -> void:
	_page_body.add_child(_section_title("Mapa pierwszej kopalni"))
	var summary := Label.new()
	summary.text = "Odblokowano pięter: %d / 30" % (_state.unlocked_floor + 1)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_theme_color_override("font_color", Color("#fff2da"))
	_page_body.add_child(summary)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_body.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)
	for floor_index in range(30):
		var button := Button.new()
		var prefix := "✓ " if _state.floor_completed[floor_index] else ""
		button.text = "%s%02d" % [prefix, floor_index + 1]
		button.custom_minimum_size = Vector2(74, 52)
		button.disabled = floor_index > _state.unlocked_floor
		button.pressed.connect(_select_floor.bind(floor_index))
		grid.add_child(button)
	var worlds := Label.new()
	worlds.text = "Kopalnia Miedzi — odblokuje się po ukończeniu 30 pięter."
	worlds.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	worlds.add_theme_color_override("font_color", Color("#d2dce4"))
	_page_body.add_child(worlds)

func _section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color("#ffe49b"))
	return label

func _buy_current_floor_upgrade() -> void:
	_state.buy_floor_upgrade(_state.current_floor)

func _buy_miner(miner_id: String) -> void:
	_state.buy_miner(miner_id)

func _buy_global_upgrade(upgrade_id: String) -> void:
	_state.buy_global_upgrade(upgrade_id)

func _select_floor(floor_index: int) -> void:
	if _state.select_floor(floor_index):
		_page = "mine"

func _on_mine_tick() -> void:
	var result: Dictionary = _state.apply_miner_hit()
	if result.get("destroyed", false):
		_refresh()
	elif _page == "mine":
		var data: Dictionary = _state._catalog.floor_data(_state.current_floor)
		_update_mine_view(data)

func _format_number(value: int) -> String:
	if value >= 1000000:
		return "%.1fM" % (float(value) / 1000000.0)
	if value >= 1000:
		return "%.1fK" % (float(value) / 1000.0)
	return str(value)

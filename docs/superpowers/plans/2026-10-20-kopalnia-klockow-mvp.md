# Kopalnia Klocków MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a playable Godot 4 Android idle-mining MVP with 30 floors, independent floor upgrades capped at level 800, persistent progress, and a GitHub Actions APK build.

**Architecture:** Keep game rules and save data in small GDScript classes without scene dependencies, then connect them to a compact portrait UI. Store floor definitions as data and derive each floor's starting block stats from its index. The Android workflow runs Godot headless validation and exports a debug APK as an artifact.

**Tech Stack:** Godot 4.x, GDScript, GitHub Actions, Android SDK/JDK.

**Spec:** `docs/superpowers/specs/2026-10-20-kopalnia-klockow-design.md`

## Global Constraints
- Android game is portrait and offline.
- First mine contains exactly 30 floors.
- Each floor has an independent upgrade level from 0 through 800.
- Miners attack automatically; manual tapping is not part of MVP.
- Game currencies are coins and crystals; include a bonus chest/reward.
- Save data stays local and tolerates missing or malformed files.
- Do not add login, ads, purchases, cloud sync, or online services.

## Review Focus
- Upgrade purchases at level 0, 799, and 800 must respect bounds and currency.
- Destroying a block/floor must grant rewards once, including on frame boundaries.
- Switching or revisiting floors must preserve each floor's individual upgrade and completion state.
- Missing, malformed, or older save data must start/migrate safely without crashing.
- Very large numeric values and repeated purchases must not overflow into negative currency or damage.

---

### Task 1: Godot scaffold and Android build workflow

**Files:**
- Create: `project.godot`
- Create: `scenes/main.tscn`
- Create: `scripts/main.gd`
- Create: `.gitignore`
- Create: `.github/workflows/android-apk.yml`
- Create: `export_presets.cfg`
- Create: `README.md`

**Interfaces:**
- Produces: runnable project root scene `scenes/main.tscn`; CI artifact named `Kopalnia-Klockow-debug.apk`.

- [ ] **Step 1: Add a minimal portrait project and main scene**
  Set application name, portrait viewport, main scene, and autoload placeholders only for components already introduced in this plan.

- [ ] **Step 2: Add the Android Actions workflow**
  Add an Android export preset named `Android`; pin a Godot 4 version and matching export templates; install the Android build dependencies; import project resources headlessly; export a debug APK; upload it as a workflow artifact. Keep signing secrets out of the repository.

- [ ] **Step 3: Validate the empty scaffold**
  Run: Godot headless editor import and scene launch with `--quit-after 2`.
  Expected: zero parse errors and clean exit.

- [ ] **Step 4: Commit**
  Commit scaffold and workflow with message `build: scaffold Godot Android project`.

---

### Task 2: Floor model, miners, economy, and rewards

**Files:**
- Create: `scripts/game_rules.gd`
- Create: `scripts/game_state.gd`
- Create: `scripts/floor_catalog.gd`
- Create: `tests/run_tests.gd`
- Modify: `project.godot` to register the game state autoload.

**Interfaces:**
- `FloorCatalog.floor_count() -> int`
- `FloorCatalog.floor_data(floor_index: int) -> Dictionary`
- `GameRules.upgrade_cost(level: int) -> int`
- `GameRules.upgrade_effect(level: int) -> float`
- `GameState.select_floor(floor_index: int) -> bool`
- `GameState.buy_floor_upgrade(floor_index: int) -> bool`
- `GameState.buy_miner(miner_id: String) -> bool`
- `GameState.apply_miner_hit() -> Dictionary`
- `GameState.complete_block() -> Dictionary`

- [ ] **Step 1: Test the 30-floor catalog and level boundaries**
  Add tests asserting exactly 30 floors, distinct indices 0–29, independent levels per floor, level 799 can buy level 800 when affordable, and level 800 cannot be exceeded.

- [ ] **Step 2: Run tests and confirm they fail**
  Run: `godot --headless --path . --script tests/run_tests.gd`.
  Expected: failures for missing catalog/rules/state APIs.

- [ ] **Step 3: Implement catalog and economy rules**
  Use configurable formulas for block health, coin payout, upgrade cost, and upgrade effect. Keep early floors completable quickly; ensure affordability checks happen before balances change.

- [ ] **Step 4: Test miner damage and reward distribution**
  Assert miners deal automatic damage; destroyed blocks grant rewards exactly once; crystals/chests are possible bonus outcomes; unaffordable purchases do not mutate state; very large balances and repeated purchases never create negative values; floor completion occurs only when all blocks are cleared.

- [ ] **Step 5: Run the rules test suite**
  Run: `godot --headless --path . --script tests/run_tests.gd`.
  Expected: all model tests pass.

- [ ] **Step 6: Commit**
  Commit rules, state, and tests with message `feat: add mining economy and floor progression`.

---

### Task 3: Save and restore

**Files:**
- Create: `scripts/save_manager.gd`
- Modify: `scripts/game_state.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- `SaveManager.save_state(state: Dictionary) -> bool`
- `SaveManager.load_state() -> Dictionary`
- `SaveManager.normalize_state(raw: Dictionary) -> Dictionary`
- Save schema key: `save_version`; floor upgrades stored as a 30-entry array.

- [ ] **Step 1: Test round-trip, missing file, malformed JSON, and version normalization**
  Assert valid state round-trips; missing/corrupt files return a fresh valid state; older or partial data fills defaults; no floor upgrade exceeds 800.

- [ ] **Step 2: Run tests and confirm save cases fail**
  Run: `godot --headless --path . --script tests/run_tests.gd`.
  Expected: save manager API failures.

- [ ] **Step 3: Implement versioned local save**
  Store JSON under `user://`; validate types and bounds before applying loaded data; write to a temporary file before replacing the active save when supported.

- [ ] **Step 4: Verify save suite and commit**
  Run the test suite; expected all save and game model tests pass.
  Commit with message `feat: persist local mining progress`.

---

### Task 4: Portrait game UI and navigation

**Files:**
- Create: `scenes/mine/mine_screen.tscn`
- Create: `scripts/mine_screen.gd`
- Create: `scenes/panels/miners_panel.tscn`
- Create: `scenes/panels/upgrades_panel.tscn`
- Create: `scenes/panels/world_map_panel.tscn`
- Create: `scenes/panels/settings_panel.tscn`
- Create: `assets/` placeholder vector/cartoon shapes where needed.

**Interfaces:**
- Mine screen reads `GameState` and calls `buy_miner`, `buy_floor_upgrade`, and `select_floor`; panel navigation remains local to the UI.
- Empty/locked world entries are display-only until unlocked.

- [ ] **Step 1: Build the mine screen layout**
  Show coins, crystals, world/floor, current block health, automatic miner animations, floor upgrade level/cost, and navigation buttons.

- [ ] **Step 2: Add miner, upgrades, map, and settings panels**
  Make each panel independently open/close and update after purchases or floor changes. Use readable high-contrast cartoon placeholder art.

- [ ] **Step 3: Wire UI to state and add smoke checks**
  Add headless smoke assertions that all required scenes load and the main scene has no missing resource paths. Verify `select_floor()` accepts unlocked floors and rejects invalid or locked floors without changing state.

- [ ] **Step 4: Manually inspect portrait scaling**
  Run at the configured portrait viewport; verify counters and controls remain on-screen and navigation does not hide the mine state.

- [ ] **Step 5: Commit**
  Commit scenes and UI with message `feat: add portrait mine and upgrade screens`.

---

### Task 5: Thirty-floor progression and final Android verification

**Files:**
- Modify: `scripts/game_state.gd`
- Modify: `scripts/mine_screen.gd`
- Modify: `tests/run_tests.gd`
- Modify: `.github/workflows/android-apk.yml` if validation reveals CI gaps.

- [ ] **Step 1: Test floor completion, revisit, and world unlock**
  Assert all 30 floors are reachable in order, completed floors can be revisited, floor-specific levels persist, and world 2 remains locked until floor 30 is completed.

- [ ] **Step 2: Implement progression and map state**
  Ensure moving between floors never resets their independent upgrades, completion state, or rewards.

- [ ] **Step 3: Run all headless tests and editor import**
  Run: `godot --headless --path . --script tests/run_tests.gd`, then import and launch the main scene.
  Expected: all tests pass; no parse/resource errors.

- [ ] **Step 4: Run GitHub Actions Android export**
  Expected: workflow succeeds and provides `Kopalnia-Klockow-debug.apk` as a downloadable artifact.

- [ ] **Step 5: Review the APK and commit**
  Confirm APK exists and has non-zero size; record workflow result and artifact link. Commit any final fixes with message `test: verify 30-floor Android MVP`.

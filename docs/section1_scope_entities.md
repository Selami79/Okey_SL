# Section 1 – Scope, Entities, Naming & Assets

## 1. Scope (MVP)

- **Mode:** 4-player human-only Okey (no AI).
- **Flow:** Free tile arrangement on personal HUD; table slots clickable for draw, discard, finish.
- **Scoring:** Start at 20 points; normal finish -2 to others, okey/7-pairs finish -4 to others.
- **Performance:** Low script count; single “UI Manager” + single “Game Controller”.

**Out of Scope (MVP):** AI, multi-table management, persistent data, tournaments.

---

## 2. System Components

- **Game_Controller (table/root prim):** Rules, turn handling, dealing, scoring, seat detection.
- **UI_Manager (HUD + table UI):** Click events, textures, tile selection tracking.
- **ScoreBoard object:** Displays names, seat mapping, scores.
- **Chair_1..4:** Seating detection.
- **Deck_1 / Indicator_1 / Discard_1..4:** Table interaction slots.

---

## 3. Link Names & Description Tags

- **Root:** `OkeyTable`
- **Chair:** `Chair_1..4` → `desc: role=Seat;idx=1..4`
- **Discard:** `Discard_1..4` → `desc: role=Discard;idx=1..4`
- **Indicator:** `Indicator_1` → `desc: role=Indicator`
- **Deck:** `Deck_1` → `desc: role=Deck`
- **Scoreboard:** `ScoreBoard_1` → `desc: role=ScoreBoard`
- **HUD slots:** `RackSlot_01..32` (HUD root `desc: seat=1..4`)

> Link numbers may vary; discovery will be via name + description.

---

## 4. Communication Channels & Constants

- **PRIVATE chat:** `-987654`
- **LinkMessage numbers:**
  - `LM_CONTROLLER = 1001`
  - `LM_MODULE = 1002`
  - `LM_HUD = 1003`
- **Attach:** HUD `ATTACH_HUD_CENTER_2`

---

## 5. Textures & Notecard

- **Notecard name:** `TextureConfig`
- **Format:** `KEY=VALUE` (VALUE = texture name or UUID)
- **KEY set:**
  - 52 tiles: `R1..R13`, `Y1..Y13`, `B1..B13`, `S1..S13`
  - `FO` (fake okey), `OK` (okey symbol if needed)
  - `BACK` (tile back), `RACK_EMPTY` (empty HUD slot)
- **UI Manager duties:** Maps notecard to memory, updates Indicator/Discard/RackSlot textures, keeps last/prev discard cache.

---

## 6. Tile Encoding (Controller Internal Logic)

- **Int code:** `color*100 + number`
  - R=1, Y=2, B=3, S=4; `1..13`
  - `ENC_OK=900`, `ENC_FO=901`
- **Indicator→Okey:** same color, `(num+1)`; wrap 13→1.

---

## 7. Seating Detection & Seat Map

- Detect via `Chair_i` sit target → `llAvatarOnSitTarget()` / `CHANGED_LINK`.
- Map: `seat → avatarKey` dictionary; JOIN/LEAVE events.
- **ScoreBoard update:** avatar display name, seat no, score=20.
- **UI notify:** `SEAT_UPDATE|seat=i;av=<key>;name=<display>`.

---

## 8. Initial Assets/Inventory Requirements

- **Table object:** `Game_Controller.lsl`, `TextureConfig` (optional), ScoreBoard mesh/prim, Deck/Indicator/Discard prims.
- **HUD object:** `UI_Manager.lsl`, 32 slot prims (`RackSlot_01..32`), same notecard optional (UI Manager can use table’s).

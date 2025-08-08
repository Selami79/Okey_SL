# Section 3 – Algorithms, Scoring, Acceptance Criteria & Tests

## 1. Algorithms

### 1.1 Tile Set & Shuffle
- 4 colors × 1–13 × 2 sets = 104 tiles
- + 2 Fake Okey = total **106 tiles**
- Encoding: `code = color*100 + number`  
  R=1, Y=2, B=3, S=4; `ENC_OK=900`, `ENC_FO=901`
- Shuffle: Fisher–Yates algorithm

### 1.2 Indicator & Okey
- Indicator: top tile from deck → placed on `Indicator_1`
- Okey: same color as indicator, `(num+1)` (wrap 13→1)
- Fake Okey behaves as real okey for matching

### 1.3 Dealing
- Starter seat: 15 tiles
- Other players: 14 tiles each
- Deal in order 1→2→3→4, repeating until hands filled

### 1.4 Turn Loop
- `WAIT_DRAW`: expects `DRAW` or `TAKE`
- `WAIT_DROP`: expects `DROP` or `CHECK`
- After `DROP`, advance to next seat
- After valid `CHECK`, go to `ROUND_END`

### 1.5 Finish Check
- Remove selected tile from hand
- Check remaining 14 tiles via `canCloseHand()`
- If true: `CHECK_RES ok=1` + update indicator with finish tile
- If false: `CHECK_RES ok=0` and stay in `WAIT_DROP`

### 1.6 Deck Exhaustion
- If deck is empty on `DRAW`, round ends in a draw, no score change

---

## 2. Scoring Rules (MVP)
- Start score: **20 points per player**
- Normal finish: other 3 players lose **2 points each**
- Okey finish (last tile is real okey): other 3 lose **4 points each**
- 7 pairs finish: other 3 lose **4 points each**
- Game ends if any player’s score ≤ 0 → highest score wins

---

## 3. Acceptance Criteria (DoD)

**Setup**
- [ ] Correct link names for all prims (`Chair_1..4`, `Discard_1..4`, `Indicator_1`, `Deck_1`, `RackSlot_01..32`)
- [ ] HUD root has `desc: seat=1..4`
- [ ] `TextureConfig` notecard exists with at least `BACK` and `RACK_EMPTY`

**Seating & Scoreboard**
- [ ] Player seating updates scoreboard with name and 20 points
- [ ] HUD binds correctly on attach

**Dealing**
- [ ] Deck shuffled; indicator opened; okey computed
- [ ] Starter gets 15 tiles, others get 14

**Turn Flow**
- [ ] Only current player can act
- [ ] `TAKE` only from left neighbor’s last discard
- [ ] `DROP` updates discard slot and advances turn
- [ ] `CHECK` updates indicator on success

**Finish & Scoring**
- [ ] Valid check ends round; scores updated correctly
- [ ] Deck exhaustion triggers draw round

**Resilience**
- [ ] HUD reconnect restores state
- [ ] Invalid moves rejected with error codes

---

## 4. Test Scenarios

### 4.1 Happy Path
- 4 players join, deal, normal play, valid finish

### 4.2 Edge Cases
- TAKE from empty discard → `DISCARD_EMPTY`
- Wrong turn action → `NOT_YOUR_TURN`
- Invalid finish → `CHECK_RES ok=0`
- 7 pairs detection works
- Fake okey treated as real okey
- Deck exhaustion triggers draw

---

## 5. Performance Notes
- Use integer bitmask DFS for `canCloseHand()` to save memory
- Avoid unnecessary list copies
- Throttle input to ≥ 300 ms between actions
- Minimal script count for low LI

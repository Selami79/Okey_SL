# Second Life – 4 Player Okey MVP

## 1. Summary
This repository contains the MVP (Minimum Viable Product) for a 4-player, human-only Okey game in Second Life.
The game features:
- Free arrangement of tiles on a personal HUD (32 slots).
- Table interactions for draw, discard, and finish actions.
- Basic scoring starting at 20 points per player, with penalties for other players on a win.
- Optimized for low Land Impact and minimal script usage.

MVP **excludes**: AI players, multi-table management, persistent data, and tournaments.

---

## 2. Repository Structure & Modules
- `docs/` – design documentation for scope, protocols, and scoring.
- `scripts/` – LSL scripts and configuration:
  - `Game_Controller.lsl` – table logic for seats, dealing, turns, and scoring.
  - `UI_Manager.lsl` – HUD script handling button clicks and textures.
  - `ScoreBoard.lsl` – displays player names and scores.
  - `TextureConfig` – notecard listing texture UUIDs for HUD elements.
  - `Link_Prim_Descriptions.txt` – reference for link names and prim descriptions.

---

## 3. Usage
1. Drop the scripts into the appropriate table and HUD prims in Second Life.
2. Ensure prim names match those defined in `Link_Prim_Descriptions.txt`.
3. Add the `TextureConfig` notecard with valid texture UUIDs.
4. Invite four players to sit on the seats; the game starts automatically.

---

## 4. License
This project is open source and available under the MIT license.

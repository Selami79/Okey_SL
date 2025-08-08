# Section 2 – Communication Protocols, State Machines & Event Flows

## 1. Communication Protocol (UI ↔ Controller)

**Kanal:** PRIVATE chat `-987654`  
**Mesaj Formatı:**  
CMD|k1=v1;k2=v2

- Zorunlu alan: `seat` (1..4)  
- Kullanıcı kaynaklı komutlarda opsiyonel: `av=<avatar_key>`

### 1.1 UI → Controller Komutları
- `HUD_READY|seat=1;av=<key>` → HUD bağlandığında gönderilir.
- `SELECT|seat=1;tile=R11` → HUD üzerinde taş seçimi.
- `DRAW|seat=1` → Desteden taş çek.
- `TAKE|seat=1;fromDiscard=4` → Soldaki oyuncunun son iskartasını al.
- `DROP|seat=1;tile=R11` → Taş at.
- `CHECK|seat=1;tile=R11` → Bitiş denemesi.
- `PING|seat=1` → Sağlık kontrolü.

### 1.2 Controller → UI Mesajları
- `UPDATE_SLOT|slot=RackSlot_05;tile=Y03` → Slotu güncelle.
- `CLEAR_SLOT|slot=Discard_3` → Slotu boşalt.
- `CHECK_RES|ok=1;tile=R11;isOkey=0;msg=...` → Bitiş sonucu.
- `TURN|seat=2` → Sıra bildirimi.
- `SEAT_UPDATE|seat=3;av=<key>;name=<display>` → Oturma güncellemesi.
- `SCORE_UPDATE|p1=20;p2=18;p3=22;p4=20` → Skor güncellemesi.
- `ERROR|code=NOT_YOUR_TURN;msg=...` → Hata mesajı.
- `PONG|seat=1` → Ping cevabı.

### 1.3 Hata Kodları (örnek)
`NOT_YOUR_TURN`, `NO_SELECTED_TILE`, `DECK_EMPTY`, `DISCARD_EMPTY`,  
`ILLEGAL_TAKE`, `HAND_NOT_CLOSABLE`, `SEAT_NOT_BOUND`, `RATE_LIMIT`

### 1.4 Güvenlik ve Doğrulama
- Sıra kontrolü: `seat == currentSeat`
- Sahiplik: `av` ile HUD bağının eşleşmesi
- Rate limit: Aynı koltuktan gelen komutlar arası min. **300 ms**

---

## 2. State Machines

### 2.1 Masa / Oyun (Game_Controller)
**Durumlar:**  
`IDLE → LOBBY → DEALING → IN_PLAY → ROUND_END → LOBBY`

**Geçişler:**
- `IDLE → LOBBY`: Masa rez/reset.
- `LOBBY → DEALING`: Başlatma komutu, 4 koltuk dolu.
- `DEALING → IN_PLAY`: Karıştırma, gösterge/okey belirleme, dağıtım (P1=15, diğerleri=14).
- `IN_PLAY → ROUND_END`: Geçerli `CHECK` veya deste biterse.
- `ROUND_END → LOBBY`: Sonuç ve skor güncelleme.

### 2.2 Tur Döngüsü (IN_PLAY alt durumları)
- Yön: Saat yönünün tersi (CCW) – `1 → 2 → 3 → 4 → 1`
- Alt durumlar:
  - `WAIT_DRAW`: 14 taş → `DRAW` veya `TAKE` bekler.
  - `WAIT_DROP`: 15 taş → `DROP` veya `CHECK` bekler.
- Geçişler:
  - `WAIT_DRAW` → `WAIT_DROP` (`DRAW/TAKE`)
  - `WAIT_DROP` → `WAIT_DRAW` (sıradaki oyuncu) (`DROP`)
  - `WAIT_DROP` → `ROUND_END` (`CHECK` başarılı)
  - `WAIT_DROP` → `WAIT_DROP` (`CHECK` başarısız)

---

## 3. Event Flows (Uçtan Uca)

### 3.1 Oturma ve Scoreboard
1. Oyuncu `Chair_i`’ye oturur → `seat=i, av=key` eşlenir.
2. `SEAT_UPDATE` yayılır, scoreboard güncellenir.
3. HUD `HUD_READY` gönderir, Controller HUD’ı bağlar.

### 3.2 Başlangıç ve Dağıtım
1. `START` → `DEALING`
2. 106 taş karıştırılır, gösterge açılır, okey hesaplanır.
3. P1=15, diğerleri=14 taş alır (`UPDATE_SLOT`).
4. `TURN|seat=1` → `WAIT_DRAW`

### 3.3 Çekme (DRAW/TAKE)
- `DRAW`: Desteden taş çek, HUD’da boş slota ekle.
- `TAKE`: Soldaki oyuncunun son iskartasını al, iskarta slotunu temizle.

### 3.4 Atma (DROP)
- HUD’de seçili taş kendi Discard slotuna gönderilir.
- Slot güncellenir, sıra değişir.

### 3.5 Bitiş (CHECK)
- Seçili taş çıkarılır, kalan 14 taş kontrol edilir.
- Başarılıysa `CHECK_RES ok=1` + Indicator güncellemesi → `ROUND_END`.
- Başarısızsa `CHECK_RES ok=0` → oyuncu `WAIT_DROP`ta kalır.

### 3.6 Tur Sonu (ROUND_END)
- Skorlar güncellenir.
- Deste boşsa tur berabere biter.
- Yeni tura `LOBBY` ile geçilir.

---

## 4. Modül Arabirimleri (İskelet)

### 4.1 Link Keşfi
`llGetLinkName()` + `PRIM_DESC` ile role/idx eşleşmesi yapılır.  
Örnek: `role=Discard;idx=1`, `role=Seat;idx=3`, `role=Indicator`, `role=Deck`.

### 4.2 Seat Bağlama
bindSeat(integer seat, key av, string name);
unbindSeat(integer seat);


### 4.3 Tur Kontrolü
startRound();
advanceTurn();
requireState(seat, phase);



### 4.4 El ve İskarta Yönetimi
giveTileToSeat(seat, code);
removeTileFromSeat(seat, code);
topOfDiscard(seat) -> code;
pushDiscard(seat, code);
popDiscard(seat) -> code;



### 4.5 Kurallar
canCloseHand(hand14, oCol, oNum) -> 0/1;
isOkeyCode(code, oCol, oNum) -> 0/1;


---

## 5. Dayanıklılık ve Anti-Cheat
- **Rate limit:** ≥ 300 ms
- **Crash recovery:** HUD reattach → `HUD_READY` ile yeniden bağlanır.
- **Server authority:** Eldeki taşların doğrusu yalnızca Controller’da tutulur.
- **Geçersiz hareketler:** `SELECT` olmayan taş, yanlış `TAKE`, HUD manipülasyonu → reddedilir.

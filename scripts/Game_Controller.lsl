// Game_Controller.lsl
// Controls Okey game flow: seat binding, dealing, turn logic, scoring
// This MVP assumes four players and a single table object

integer NUM_PLAYERS = 4;

// Player data
list gPlayers = [];            // avatar keys
list gSeatPrims = ["SEAT_1", "SEAT_2", "SEAT_3", "SEAT_4"]; // names of seat prims
list gHands = [];              // list of lists: [player0Hand, player1Hand, ...]
list gScores = [0,0,0,0];      // scores for each player

// Deck representation: 106 tiles (1-13 in four colors + 2 jokers)
list gDeck = [];

integer gTurnIndex = -1;       // whose turn (-1 until game start)

// ---------- Utility ----------
list buildDeck(){
    list deck = [];
    integer color;
    integer value;
    for(color=0;color<4;color++){
        for(value=1; value<=13; value++){
            deck += [value | (color<<8)];
            deck += [value | (color<<8)];
        }
    }
    // Two jokers represented as 0xFFFF
    deck += [0xFFFF,0xFFFF];
    return deck;
}

list shuffle(list deck){
    integer i;
    integer len = llGetListLength(deck);
    list out = deck;
    for(i=0;i<len;i++){
        integer idx = (integer)llFrand(len);
        integer tmp = llList2Integer(out, i);
        out = llListReplaceList(out, [llList2Integer(out, idx)], i, i);
        out = llListReplaceList(out, [tmp], idx, idx);
    }
    return out;
}

list takeTiles(integer amount){
    list taken = llList2List(gDeck, 0, amount-1);
    gDeck = llDeleteSubList(gDeck, 0, amount-1);
    return taken;
}

// ---------- Game Setup ----------
startGame(){
    gDeck = shuffle(buildDeck());
    gHands = [];
    integer i;
    for(i=0;i<NUM_PLAYERS;i++){
        gHands += [takeTiles(14)]; // each player gets 14 tiles
    }
    gTurnIndex = 0;
    llSay(0, "Game started. Player 1 begins.");
    updateScores();
}

bindSeat(key id, string primName){
    integer seatIndex = llListFindList(gSeatPrims, [primName]);
    if(seatIndex != -1 && llList2Key(gPlayers, seatIndex) == NULL_KEY){
        gPlayers = llListReplaceList(gPlayers, [id], seatIndex, seatIndex);
        llOwnerSay("Player bound to seat " + (string)(seatIndex+1));
        llMessageLinked(LINK_SET, 0, "NAME:" + (string)seatIndex + ":" + llKey2Name(id), NULL_KEY);
    }
}

// ---------- Turn Logic ----------
nextTurn(){
    gTurnIndex = (gTurnIndex + 1) % NUM_PLAYERS;
    llMessageLinked(LINK_SET, 0, "TURN:" + (string)gTurnIndex, NULL_KEY);
}

// Simulate draw from deck
playerDraw(integer index){
    list tile = takeTiles(1);
    list hand = llList2List(gHands, index, index);
    list newHand = hand + tile;
    gHands = llListReplaceList(gHands, [newHand], index, index);
}

// Simulate discard (remove first tile)
playerDiscard(integer index){
    list hand = llList2List(gHands, index, index);
    if(llGetListLength(hand) > 0){
        integer tile = llList2Integer(hand, 0);
        hand = llDeleteSubList(hand, 0, 0);
        gHands = llListReplaceList(gHands, [hand], index, index);
        llSay(0, "Player " + (string)(index+1) + " discarded tile " + (string)tile);
    }
}

// Simple scoring: +1 per tile in hand after round
endRound(){
    integer i;
    for(i=0;i<NUM_PLAYERS;i++){
        list hand = llList2List(gHands, i, i);
        integer score = llList2Integer(gScores, i);
        score += llGetListLength(hand);
        gScores = llListReplaceList(gScores, [score], i, i);
    }
    updateScores();
}

updateScores(){
    integer i;
    for(i=0;i<NUM_PLAYERS;i++){
        llMessageLinked(LINK_SET, 0, "SCORE:" + (string)i + ":" + (string)llList2Integer(gScores,i), NULL_KEY);
    }
}

// ---------- Events ----------
default{
    state_entry(){
        gPlayers = [NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY];
    }

    touch_start(integer count){
        key id = llDetectedKey(0);
        string primName = llGetLinkName(llDetectedLinkNumber(0));
        // If seat is touched bind player
        if(llListFindList(gSeatPrims, [primName]) != -1){
            bindSeat(id, primName);
            if(llGetListLength(gPlayers) == NUM_PLAYERS && gTurnIndex == -1){
                startGame();
            }
        }
    }

    listen(integer channel, string name, key id, string msg){
        if(msg == "DRAW" && id == llList2Key(gPlayers,gTurnIndex)){
            playerDraw(gTurnIndex);
        }
        if(msg == "DISCARD" && id == llList2Key(gPlayers,gTurnIndex)){
            playerDiscard(gTurnIndex);
            nextTurn();
        }
        if(msg == "ENDROUND"){
            endRound();
        }
    }
}

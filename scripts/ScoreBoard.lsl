// ScoreBoard.lsl
// Displays player names and scores on linked prims named SCORE_1..SCORE_4

integer NUM_PLAYERS = 4;
list gNames = ["", "", "", ""];
list gScores = [0,0,0,0];

updateBoard(){
    integer i;
    for(i=0;i<NUM_PLAYERS;i++){
        string text = llList2String(gNames,i) + "\n" + (string)llList2Integer(gScores,i);
        integer link = llGetLinkNumber("SCORE_" + (string)(i+1));
        if(link>0){
            llSetLinkPrimitiveParamsFast(link, [PRIM_TEXT, text, <1,1,1>, 1.0]);
        }
    }
}

default{
    state_entry(){
        updateBoard();
    }

    link_message(integer sender, integer num, string msg, key id){
        if(llSubStringIndex(msg, "NAME:") == 0){
            list parts = llParseString2List(llGetSubString(msg,5,-1), [":"], []);
            integer idx = (integer)llList2String(parts,0);
            gNames = llListReplaceList(gNames, [llList2String(parts,1)], idx, idx);
            updateBoard();
        }
        if(llSubStringIndex(msg, "SCORE:") == 0){
            list parts = llParseString2List(llGetSubString(msg,6,-1), [":"], []);
            integer idx = (integer)llList2String(parts,0);
            gScores = llListReplaceList(gScores, [(integer)llList2String(parts,1)], idx, idx);
            updateBoard();
        }
    }
}

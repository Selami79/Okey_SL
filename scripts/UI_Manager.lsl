// UI_Manager.lsl
// Handles HUD button clicks and texture updates from TextureConfig notecard

string NOTECARD = "TextureConfig";
integer gLine = 0;

list gTextures = [];

loadTextures(){
    gLine = 0;
    llGetNotecardLine(NOTECARD, gLine);
}

processTexture(string line){
    // Expected format: name|uuid
    list parts = llParseString2List(line, ["|"], []);
    if(llGetListLength(parts) == 2){
        gTextures += parts;
    }
}

applyTextures(){
    integer i;
    for(i=0;i<llGetListLength(gTextures);i+=2){
        string name = llList2String(gTextures, i);
        string uuid = llList2String(gTextures, i+1);
        integer link = llGetLinkNumber(name);
        if(link>0){
            llSetLinkTexture(link, uuid, ALL_SIDES);
        }
    }
}

sendAction(string action){
    // Relay HUD action to controller
    llMessageLinked(LINK_SET, 0, action, llGetOwner());
}

default{
    state_entry(){
        loadTextures();
    }

    dataserver(key query_id, string data){
        if(data != EOF){
            processTexture(data);
            gLine++;
            llGetNotecardLine(NOTECARD, gLine);
        } else {
            applyTextures();
        }
    }

    touch_start(integer count){
        string name = llGetLinkName(llDetectedLinkNumber(0));
        if(name == "DRAW_BUTTON") sendAction("DRAW");
        if(name == "DISCARD_BUTTON") sendAction("DISCARD");
        if(name == "ENDROUND_BUTTON") sendAction("ENDROUND");
    }
}

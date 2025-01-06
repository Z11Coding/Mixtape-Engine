package archipelago;

class APCategoryState extends states.CategoryState {

    public var AP:archipelago.Client;
    public var gameState:archipelago.APGameState;


    public function new(gameState:archipelago.APGameState) {
        this.AP = gameState.info();
        this.gameState = gameState;
        super(['All', 'Hinted', 'Unlocked', 'Unplayed', 'Options', 'Quit'], false, false, false, false);
        menuLocks = [false, false, false, false];
        specialOptions = [null, null, null, null];

        var opFunc = function() {
            MusicBeatState.switchState(new options.OptionsState());
        };

        var quitFunc = function() {
            AP.disconnect_socket();
            MusicBeatState.switchState(new archipelago.APEntryState());
        };
        specialOptions.push(opFunc);

        this.specialOptions.pushMulti([opFunc, quitFunc]);

        ExitState.addExitCallback(function() {
            if (AP != null){
                trace("Properly disconnecting from server before exiting...");
            AP.disconnect_socket();}
        });
    }
}
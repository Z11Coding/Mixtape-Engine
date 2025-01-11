package archipelago;

import backend.ui.*;
import archipelago.APEntryState;

class APSettingsSubState extends MusicBeatSubstate {
    var box:PsychUIBox;
    var progression_balancing:PsychUIDropDownMenu;
    var accessibility:PsychUIDropDownMenu;
    var unlockType:PsychUIDropDownMenu;
    var unlockMethod:PsychUIDropDownMenu;
    var startingSong:PsychUIDropDownMenu;
    var allowMods:PsychUICheckBox;
    var deathlink:PsychUICheckBox;
    var ticketPercent:PsychUISlider;
    var ticketWinPercent:PsychUISlider;
    var chartmodifierchance:PsychUISlider;
    var trapAmount:PsychUISlider;
    var bbcWeight:PsychUISlider;
    var ghostChatWeight:PsychUISlider;
    var tutorialWeight:PsychUISlider;
    var svcWeight:PsychUISlider;
    var fakeTransWeight:PsychUISlider;
    var shieldWeight:PsychUISlider;
    var MHPWeight:PsychUISlider;
    var gameSettings:Dynamic;

    override function create() {
        box = new PsychUIBox(0, 0, 300, 480, ['Main Settings', 'Songs', 'Traps']);
		box.selectedName = 'Main Settings';
		box.scrollFactor.set();
        box.canMove = false;
        box.canMinimize = false;
        box.screenCenter();
		add(box);

        gameSettings = archipelago.APEntryState.gameSettings;

        addMainSettings();
        addSongsSettings();
        addTrapsSettings();

        progression_balancing.list = ['disabled', 'normal', 'extreme'];
        accessibility.list = ['full', 'minimal'];
        unlockType.list = ["Per Song", "Per Week"];
        unlockMethod.list = ["Note Checks", "Song Completion", "Both"];
        
        var songList:Array<String> = [];
        WeekData.reloadWeekFiles(false);
        for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			
			for (song in leWeek.songs)
			{
				songList.push(song[0]);
			}
		}
        songList.sort((a:String, b:String) -> (a.toUpperCase() < b.toUpperCase()) ? -1 : 1); //Sort alphabetically descending
        
        if (songList.length > 0)
            startingSong.list = songList;
        else
        {
            trace("ERROR! NO SONGS FOUND! RESORTING TO DEFUALT!");
            var tempList = APEntryState.globalSongList;
            tempList.sort((a:String, b:String) -> (a.toUpperCase() < b.toUpperCase()) ? -1 : 1); //Sort alphabetically descending
            startingSong.list = tempList;
        }
        
        super.create();
    }
    
    function addMainSettings()
    {
        var tab_group = box.getTab('Main Settings').menu;
        var objX = 10;
        var objY = 40;

        progression_balancing = new PsychUIDropDownMenu(objX, objY, [''], function(id:Int, prog:String)
        {
            gameSettings.progression_balancing = prog;
        });
        progression_balancing.selectedLabel = gameSettings.progression_balancing;

        accessibility = new PsychUIDropDownMenu(objX + 150, objY, [''], function(id:Int, acc:String)
        {
            gameSettings.accessibility = acc;
        });
        accessibility.selectedLabel = gameSettings.accessibility;

        objY += 50;
        unlockType = new PsychUIDropDownMenu(objX, objY, [''], function(id:Int, unlock:String)
        {
            gameSettings.unlock_type = unlock;
        });
        unlockType.selectedLabel = gameSettings.unlock_type;

        unlockMethod = new PsychUIDropDownMenu(objX + 150, objY, [''], function(id:Int, unlock:String)
        {
            gameSettings.unlock_method = unlock;
        });
        unlockMethod.selectedLabel = gameSettings.unlock_method;

        objY += 70;
        deathlink = new PsychUICheckBox(objX, objY, 'DeathLink', 100, function() gameSettings.deathlink = deathlink.checked);
        deathlink.checked = gameSettings.deathlink;
        
        objY += 50;
        ticketPercent = new PsychUISlider(objX, objY, function(v:Float) gameSettings.ticket_percentage = Std.int(v));
        ticketPercent.decimals = 0;
        ticketPercent.min = 10;
        ticketPercent.max = 50;
        ticketPercent.value = gameSettings.ticket_percentage;

        objY += 50;
        ticketWinPercent = new PsychUISlider(objX, objY, function(v:Float) gameSettings.ticket_win_percentage = Std.int(v));
        ticketWinPercent.decimals = 0;
        ticketWinPercent.min = 50;
        ticketWinPercent.max = 100;
        ticketWinPercent.value = gameSettings.ticket_win_percentage;

        tab_group.add(new FlxText(progression_balancing.x, progression_balancing.y - 15, 120, 'Progression Balancing:'));
        tab_group.add(new FlxText(accessibility.x, accessibility.y - 15, 120, 'Accessibility:'));
        tab_group.add(new FlxText(unlockType.x, unlockType.y - 15, 120, 'Unlock Type:'));
        tab_group.add(new FlxText(unlockMethod.x, unlockMethod.y - 15, 120, 'Unlock Method:'));
        tab_group.add(new FlxText(ticketPercent.x, ticketPercent.y - 15, 120, 'Ticket Percent:'));
        tab_group.add(new FlxText(ticketWinPercent.x, ticketWinPercent.y - 15, 120, 'Ticket Win Percent:'));
        tab_group.add(unlockMethod);
        tab_group.add(accessibility);
        tab_group.add(unlockType);
        tab_group.add(progression_balancing);
        tab_group.add(deathlink);
        tab_group.add(ticketPercent);
        tab_group.add(ticketWinPercent);
    }

    function addSongsSettings()
    {
        var tab_group = box.getTab('Songs').menu;
        var objX = 10;
        var objY = 10;

        allowMods = new PsychUICheckBox(objX, objY, 'Allow Mods', 100, 
        function() 
        {
            gameSettings.mods_enabled = allowMods.checked;
            APEntryState.generateSongList();
            startingSong.selectedLabel = ''; //So it can reset
        });
        allowMods.checked = gameSettings.mods_enabled;

        objY += 50;
        startingSong = new PsychUIDropDownMenu(objX, objY, [''], function(id:Int, song:String)
        {
            gameSettings.starting_song = song;
        });
        startingSong.selectedLabel = gameSettings.starting_song;

        tab_group.add(new FlxText(startingSong.x, startingSong.y - 15, 120, 'Starting Song:'));
        tab_group.add(allowMods);
        tab_group.add(startingSong);
    }

    function addTrapsSettings()
    {
        var tab_group = box.getTab('Traps').menu;
        var objX = 10;
        var objY = 20;

        trapAmount = new PsychUISlider(objX, objY, function(v:Float) gameSettings.trapAmount = Std.int(v));
        trapAmount.min = 0;
        trapAmount.max = 60;
        trapAmount.decimals = 0;
        trapAmount.value = gameSettings.trapAmount;

        objY += 40;
        bbcWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.bbcWeight = Std.int(v));
        bbcWeight.min = 0;
        bbcWeight.max = 10;
        bbcWeight.decimals = 0;
        bbcWeight.value = gameSettings.bbcWeight;

        objY += 40;
        ghostChatWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.ghostChatWeight = Std.int(v));
        ghostChatWeight.min = 0;
        ghostChatWeight.max = 10;
        ghostChatWeight.decimals = 0;
        ghostChatWeight.value = gameSettings.ghostChatWeight;

        objY += 40;
        tutorialWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.svcWeight = Std.int(v));
        tutorialWeight.min = 0;
        tutorialWeight.max = 10;
        tutorialWeight.decimals = 0;
        tutorialWeight.value = gameSettings.svcWeight;

        objY += 40;
        svcWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.tutorialWeight = Std.int(v));
        svcWeight.min = 0;
        svcWeight.max = 10;
        svcWeight.decimals = 0;
        svcWeight.value = gameSettings.tutorialWeight;

        objY += 40;
        fakeTransWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.fakeTransWeight = Std.int(v));
        fakeTransWeight.min = 0;
        fakeTransWeight.max = 10;
        fakeTransWeight.decimals = 0;
        fakeTransWeight.value = gameSettings.fakeTransWeight;

        objY += 40;
        chartmodifierchance = new PsychUISlider(objX, objY, function(v:Float) gameSettings.chart_modifier_change_chance = Std.int(v));
        chartmodifierchance.min = 0;
        chartmodifierchance.max = 10;
        chartmodifierchance.decimals = 0;
        chartmodifierchance.value = gameSettings.chart_modifier_change_chance;

        objY += 40;
        shieldWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.shieldWeight = Std.int(v));
        shieldWeight.min = 0;
        shieldWeight.max = 10;
        shieldWeight.decimals = 0;
        shieldWeight.value = gameSettings.shieldWeight;

        objY += 40;
        MHPWeight = new PsychUISlider(objX, objY, function(v:Float) gameSettings.MHPWeight = Std.int(v));
        MHPWeight.min = 0;
        MHPWeight.max = 10;
        MHPWeight.decimals = 0;
        MHPWeight.value = gameSettings.MHPWeight;

        tab_group.add(new FlxText(chartmodifierchance.x, chartmodifierchance.y - 15, 300, 'Chart Modifier Chance:'));
        tab_group.add(new FlxText(trapAmount.x, trapAmount.y - 15, 300, 'Trap Amount:'));
        tab_group.add(new FlxText(bbcWeight.x, bbcWeight.y - 15, 300, 'Blue Balls Curse Trap Weight:'));
        tab_group.add(new FlxText(ghostChatWeight.x, ghostChatWeight.y - 15, 300, 'Ghost Chat Trap Weight:'));
        tab_group.add(new FlxText(tutorialWeight.x, tutorialWeight.y - 15, 300, 'Tutorial Trap Weight:'));
        tab_group.add(new FlxText(svcWeight.x, svcWeight.y - 15, 300, 'Streamer Vs. Chat Trap Weight:'));
        tab_group.add(new FlxText(fakeTransWeight.x, fakeTransWeight.y - 15, 300, 'Fake Transition Trap Weight:'));
        tab_group.add(new FlxText(shieldWeight.x, shieldWeight.y - 15, 300, 'Shield Item Weight:'));
        tab_group.add(new FlxText(MHPWeight.x, MHPWeight.y - 15, 300, 'Hax HP Item Weight:'));
        tab_group.add(chartmodifierchance);
        tab_group.add(trapAmount);
        tab_group.add(bbcWeight);
        tab_group.add(ghostChatWeight);
        tab_group.add(tutorialWeight);
        tab_group.add(svcWeight);
        tab_group.add(fakeTransWeight);
        tab_group.add(shieldWeight);
        tab_group.add(MHPWeight);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.BACK) close();
    }
}
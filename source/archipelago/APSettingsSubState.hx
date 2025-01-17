package archipelago;

import backend.ui.*;
import archipelago.APEntryState;
import archipelago.APInfo;
import flixel.util.FlxGradient;
import yaml.Yaml;
import yaml.Renderer;
import substates.Prompt;

class APSettingsSubState extends MusicBeatSubstate {
    public static var globalSongList:Array<String> = [];
    
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
    var gradientBar:FlxSprite;
    var dim:FlxSprite;

    public static function generateSongList(?type:String)
	{
        for (song in globalSongList)
            globalSongList.remove(song);
        switch (type)
        {
            case "A":
                globalSongList = APInfo.baseGame;    
                for (erect in APInfo.baseErect)
                    globalSongList.push(erect);
                for (pico in APInfo.basePico)
                    globalSongList.push(pico);
                for (secret in APInfo.secrets)
                    globalSongList.push(secret);
            case "B":
                if (APEntryState.gameSettings.FNF.mods_enabled)
                {
                    for (i in 0...WeekData.weeksList.length) {
                        var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
                        for (song in leWeek.songs)
                        {
                            globalSongList.remove(song[0]); // To remove dups
                            globalSongList.push(song[0]);
                            globalSongList.remove('Tutorial'); // To remove Tutorial because it keeps re-adding itself
                        }
                    }
                }
            case "Test":
                globalSongList = APInfo.baseGame;
            default:
                globalSongList = APInfo.baseGame; //This always resets the list to just base base game
                for (erect in APInfo.baseErect)
                    globalSongList.push(erect);
                for (pico in APInfo.basePico)
                    globalSongList.push(pico);
                for (secret in APInfo.secrets)
                    globalSongList.push(secret);
                if (APEntryState.gameSettings.FNF.mods_enabled)
                {
                    for (i in 0...WeekData.weeksList.length) {
                        var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
                        trace(leWeek.folder);
                        for (song in leWeek.songs)
                        {
                            globalSongList.remove(song[0]); // To remove dups
                            globalSongList.push(song[0]); // To add the folder name if it's not empty
                            globalSongList.remove(APEntryState.gameSettings.FNF.starting_song); // To remove Tutorial because it keeps re-adding itself
                        }
                    }
                }
        }
	}

    override function create() {
        dim = new FlxSprite().makeGraphic(FlxG.width*4, FlxG.height*4, 0x000000);
        dim.scrollFactor.set();
        dim.screenCenter();
        add(dim);
        dim.alpha = 0.5;

        box = new PsychUIBox(0, 0, 300, 480, ['Main Settings', 'Songs', 'Traps']);
		box.selectedName = 'Main Settings';
		box.scrollFactor.set();
        box.canMove = false;
        box.canMinimize = false;
        box.screenCenter();
		add(box);

        generateSongList();

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
            var tempList = globalSongList;
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
            APEntryState.gameSettings.FNF.progression_balancing = prog;
        });
        progression_balancing.selectedLabel = APEntryState.gameSettings.FNF.progression_balancing;

        accessibility = new PsychUIDropDownMenu(objX + 150, objY, [''], function(id:Int, acc:String)
        {
            APEntryState.gameSettings.FNF.accessibility = acc;
        });
        accessibility.selectedLabel = APEntryState.gameSettings.FNF.accessibility;

        objY += 50;
        unlockType = new PsychUIDropDownMenu(objX, objY, [''], function(id:Int, unlock:String)
        {
            APEntryState.gameSettings.FNF.unlock_type = unlock;
        });
        unlockType.selectedLabel = APEntryState.gameSettings.FNF.unlock_type;

        unlockMethod = new PsychUIDropDownMenu(objX + 150, objY, [''], function(id:Int, unlock:String)
        {
            APEntryState.gameSettings.FNF.unlock_method = unlock;
        });
        unlockMethod.selectedLabel = APEntryState.gameSettings.FNF.unlock_method;

        objY += 70;
        deathlink = new PsychUICheckBox(objX, objY, 'DeathLink', 100, function() APEntryState.gameSettings.FNF.deathlink = deathlink.checked);
        deathlink.checked = APEntryState.gameSettings.FNF.deathlink;
        
        objY += 50;
        ticketPercent = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.ticket_percentage = Std.int(v));
        ticketPercent.decimals = 0;
        ticketPercent.min = 10;
        ticketPercent.max = 50;
        ticketPercent.value = APEntryState.gameSettings.FNF.ticket_percentage;

        objY += 50;
        ticketWinPercent = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.ticket_win_percentage = Std.int(v));
        ticketWinPercent.decimals = 0;
        ticketWinPercent.min = 50;
        ticketWinPercent.max = 100;
        ticketWinPercent.value = APEntryState.gameSettings.FNF.ticket_win_percentage;

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
            APEntryState.gameSettings.FNF.mods_enabled = allowMods.checked;
            generateSongList();
            startingSong.selectedLabel = ''; //So it can reset
            var tempList = globalSongList;
            tempList.sort((a:String, b:String) -> (a.toUpperCase() < b.toUpperCase()) ? -1 : 1); //Sort alphabetically descending
            startingSong.list = tempList;
        });
        allowMods.checked = APEntryState.gameSettings.FNF.mods_enabled;

        objY += 50;
        startingSong = new PsychUIDropDownMenu(objX, objY, [''], function(id:Int, song:String)
        {
            APEntryState.gameSettings.FNF.starting_song = song;
        });
        startingSong.selectedLabel = APEntryState.gameSettings.FNF.starting_song;

        tab_group.add(new FlxText(startingSong.x, startingSong.y - 15, 120, 'Starting Song:'));
        tab_group.add(allowMods);
        tab_group.add(startingSong);
    }

    function addTrapsSettings()
    {
        var tab_group = box.getTab('Traps').menu;
        var objX = 10;
        var objY = 20;

        trapAmount = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.trapAmount = Std.int(v));
        trapAmount.min = 0;
        trapAmount.max = 60;
        trapAmount.decimals = 0;
        trapAmount.value = APEntryState.gameSettings.FNF.trapAmount;

        objY += 40;
        bbcWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.bbcWeight = Std.int(v));
        bbcWeight.min = 0;
        bbcWeight.max = 10;
        bbcWeight.decimals = 0;
        bbcWeight.value = APEntryState.gameSettings.FNF.bbcWeight;

        objY += 40;
        ghostChatWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.ghostChatWeight = Std.int(v));
        ghostChatWeight.min = 0;
        ghostChatWeight.max = 10;
        ghostChatWeight.decimals = 0;
        ghostChatWeight.value = APEntryState.gameSettings.FNF.ghostChatWeight;

        objY += 40;
        tutorialWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.svcWeight = Std.int(v));
        tutorialWeight.min = 0;
        tutorialWeight.max = 10;
        tutorialWeight.decimals = 0;
        tutorialWeight.value = APEntryState.gameSettings.FNF.svcWeight;

        objY += 40;
        svcWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.tutorialWeight = Std.int(v));
        svcWeight.min = 0;
        svcWeight.max = 10;
        svcWeight.decimals = 0;
        svcWeight.value = APEntryState.gameSettings.FNF.tutorialWeight;

        objY += 40;
        fakeTransWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.fakeTransWeight = Std.int(v));
        fakeTransWeight.min = 0;
        fakeTransWeight.max = 10;
        fakeTransWeight.decimals = 0;
        fakeTransWeight.value = APEntryState.gameSettings.FNF.fakeTransWeight;

        objY += 40;
        chartmodifierchance = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.chart_modifier_change_chance = Std.int(v));
        chartmodifierchance.min = 0;
        chartmodifierchance.max = 10;
        chartmodifierchance.decimals = 0;
        chartmodifierchance.value = APEntryState.gameSettings.FNF.chart_modifier_change_chance;

        objY += 40;
        shieldWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.shieldWeight = Std.int(v));
        shieldWeight.min = 0;
        shieldWeight.max = 10;
        shieldWeight.decimals = 0;
        shieldWeight.value = APEntryState.gameSettings.FNF.shieldWeight;

        objY += 40;
        MHPWeight = new PsychUISlider(objX, objY, function(v:Float) APEntryState.gameSettings.FNF.MHPWeight = Std.int(v));
        MHPWeight.min = 0;
        MHPWeight.max = 10;
        MHPWeight.decimals = 0;
        MHPWeight.value = APEntryState.gameSettings.FNF.MHPWeight;

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

    var testMap:Map<String, Dynamic>;
    function onGenYaml()
	{

        var yamlThing = {}
        for (thing in Reflect.fields(APEntryState.gameSettings.FNF))
        {
            Reflect.setField(yamlThing, thing, Reflect.field(APEntryState.gameSettings.FNF, thing));
        }

        globalSongList.remove(APEntryState.gameSettings.FNF.starting_song);
		APEntryState.gameSettings.FNF.songList = globalSongList;
        var mainSettings = {name: APEntryState.yamlName, description: APEntryState.gameSettings.description, game: APEntryState.gameSettings.game};
        var document = Yaml.render(mainSettings, Renderer.options().setFlowLevel(1));
		trace(document);

        if (Reflect.hasField(yamlThing, "ticket_percentage"))
            if (Reflect.field(yamlThing, "ticket_percentage") < 10)
                Reflect.setField(yamlThing, "ticket_percentage", 10);

        if (Reflect.hasField(yamlThing, "ticket_win_percentage"))
            if (Reflect.field(yamlThing, "ticket_win_percentage") < 50)
                Reflect.setField(yamlThing, "ticket_win_percentage", 50);

        if (Reflect.hasField(yamlThing, "unlock_type"))
            if (Reflect.field(yamlThing, "unlock_type") != "Per Song" && Reflect.field(yamlThing, "unlock_type") != "Per Week")
                Reflect.setField(yamlThing, "unlock_type", "Per Song");

        if (Reflect.hasField(yamlThing, "unlock_method"))
            if (Reflect.field(yamlThing, "unlock_method") != "Note Checks" && Reflect.field(yamlThing, "unlock_method") != "Song Completion" && Reflect.field(yamlThing, "unlock_method") != "Both")
                Reflect.setField(yamlThing, "unlock_method", "Song Completion");

        if (Reflect.hasField(yamlThing, "progression_balancing"))
            if (Reflect.field(yamlThing, "progression_balancing") != "disabled" && Reflect.field(yamlThing, "progression_balancing") != "normal" && Reflect.field(yamlThing, "progression_balancing") != "extreme")
                Reflect.setField(yamlThing, "progression_balancing", "normal");

        if (Reflect.hasField(yamlThing, "songList")) {
            var songList = Reflect.field(yamlThing, "songList");
            var uniqueSongList = new Array<String>();
            for (song in songList) {
            if (!uniqueSongList.contains(song)) {
                uniqueSongList.push(song);
            }
            }
            Reflect.setField(yamlThing, "songList", uniqueSongList);
        }


		#if sys
		// This time write that same document to disk and adjust the flow level giving
		// a more compact result.
		if (!FileSystem.exists("./PlayerSettings/"))
			FileSystem.createDirectory("./PlayerSettings/");
		Yaml.write("PlayerSettings/" + APEntryState.yamlName + ".yaml", mainSettings, Renderer.options().setFlowLevel(1));
		#end
		openSubState(new Prompt("Settings Exported Successfully!", 0, null, null, false));

        // Add actual settings.

        var yamlString = "Friday Night Funkin:\n";
        for (key in Reflect.fields(yamlThing)) {
            yamlString += "  " + key + ": " + Reflect.field(yamlThing, key) + "\n";
        }

        var finalDocument = document + "\n" + yamlString;
        trace(finalDocument);

        #if sys
        sys.io.File.saveContent("PlayerSettings/" + APEntryState.yamlName + ".yaml", finalDocument);
        #end
        close();
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.BACK) 
        {
            onGenYaml();
            FlxTween.num(0.0134, 1, 1, {ease: FlxEase.sineInOut}, function(t) {
                APEntryState.lowFilterAmount = t;
            });
        }
    }
}
package options;

import backend.window.Priority;

class OtherSettingsSubState extends BaseOptionsMenu
{
	public static var curBPMList:Array<Int> =  [0, 160, 105, 130, 100, 160, 180, 100, 125, 150, 140];
	public var priority:Int = 2;
	public function new()
	{
		priority = Priority.getPriority();
		title = 'Misc. Settings.';
		rpcTitle = 'Misc. Settings'; // for Discord Rich Presence

		var option:Option = new Option('Show Crash Dialogue',
			"If checked, The game will show a dialogue when it crashes.", 'showCrash', 'bool');
			addOption(option);

		var option:Option = new Option('Ignore Tween Errors',
			"If checked, The game will ignore tween errors.", 'ignoreTweenErrors', 'bool');
			addOption(option);

		var option:Option = new Option("Allow Force Quit",
			"If checked, The game will allow you to force quit the game.", 'allowForcedExit', 'bool');
			addOption(option);

		var option:Option = new Option('Game Priority',
			"Set the game's priority.\n Tells the game to change how it processes things.\nMakes it potentially take priority over other programs.", 'gamePriority', 'int');
			option.minValue = 0;
			option.maxValue = 5;
			option.defaultValue = 2;
			option.onChange = function()
			{
				backend.window.Priority.setPriority(ClientPrefs.data.gamePriority);
			};
			addOption(option);

			var option:Option = new Option('Force Priority', 'If checked, The game will force the priority.', 'forcePriority', 'bool');
			addOption(option);

		var option:ToggleOption = new ToggleOption('Test Togglable', 'A test.', 'testToggle', 'int', 0);
		option.defaultValue = 0;
		option.minValue = 0;
		option.maxValue = 10;
		//addOption(option);

		var maxThreads:Int = Std.parseInt(Sys.getEnv("NUMBER_OF_PROCESSORS"));
		if (maxThreads > 1)
		{
			var option:Option = new Option('Multi-thread Loading', // Name
				'--INCOMPLETE-- If checked, the mod can use multiple threads to speed up loading times on some songs.\nRecommended to leave on, unless it causes crashing', // Description
				'multicoreLoading', // Save data variable name
				'bool'); // Variable type
				addOption(option);

			var option:Option = new Option('Loading Threads', // Name
				'--INCOMPLETE-- How many threads the game can use to load graphics when using Multi-thread Loading.\nThe maximum amount of threads depends on your processor', // Description
				'loadingThreads', // Save data variable name
				'int'); // Variable type

			option.minValue = 1;
			option.maxValue = Std.parseInt(Sys.getEnv("NUMBER_OF_PROCESSORS"));
			option.displayFormat = '%v';

			addOption(option);
		}
		else
		{
			// if you guys ever add more options to misc that dont rely on the thread count
			var option:Option = new Option("Nothin' here!", // Name
				"Usually there'd be options about multi-thread loading, but you only have 1 thread to use so no real use", // Description
				'', // Save data variable name
				'label'); // Variable type
			addOption(option);
		}

		var option:Option = new Option('Cache Graphics', // even tho only one person asked, it here
			"If checked, The Graphics Will Be Cached.", 'graphicsPreload2', 'bool');
		addOption(option);

		var option:Option = new Option('Cache Music', // even tho only one person asked, it here
			"If checked, The Music Will Be Cached.", 'musicPreload2', 'bool');
		addOption(option); // now shut up before i put you in my basement

		var option:Option = new Option('Cache Videos', // even tho only one person asked, it here
			"If checked, The Videos Will Be Cached.", 'videoPreload2', 'bool');
		addOption(option); // now shut up before i put you in my basement

		var option:Option = new Option(
			'Silent Volume Noise', 
			"If checked, The volume wont make noise when you turn up/down the volume", 
			'silentVol', 
			'bool'
		);
		addOption(option);

		var option:Option = new Option(
			'Raise Volume Sound', 
			"The sound that plays when you change the volume.", 
			'volUp', 
			'string', 
			[
			"beep",
			"bfBeep",
			"cancelMenu",
			"clickText",
			"confirmMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"pixelText",
			"scrollMenu",
			"snd_hurt1",
			"txtSans",
			"Volup"]
		);
		addOption(option);
		option.onChange = onChangeSoundUp;
		option.displayFormat = '< %v >';

		var option:Option = new Option(
			'Lower Volume Sound', 
			"The sound that plays when you change the volume.", 
			'volDown', 
			'string', 
			[
			"beep",
			"bfBeep",
			"cancelMenu",
			"clickText",
			"confirmMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"pixelText",
			"scrollMenu",
			"snd_hurt1",
			"txtSans",
			"Voldown"]
		);
		addOption(option);
		option.onChange = onChangeSoundDown;
		option.displayFormat = '< %v >';

		var option:Option = new Option(
			'Max Volume Sound', 
			"The sound that plays when you reach max volume.", 
			'volMax', 
			'string', 
			[
			"beep",
			"bfBeep",
			"cancelMenu",
			"clickText",
			"confirmMenu",
			"dialogue",
			"dialogueClose",
			"GF_4",
			"hitsound",
			"Metronome_Tick",
			"pixelText",
			"scrollMenu",
			"snd_hurt1",
			"txtSans",
			"VolMAX"]
		);
		addOption(option);
		option.onChange = onChangeSoundMax;
		option.displayFormat = '< %v >';

		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time', 'Celebration', 'Drippy Genesis', 'Reglitch', 'False Memory', 'Funky Genesis', 'Late Night Cafe', 'Late Night Jersey', 'Silly Little Sample Song']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option(
			'Check For Updates', 
			"If checked, The engine will scan for updates", 
			'checkForUpdates', 
			'bool'
		);
		addOption(option);

		var option:Option = new Option('Allow Username Detection',
			"Uncheck this to prevent the game from leaking your computer name. Usually a good idea for streamers.",
			'username',
			'bool');
		addOption(option);

		var option:Option = new Option('Mix-Up Mode',
			"Have you ever hear of Funky Friday/Friday Night Bloxin'?\nWell is essentially that, except it's single player.",
			'mixupMode',
			'bool');
		addOption(option);

		var option:Option = new Option('Opp. Difficulty',
			"ONLY WORKS IF MIX-UP MODE IS ON!!!\nSet the level of how badly the opponent beats your butt.",
			'aiDifficulty',
			'string', 
			[
			"Baby Mode",
			"Easier",
			"Normal",
			"Harder",
			"Hardest",
			"Average FNF Player",
			"Dont"]
		);
		addOption(option);
		option.displayFormat = '< %v >';

		var option:Option = new Option('Break The Sticker Audio',
			"Literally just locks the sound to a funny bug I found.",
			'audioBreak',
			'bool');
		addOption(option);

		var option:Option = new Option('Enable Artemis', // even tho only one person asked, it here
			"Got An RGB Keyboard Like A Razer Cynosa Chroma Gaming Keyboard?\n
			Turn This Bad Boy On To Get Your Keyboard In The Action Too!\n
			(YOU MUST HAVE ARTEMIS INSTALLED AND THE PROFILE SET TO MIXTAPE FOR IT TO WORK!)\n
			(YOU WILL BE SENT TO THE TITLE SCREEN WHEN YOU LEAVE IF THIS IS ON!)", 'enableArtemis', 'bool');
		addOption(option);

		super();
	}

	var changedMusic:Bool = false;
	var indeed:Int = 0;
	function onChangePauseMusic()
	{
		switch (ClientPrefs.data.pauseMusic)
		{
			case 'None':
				indeed = 0;
			case 'Breakfast':
				indeed = 1;
			case 'Tea Time':
				indeed = 2;
			case 'Celebration':
				indeed = 3;
			case 'Drippy Genesis':
				indeed = 4;
			case 'Reglitch':
				indeed = 5;
			case 'False Memory':
				indeed = 6;
			case 'Funky Genesis':
				indeed = 7;
			case 'Late Night Cafe':
				indeed = 8;
			case 'Late Night Jersey':
				indeed = 9;
			case 'Silly Little Sample Song':
				indeed = 10;
		}
		/*
		if (controls.UI_RIGHT_P)
			indeed++;
		if (controls.UI_LEFT_P)
			indeed--;
		if (indeed < 0)
			indeed = curBPMList.length - 1;
		if (indeed >= curBPMList.length)
			indeed = 0;
		*/
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
		Conductor.bpm = curBPMList[indeed];
		ClientPrefs.data.pauseBPM = curBPMList[indeed];
	}

	function onChangeSoundDown()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound('soundtray/'+ClientPrefs.data.volDown), 1);
	}

	function onChangeSoundUp()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound('soundtray/'+ClientPrefs.data.volUp), 1);
	}

	function onChangeSoundMax()
	{
		if (!ClientPrefs.data.silentVol) FlxG.sound.play(Paths.sound('soundtray/'+ClientPrefs.data.volMax), 1);
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	override function update(e:Float)
	{
		super.update(e);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!ClientPrefs.data.forcePriority && backend.window.Priority.getPriority() != ClientPrefs.data.gamePriority){
			backend.window.Priority.setPriority(backend.window.Priority.getPriority()); priority = ClientPrefs.data.gamePriority;
		FlxG.resetState();}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom = zoomies;

		FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
			ease: FlxEase.quadOut
		});
	}
}

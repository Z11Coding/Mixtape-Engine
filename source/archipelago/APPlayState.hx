package archipelago;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import shaders.MosaicEffect;
import openfl.filters.BitmapFilter;
import flixel.tweens.misc.NumTween;
import flixel.input.keyboard.FlxKey;
import streamervschat.*;
import flixel.util.FlxDestroyUtil;
import objects.Character;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
class APPlayState extends PlayState {
    public static var effectiveScrollSpeed:Float;
	public static var effectiveDownScroll:Bool;
    public static var xWiggle:Array<Float> = [0, 0, 0, 0];
	public static var yWiggle:Array<Float> = [0, 0, 0, 0];
    public static var notePositions:Array<Int> = [0, 1, 2, 3];
    public static var validWords:Array<String> = [];
    public static var controlButtons:Array<String> = [];
    public static var ogScroll:Bool = ClientPrefs.data.downScroll;
    public var activeItems:Array<Int> = [0, 0, 0, 0]; // Shield, Curse, MHP, Traps
    public var archMode:Bool = false;
    public var itemAmount:Int = 0;
    public var midSwitched:Bool = false;
    public var severInputs:Array<Bool> = new Array<Bool>();
    public var lowFilterAmount:Float = 1;
	public var vocalLowFilterAmount:Float = 1;
    private var lastDifficultyName:String = '';
    private var invulnCount:Int = 0;
    private var debugKeysDodge:Array<FlxKey>;
    var curDifficulty:Int = -1;
    var effectsActive:Map<String, Int> = new Map<String, Int>();
    var effectTimer:FlxTimer = new FlxTimer();
	var randoTimer:FlxTimer = new FlxTimer();
    var drainHealth:Bool = false;
	var drunkTween:NumTween = null;
	var lagOn:Bool = false;
	var addedMP4s:Array<VideoHandlerMP4> = [];
	var flashbangTimer:FlxTimer = new FlxTimer();
	var errorMessages:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var noiseSound:FlxSound = new FlxSound();
	var camAngle:Float = 0;
	var dmgMultiplier:Float = 1;
	var delayOffset:Float = 0;
	var volumeMultiplier:Float = 1;
	var frozenInput:Int = 0;
	var blurEffect:MosaicEffect = new MosaicEffect();
	var spellPrompts:Array<SpellPrompt> = [];
    var terminateStep:Int = -1;
	var terminateMessage:FlxSprite = new FlxSprite();
	var terminateSound:FlxSound = new FlxSound();
	var terminateTimestamps:Array<TerminateTimestamp> = new Array<TerminateTimestamp>();
	var terminateCooldown:Bool = false;
	var shieldSprite:FlxSprite = new FlxSprite();
	var filters:Array<BitmapFilter> = [];
	var filtersGame:Array<BitmapFilter> = [];
	var filtersHUD:Array<BitmapFilter> = [];
	var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}>;
	var picked:Int = 0;
    var wordList:Array<String> = [];
	var nonoLetters:String = "";
	var effectArray:Array<String> = [
		'colorblind', 'blur', 'lag', 'mine', 'warning', 'heal', 'spin', 'songslower', 'songfaster', 'scrollswitch', 'scrollfaster', 'scrollslower', 'rainbow',
		'cover', 'ghost', 'flashbang', 'nostrum', 'jackspam', 'spam', 'sever', 'shake', 'poison', 'dizzy', 'noise', 'flip', 'invuln',
		'desync', 'mute', 'ice', 'randomize', 'fakeheal', 'spell', 'terminate', 'lowpass', 'songSwitch'
	];
	var curEffect:Int = 0;

    function generateGibberish(length:Int, exclude:String):String
	{
		var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
		var result:String = "";

		// Remove excluded characters from the alphabet
		for (i in 0...exclude.length)
		{
			alphabet = StringTools.replace(alphabet, exclude.charAt(i), "");
		}

		// Generate the gibberish string
		for (i in 0...length)
		{
			var randomIndex:Int = Math.floor(Math.random() * alphabet.length);
			result += alphabet.charAt(randomIndex);
		}

		return result;
	}

    override public function create()
    {
        if (FlxG.save.data.closeDuringOverRide == null) FlxG.save.data.closeDuringOverRide = false;
        if (FlxG.save.data.manualOverride == null) FlxG.save.data.manualOverride = false;
        if (APEntryState.inArchipelagoMode)
        {
            if (FlxG.save.data.activeItems != null)
                activeItems = FlxG.save.data.activeItems;
            if (FlxG.save.data.activeItems == null)
            {
                activeItems[3] = FlxG.random.int(0, 9);
                activeItems[2] = Std.int(MaxHP);
            }
        }

        debugKeysDodge = ClientPrefs.keyBinds.get('dodge').copy();

		effectiveScrollSpeed = 1;
		effectiveDownScroll = ClientPrefs.data.downScroll;
		notePositions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17];
        blurEffect.setStrength(0, 0);
        addNonoLetters('note_left');
		addNonoLetters('note_down');
		addNonoLetters('note_up');
		addNonoLetters('note_right');
		addNonoLetters('reset');
        trace(nonoLetters);
        if (FileSystem.exists(Paths.txt("words")))
		{
			var content:String = sys.io.File.getContent(Paths.txt("words"));
			wordList = content.toLowerCase().split("\n");
		}
        wordList.push(PlayState.SONG.song);
		trace(wordList.length + " words loaded");
		trace(wordList);
		validWords.resize(0);
		for (word in wordList)
		{
			var containsNonoLetter:Bool = false;
			var nonoLettersArray:Array<String> = nonoLetters.split("");

			for (nonoLetter in nonoLettersArray)
			{
				if (word.contains(nonoLetter))
				{
					containsNonoLetter = true;
					break;
				}
			}

			if (!containsNonoLetter)
			{
				validWords.push(word.toLowerCase());
			}
		}

		if (validWords.length <= 0)
		{
			trace("wtf no valid words");
			var numWords:Int = 10; // Number of words to generate

			validWords = [for (i in 0...numWords) generateGibberish(5, nonoLetters)];
		}
		trace(validWords.length + " words accepted");
		trace(validWords);
		controlButtons.resize(0);
		for (thing in [
            ClientPrefs.keyBinds.get('note_left').copy().toString(),
            ClientPrefs.keyBinds.get('note_down').copy().toString(),
            ClientPrefs.keyBinds.get('note_up').copy().toString(),
            ClientPrefs.keyBinds.get('note_right').copy().toString(),
            ClientPrefs.keyBinds.get('reset').copy().toString(),
			"LEFT",
			"RIGHT",
			"UP",
			"DOWN",
			"SEVEN",
			"EIGHT",
			"NINE"
		])
		{
			controlButtons.push(StringTools.trim(thing).toLowerCase());
		}

        if (archMode)
        {
            if (FlxG.save.data.activeItems == null)
            {
                if (activeItems[3] != 0)
                {
                    switch activeItems[3]
                    {
                        case 1:
                            chartModifier = 'Flip';
                        case 2:
                            chartModifier = 'Random';
                        case 3:
                            chartModifier = 'Stairs';
                        case 4:
                            chartModifier = 'Wave';
                        case 5:
                            chartModifier = 'SpeedRando';
                        case 6:
                            chartModifier = 'Amalgam';
                        case 7:
                            chartModifier = 'Trills';
                        case 8:
                            chartModifier = "SpeedUp";
                        case 9:
                            if (PlayState.SONG.mania == 3)
                            {
                                chartModifier = "ManiaConverter";
                                convertMania = FlxG.random.int(4, Note.maxMania);
                            }
                            else
                            {
                                chartModifier = "4K Only";
                            }
                    }
                }
                if (chartModifier == "ManiaConverter")
                {
                    ArchPopup.startPopupCustom("convertMania value is:", "" + convertMania + "", 'Color');
                }

                ArchPopup.startPopupCustom('You Got an Item!', "Chart Modifier Trap (" + chartModifier + ")", 'Color');
            }
            MaxHP = activeItems[2];
        }

        filterMap = [
            "Grayscale" => {
                var matrix:Array<Float> = [
                    0.5, 0.5, 0.5, 0, 0,
                    0.5, 0.5, 0.5, 0, 0,
                    0.5, 0.5, 0.5, 0, 0,
                        0,   0,   0, 1, 0,
                ];

                {filter: new ColorMatrixFilter(matrix)}
            },
            "BlurLittle" => {
                filter: new BlurFilter()
            }
        ];

        super.create();

        terminateSound = new FlxSound().loadEmbedded(Paths.sound('beep'));
        FlxG.sound.list.add(terminateSound);

        terminateMessage.visible = false;
        add(terminateMessage);

        errorMessages.cameras = [camOther];
		add(errorMessages);

        for (i in 0...PlayState.mania + 1) {
			severInputs.push(false);
		}

        itemAmount = FlxG.random.int(1, 100);
        trace('Max Items = ' + 100);
        trace('itemAmount:' + itemAmount);

        if (PlayState.isPixelStage)
		{
			shieldSprite.loadGraphic(Paths.image("streamervschat/pixelUI/shield"));
			shieldSprite.alpha = 0.85;
			shieldSprite.setGraphicSize(Std.int(shieldSprite.width * PlayState.daPixelZoom));
			shieldSprite.updateHitbox();
			shieldSprite.antialiasing = false;
		}
		else
		{
			shieldSprite.loadGraphic(Paths.image("streamervschat/shield"));
			shieldSprite.alpha = 0.85;
			shieldSprite.scale.x = shieldSprite.scale.y = 0.8;
			shieldSprite.updateHitbox();
		}
		shieldSprite.visible = false;
    }

    public static var startOnTime:Float = 0;
	public var camMovement:Float = 40;
	public var velocity:Float = 1;
	public var campointx:Float = 0;
	public var campointy:Float = 0;
	public var camlockx:Float = 0;
	public var camlocky:Float = 0;
	public var camlock:Bool = false;
	public var bfturn:Bool = false;
    public var stuck:Bool = false;
    public var did:Int = 0;

    override public function startCountdown():Bool
    {
        if (PlayState.SONG.player1.toLowerCase().contains('zenetta') || PlayState.SONG.player2.toLowerCase().contains('zenetta') || PlayState.SONG.gfVersion.toLowerCase().contains('zenetta'))
        {
            itemAmount = 69;
            trace("RESISTANCE OVERRIDE!"); // what are the chances
        }
        // Check if there are any mustPress notes available
        if (unspawnNotes.filter(function(note:Note):Bool
        {
            return note.mustPress && note.noteType == '' && !note.isSustainNote;
        }).length == 0)
        {
            trace('No mustPress notes found. Pausing Note Generation...');
            trace('Waiting for Note Scripts...');
        }
        else
        {
            while (did < itemAmount && !stuck)
            {
                var foundOne:Bool = false;

                for (i in 0...unspawnNotes.length)
                {
                    if (did >= itemAmount)
                    {
                        break; // exit the loop if the required number of notes are created
                    }
                    if (unspawnNotes[i].mustPress
                        && unspawnNotes[i].noteType == ''
                        && !unspawnNotes[i].isSustainNote
                        && FlxG.random.bool(1)
                        && unspawnNotes.filter(function(note:Note):Bool
                        {
                            return note.mustPress && note.noteType == '' && !note.isSustainNote;
                        }).length != 0)

                    {
                        unspawnNotes[i].isCheck = true;
                        unspawnNotes[i].noteType = 'Check Note';
                        did++;
                        foundOne = true;
                        Sys.print('\rGenerating Checks: ' + did + '/' + itemAmount);
                    }
                    else if (unspawnNotes.filter(function(note:Note):Bool
                    {
                        return note.mustPress && note.noteType == '' && !note.isSustainNote;
                    }).length == 0)
                    {
                        Sys.println('');
                        trace('Stuck!');
                        stuck = true;
                        // Additional handling for when it gets stuck
                    }
                }
                // Check if there are no more mustPress notes of type '' and not isSustainNote
                if (stuck)
                {
                    Sys.println('');
                    trace('No more mustPress notes of type \'\' found. Pausing Note Generation...');
                    trace('Waiting for Note Scripts...');
                    break; // exit the loop if no more mustPress notes of type '' are found
                }
            }
        }
        for (i in 0...unspawnNotes.length)
        {
            if (unspawnNotes[i].noteType == 'Hurt Note') unspawnNotes[i].reloadNote('HURT');
        }
        Sys.println('');
        startOnTime = FlxG.save.data.songPos;
        super.startCountdown();
        return true;
    }

    override function startSong()
    {
        effectTimer.start(5, function(timer)
        {
            if (paused)
                return;
            if (startingSong)
                return;
            if (endingSong)
                return;
        }, 0);

        randoTimer.start(FlxG.random.float(5, 10), function(tmr:FlxTimer)
        {
            if (curEffect <= 37) doEffect(effectArray[curEffect]);
            else if (curEffect >= 37 && archMode)
            {
                switch (curEffect)
                {
                    case 38:
                        activeItems[0] += 1;
                        ArchPopup.startPopupCustom('You Got an Item!', '+1 Shield ( ' + activeItems[0] + ' Left)', 'Color');
                    case 39:
                        activeItems[1] = 1;
                        ArchPopup.startPopupCustom('You Got an Item!', "Blue Ball's Curse", 'Color');
                    case 40:
                        activeItems[2] += 1;
                        ArchPopup.startPopupCustom('You Got an Item!', "Max HP Up!", 'Color');
                }
            }
            tmr.reset(FlxG.random.float(5, 10));
        });
        super.startSong();
    }

    function addNonoLetters(keyBind:String) {
        var keys:Null<Array<FlxKey>> = ClientPrefs.keyBinds.get(keyBind);
        if (keys != null) {
            for (key in keys) {
                var keyName:String = InputFormatter.getKeyName(key);
                if (keyName.length == 1 && keyName != "-") {
                    nonoLetters += keyName.toLowerCase();
                }
            }
        }
    }

    override function destroy()
	{
		if (drunkTween != null && drunkTween.active)
		{
			drunkTween.cancel();
		}

		if (effectTimer != null && effectTimer.active)
			effectTimer.cancel();
		if (randoTimer != null && randoTimer.active)
			randoTimer.cancel();

		super.destroy();
	}

    var oldRate:Int = 60;
	var noIcon:Bool = false;

	function doEffect(effect:String)
	{
		if (paused)
			return;
		if (endingSong)
			return;

		var ttl:Float = 0;
		var onEnd:(Void->Void) = null;
		var alwaysEnd:Bool = false;
		var playSound:String = "";
		var playSoundVol:Float = 1;
		// trace(effect);
		switch (effect)
		{
			case 'colorblind':
				filters.push(filterMap.get("Grayscale").filter);
				filtersGame.push(filterMap.get("Grayscale").filter);
				playSound = "colorblind";
				playSoundVol = 0.8;
				ttl = 16;
				onEnd = function()
				{
					filters.remove(filterMap.get("Grayscale").filter);
					filtersGame.remove(filterMap.get("Grayscale").filter);
				}
				noIcon = false;
			case 'blur':
				if (effectsActive[effect] == null || effectsActive[effect] <= 0)
				{
					filtersGame.push(filterMap.get("BlurLittle").filter);
					if (PlayState.curStage.startsWith('school'))
						blurEffect.setStrength(2, 2);
					else
						blurEffect.setStrength(32, 32);
					strumLineNotes.forEach(function(sprite)
					{
						sprite.shader = blurEffect.shader;
					});
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.shader = blurEffect.shader;
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						else
							daNote.shader = blurEffect.shader;
					}
					boyfriend.shader = blurEffect.shader;
					dad.shader = blurEffect.shader;
					if (gf != null) gf.shader = blurEffect.shader;
				}
				noIcon = false;
				playSound = "blur";
				playSoundVol = 0.7;
				ttl = 12;
				onEnd = function()
				{
					strumLineNotes.forEach(function(sprite)
					{
						sprite.shader = null;
					});
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.shader = null;
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						else
							daNote.shader = null;
					}
					boyfriend.shader = null;
					dad.shader = null;
					if(gf != null) gf.shader = null;
					blurEffect.setStrength(0, 0);
					filtersGame.remove(filterMap.get("BlurLittle").filter);
				}
			case 'lag':
				noIcon = false;
				lagOn = true;
				playSound = "lag";
				playSoundVol = 0.7;
				ttl = 12;
				onEnd = function()
				{
					lagOn = false;
				}
			case 'mine':
				noIcon = true;
				var startPoint:Int = FlxG.random.int(5, 9);
				var nextPoint:Int = FlxG.random.int(startPoint + 2, startPoint + 6);
				var lastPoint:Int = FlxG.random.int(nextPoint + 2, nextPoint + 6);
				addNote(1, startPoint, startPoint);
				addNote(1, nextPoint, nextPoint);
				addNote(1, lastPoint, lastPoint);
			case 'warning':
				noIcon = true;
				var startPoint:Int = FlxG.random.int(5, 9);
				var nextPoint:Int = FlxG.random.int(startPoint + 2, startPoint + 6);
				var lastPoint:Int = FlxG.random.int(nextPoint + 2, nextPoint + 6);
				addNote(2, startPoint, startPoint, -1);
				addNote(2, nextPoint, nextPoint, -1);
				addNote(2, lastPoint, lastPoint, -1);
			case 'heal':
				noIcon = true;
				addNote(3, 5, 9);
			case 'spin':
				noIcon = false;
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						daNote.spinAmount = (FlxG.random.bool() ? 1 : -1) * FlxG.random.float(333 * 0.8, 333 * 1.15);
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					if (!daNote.isSustainNote)
						daNote.spinAmount = (FlxG.random.bool() ? 1 : -1) * FlxG.random.float(333 * 0.8, 333 * 1.15);
				}
				playSound = "spin";
				ttl = 15;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						{
							daNote.spinAmount = 0;
							daNote.angle = 0;
						}
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						if (!daNote.isSustainNote)
						{
							daNote.spinAmount = 0;
							daNote.angle = 0;
						}
					}
				}
			case 'songslower':
				noIcon = false;
				var desiredChangeAmount:Float = FlxG.random.float(0.1, 0.9);
				var changeAmount = playbackRate - Math.max(playbackRate - desiredChangeAmount, 0.2);
				set_playbackRate(playbackRate - changeAmount);
				playbackRate - changeAmount;
				trace(playbackRate);
				playSound = "songslower";
				ttl = 15;
				alwaysEnd = true;
				onEnd = function()
				{
					set_playbackRate(playbackRate + changeAmount);
					playbackRate + changeAmount;
				};
			case 'songfaster':
				noIcon = false;
				var changeAmount:Float = FlxG.random.float(0.1, 0.9);
				set_playbackRate(playbackRate + changeAmount);
				playbackRate + changeAmount;
				playSound = "songfaster";
				ttl = 15;
				alwaysEnd = true;
				onEnd = function()
				{
					set_playbackRate(playbackRate - changeAmount);
					playbackRate - changeAmount;
				};
			case 'scrollswitch':
				noIcon = false;
				effectiveDownScroll = !effectiveDownScroll;
				playSound = "scrollswitch";
				updateScrollUI();
			case 'scrollfaster':
				noIcon = false;
				var changeAmount:Float = FlxG.random.float(1.1, 3);
				effectiveScrollSpeed += changeAmount;
				songSpeed = PlayState.SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * effectiveScrollSpeed;
				playSound = "scrollfaster";
				ttl = 20;
				alwaysEnd = true;
				onEnd = function() {
					effectiveScrollSpeed -= changeAmount;
					songSpeed = PlayState.SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * effectiveScrollSpeed;
				}
			case 'scrollslower':
				noIcon = false;
				var changeAmount:Float = FlxG.random.float(0.1, 0.9);
				effectiveScrollSpeed -= changeAmount;
				songSpeed = PlayState.SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * effectiveScrollSpeed;
				playSound = "scrollslower";
				ttl = 20;
				alwaysEnd = true;
				onEnd = function() {
					effectiveScrollSpeed += changeAmount;
					songSpeed = PlayState.SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * effectiveScrollSpeed;
				}
			case 'rainbow':
				noIcon = false;
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						daNote.setColorTransform(1, 1, 1, 1, FlxG.random.int(-255, 255), FlxG.random.int(-255, 255), FlxG.random.int(-255, 255));
					else if (daNote.strumTime >= Conductor.songPosition && daNote.isSustainNote)
						daNote.setColorTransform(1, 1, 1, 1, Std.int(daNote.prevNote.colorTransform.redOffset),
							Std.int(daNote.prevNote.colorTransform.greenOffset), Std.int(daNote.prevNote.colorTransform.blueOffset));
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.setColorTransform(1, 1, 1, 1, FlxG.random.int(-255, 255), FlxG.random.int(-255, 255), FlxG.random.int(-255, 255));
				}
				playSound = "rainbow";
				playSoundVol = 0.5;
				ttl = 20;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.setColorTransform();
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.setColorTransform();
					}
				};
			case 'cover':
				noIcon = false;
				var errorMessage = new FlxSprite();
				var random = FlxG.random.int(0, 13);
				var randomPosition:Bool = true;

				switch (random)
				{
					case 0:
						errorMessage.loadGraphic(Paths.image("zzzzzzzz"));
						errorMessage.scale.x = errorMessage.scale.y = 0.5;
						errorMessage.updateHitbox();
						playSound = "bell";
						playSoundVol = 0.6;
					case 1:
						errorMessage.loadGraphic(Paths.image("scam"));
						playSound = 'scam';
					case 2:
						errorMessage.loadGraphic(Paths.image("funnyskeletonman"));
						playSound = 'doot';
						errorMessage.scale.x = errorMessage.scale.y = 0.8;
					case 3:
						errorMessage.loadGraphic(Paths.image("error"));
						playSound = 'error';
						errorMessage.scale.x = errorMessage.scale.y = 0.8;
						errorMessage.antialiasing = true;
						errorMessage.updateHitbox();
					case 4:
						errorMessage.loadGraphic(Paths.image("nopunch"));
						playSound = 'nopunch';
						errorMessage.scale.x = errorMessage.scale.y = 0.8;
						errorMessage.antialiasing = true;
						errorMessage.updateHitbox();
					case 5:
						errorMessage.loadGraphic(Paths.image("banana"), true, 397, 750);
						errorMessage.animation.add("dance", [0, 1, 2, 3, 4, 5, 6, 7, 8], 9, true);
						errorMessage.animation.play("dance");
						playSound = 'banana';
						playSoundVol = 0.5;
						errorMessage.scale.x = errorMessage.scale.y = 0.5;
					case 6:
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('mark'), null, false, false).setDimensions(378, 362);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
					case 7:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('fireworks'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'firework';
					case 8:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('spiral'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'spiral';
					case 9:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('thingy'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'thingy';
					case 10:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('light'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'light';
					case 11:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('snow'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'snow';
						playSoundVol = 0.6;
					case 12:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('spiral2'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'spiral';
					case 13:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('wheel'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'wheel';
				}

				if (randomPosition)
				{
					var position = FlxG.random.int(0, 4);
					switch (position)
					{
						case 0:
							errorMessage.x = (FlxG.width - FlxG.width / 4) - errorMessage.width / 2;
							errorMessage.screenCenter(Y);
							errorMessages.add(errorMessage);
						case 1:
							errorMessage.x = (FlxG.width - FlxG.width / 4) - errorMessage.width / 2;
							errorMessage.y = (effectiveDownScroll ? FlxG.height - errorMessage.height : 0);
							errorMessages.add(errorMessage);
						case 2:
							errorMessage.x = (FlxG.width - FlxG.width / 4) - errorMessage.width / 2;
							errorMessage.y = (effectiveDownScroll ? 0 : FlxG.height - errorMessage.height);
							errorMessages.add(errorMessage);
						case 3:
							errorMessage.screenCenter(XY);
							errorMessages.add(errorMessage);
						case 4:
							errorMessage.x = 0;
							errorMessage.y = 0;
							FlxTween.circularMotion(errorMessage, FlxG.width / 2 - errorMessage.width / 2, FlxG.height / 2 - errorMessage.height / 2,
								errorMessage.width / 2, 0, true, 6, true, {
									onStart: function(_)
									{
										errorMessages.add(errorMessage);
									},
									type: LOOPING
								});
					}
				}

				ttl = 12;
				alwaysEnd = true;
				onEnd = function()
				{
					errorMessage.kill();
					errorMessages.remove(errorMessage);
					FlxDestroyUtil.destroy(errorMessage);
				}

			case 'ghost':
				noIcon = false;
				modManager.setValue('stealth', 1);
				playSound = "ghost";
				playSoundVol = 0.5;
				ttl = 15;
				onEnd = function()
				{
					modManager.setValue('stealth', 0);
				};
			case 'flashbang':
				noIcon = true;
				playSound = "bang";
				if (flashbangTimer != null && flashbangTimer.active)
					flashbangTimer.cancel();
				var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				whiteScreen.scrollFactor.set();
				whiteScreen.cameras = [camOther];
				add(whiteScreen);
				flashbangTimer.start(0.4, function(timer)
				{
					camOther.flash(FlxColor.WHITE, 7, null, true);
					remove(whiteScreen);
					FlxG.sound.play(Paths.sound('ringing'), 0.4);
				});

			case 'nostrum':
				noIcon = false;
				for (i in 0...playerStrums.length)
					playerStrums.members[i].visible = false;
				playSound = "nostrum";
				ttl = 13;
				onEnd = function()
				{
					for (i in 0...playerStrums.length)
						playerStrums.members[i].visible = true;
				}
			case 'jackspam':
				noIcon = true;
				var startingPoint = FlxG.random.int(5, 9);
				var endingPoint = FlxG.random.int(startingPoint + 6, startingPoint + 12);
				var dataPicked = FlxG.random.int(0, PlayState.mania);
				for (i in startingPoint...endingPoint)
				{
					addNote(0, i, i, dataPicked);
				}
			case 'spam':
				noIcon = true;
				var startingPoint = FlxG.random.int(5, 9);
				var endingPoint = FlxG.random.int(startingPoint + 5, startingPoint + 10);
				for (i in startingPoint...endingPoint)
				{
					addNote(0, i, i);
				}
			case 'sever':
				noIcon = false;
				var chooseFrom:Array<Int> = [];
				for (i in 0...severInputs.length)
				{
					if (!severInputs[i])
						chooseFrom.push(i);
				}
				if (chooseFrom.length <= 0)
					picked = FlxG.random.int(0, 3);
				else
					picked = chooseFrom[FlxG.random.int(0, chooseFrom.length - 1)];
				playerStrums.members[picked].alpha = 0;
				severInputs[picked] = true;

				var okayden:Array<Int> = [];
				for (i in 0...64)
				{
					okayden.push(i);
				}
				var explosion = new FlxSprite().loadGraphic(Paths.image("explosion"), true, 256, 256);
				explosion.animation.add("boom", okayden, 60, false);
				explosion.animation.finishCallback = function(name)
				{
					explosion.visible = false;
					explosion.kill();
					remove(explosion);
					FlxDestroyUtil.destroy(explosion);
				};
				explosion.cameras = [camHUD];
				explosion.x = playerStrums.members[picked].x + playerStrums.members[picked].width / 2 - explosion.width / 2;
				explosion.y = playerStrums.members[picked].y + playerStrums.members[picked].height / 2 - explosion.height / 2;
				explosion.animation.play("boom", true);
				add(explosion);

				playSound = "sever";
				ttl = 6;
				alwaysEnd = true;
				onEnd = function()
				{
					playerStrums.members[picked].alpha = 1;
					severInputs[picked] = false;
				}
			case 'shake':
				noIcon = false;
				playSound = "shake";
				playSoundVol = 0.5;
				camHUD.shake(FlxG.random.float(0.03, 0.06), 9, null, true);
				camGame.shake(FlxG.random.float(0.03, 0.06), 9, null, true);
			case 'poison':
				noIcon = false;
				drainHealth = true;
				playSound = "poison";
				playSoundVol = 0.6;
				ttl = 5;
				boyfriend.color = 0xf003fc;
				onEnd = function()
				{
					drainHealth = false;
					boyfriend.color = 0xffffff;
				}
			case 'dizzy':
				noIcon = false;
				if (effectsActive[effect] == null || effectsActive[effect] <= 0)
				{
					if (drunkTween != null && drunkTween.active)
					{
						drunkTween.cancel();
						FlxDestroyUtil.destroy(drunkTween);
					}
					drunkTween = FlxTween.num(0, 24, FlxG.random.float(1.2, 1.4), {
						onUpdate: function(tween)
						{
							camHUD.angle = (tween.executions % 4 > 1 ? 1 : -1) * cast(tween, NumTween).value + camAngle;
							camGame.angle = (tween.executions % 4 > 1 ? -1 : 1) * cast(tween, NumTween).value / 2 + camAngle;
						},
						type: PINGPONG
					});
				}

				playSound = "dizzy";
				ttl = 8;
				onEnd = function()
				{
					if (drunkTween != null && drunkTween.active)
					{
						drunkTween.cancel();
						FlxDestroyUtil.destroy(drunkTween);
					}
					camHUD.angle = camAngle;
					camGame.angle = camAngle;
				}
			case 'noise':
				noIcon = false;
				var noisysound:String = "";
				var noisysoundVol:Float = 1.0;
				switch (FlxG.random.int(0, 9))
				{
					case 0:
						noisysound = "dialup";
						noisysoundVol = 0.5;
					case 1:
						noisysound = "crowd";
						noisysoundVol = 0.3;
					case 2:
						noisysound = "airhorn";
						noisysoundVol = 0.6;
					case 3:
						noisysound = "copter";
						noisysoundVol = 0.5;
					case 4:
						noisysound = "magicmissile";
						noisysoundVol = 0.9;
					case 5:
						noisysound = "ping";
						noisysoundVol = 1.0;
					case 6:
						noisysound = "call";
						noisysoundVol = 1.0;
					case 7:
						noisysound = "knock";
						noisysoundVol = 1.0;
					case 8:
						noisysound = "fuse";
						noisysoundVol = 0.7;
					case 9:
						noisysound = "hallway";
						noisysoundVol = 0.9;
				}
				noiseSound.stop();
				noiseSound.loadEmbedded(Paths.sound(noisysound));
				noiseSound.volume = noisysoundVol;
				noiseSound.play(true);

			case 'flip':
				noIcon = false;
				playSound = "flip";
				ttl = 5;
				camAngle = 180;
				camHUD.angle = camAngle;
				camGame.angle = camAngle;
				onEnd = function()
				{
					camAngle = 0;
					camHUD.angle = camAngle;
					camGame.angle = camAngle;
				}
			case 'invuln':
				noIcon = false;
				playSound = "invuln";
				playSoundVol = 0.5;
				ttl = 5;
				if (boyfriend.curCharacter.contains("pixel"))
				{
					shieldSprite.x = boyfriend.x + boyfriend.width / 2 - shieldSprite.width / 2 - 150;
					shieldSprite.y = boyfriend.y + boyfriend.height / 2 - shieldSprite.height / 2 - 150;
				}
				else
				{
					shieldSprite.x = boyfriend.x + boyfriend.width / 2 - shieldSprite.width / 2;
					shieldSprite.y = boyfriend.y + boyfriend.height / 2 - shieldSprite.height / 2;
				}
				shieldSprite.visible = true;
				dmgMultiplier = 0;
				onEnd = function()
				{
					shieldSprite.visible = false;
					dmgMultiplier = 1.0;
				}

			case 'desync':
				noIcon = true;
				playSound = "delay";
				delayOffset = FlxG.random.int(Std.int(Conductor.stepCrochet), Std.int(Conductor.stepCrochet) * 3);
				FlxG.sound.music.time -= delayOffset;
				resyncVocals();

				ttl = 8;
				onEnd = function()
				{
					FlxG.sound.music.time += delayOffset;
					delayOffset = 0;
				}

			case 'mute':
				noIcon = true;
				playSound = "delay";
				if (FlxG.random.bool(15)) 
				{
					FlxG.sound.music.volume = 0;
				}
				else 
				{
					volumeMultiplier = 0;
					vocals.volume = 0;
				}
				ttl = 8;
				onEnd = function()
				{
					FlxG.sound.music.volume = 1;
					volumeMultiplier = 1;
				}

			case 'ice':
				noIcon = true;
				var startPoint:Int = FlxG.random.int(5, 9);
				var nextPoint:Int = FlxG.random.int(startPoint + 2, startPoint + 6);
				var lastPoint:Int = FlxG.random.int(nextPoint + 2, nextPoint + 6);
				addNote(4, startPoint, startPoint, -1);
				addNote(4, nextPoint, nextPoint, -1);
				addNote(4, lastPoint, lastPoint, -1);

			case 'randomize':
				noIcon = false;
				var available:Array<Int> = [];
				for (i in 0...PlayState.mania+1) {
					available.push(i);
					trace("available: " + available);
				}
				FlxG.random.shuffle(available);
				switch (available)
				{
					case [0, 1, 2, 3]:
						available = [3, 2, 1, 0];
					default:
				}

				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition)
					{
						daNote.noteData = available[daNote.noteData];
					}
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					else
					{
						daNote.noteData = available[daNote.noteData];
					}
				}

				playSound = "randomize";
				playSoundVol = 0.7;
				ttl = 10;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
						{
							daNote.noteData = daNote.trueNoteData;
						}
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						else
						{
							daNote.noteData = daNote.trueNoteData;
						}
					}
				}

			case 'fakeheal':
				noIcon = true;
				addNote(5, 5, 9);

			case 'spell':
				noIcon = false;
				var spellThing = new SpellPrompt();
				spellPrompts.push(spellThing);
				playSound = "spell";
				playSoundVol = 0.66;

			case 'terminate':
				noIcon = true;
				terminateStep = 3;

			case 'lowpass':
				noIcon = true;
				if (FlxG.random.bool(40)) 
				{
					lowFilterAmount = .0134;
					filtersGame.push(filterMap.get("BlurLittle").filter);
					blurEffect.setStrength(32, 32);
				
				}
				else 
				{
					vocalLowFilterAmount = .0134;
					filtersHUD.push(filterMap.get("BlurLittle").filter);
					filters.push(filterMap.get("BlurLittle").filter);
					blurEffect.setStrength(32, 32);
				}
				playSound = "delay";
				playSoundVol = 0.6;
				ttl = 10;
				onEnd = function()
				{
					blurEffect.setStrength(0, 0);
					filtersHUD.remove(filterMap.get("BlurLittle").filter);
					filtersGame.remove(filterMap.get("BlurLittle").filter);
					filters.remove(filterMap.get("BlurLittle").filter);
					lowFilterAmount = 1;
					vocalLowFilterAmount = 1;
				}

			case 'songSwitch':
				//save everything first
				if (FlxG.save.data.manualOverride != null && FlxG.save.data.manualOverride == false) 
					FlxG.save.data.manualOverride = true;
				else if (FlxG.save.data.manualOverride != null && FlxG.save.data.manualOverride == true) 
					FlxG.save.data.manualOverride = false;

				trace('MANUAL OVERRIDE: ' + FlxG.save.data.manualOverride);

				if (FlxG.save.data.manualOverride)
				{
					FlxG.save.data.storyWeek = PlayState.storyWeek;
					FlxG.save.data.currentModDirectory = Mods.currentModDirectory;
					FlxG.save.data.difficulties = Difficulty.list; // just in case
					FlxG.save.data.SONG = PlayState.SONG;
					FlxG.save.data.storyDifficulty = PlayState.storyDifficulty;
					FlxG.save.data.songPos = Conductor.songPosition;
					FlxG.save.flush();
				}

				//Then make a hostile takeover
				if (FlxG.save.data.manualOverride)
				{
					//playBackRate = 1;
					PlayState.storyWeek = 0;
					Mods.currentModDirectory = '';
					Difficulty.list = Difficulty.defaultList.copy();
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong('tutorial', curDifficulty), Paths.formatToSongPath('tutorial'));
					PlayState.storyDifficulty = curDifficulty;
					FlxG.save.flush();
				}
				MusicBeatState.resetState();

			default:
				return;
		}

		effectsActive[effect] = (effectsActive[effect] == null ? 0 : effectsActive[effect] + 1);

		if (playSound != "")
		{
			FlxG.sound.play(Paths.sound(playSound), playSoundVol);
		}

		new FlxTimer().start(ttl, function(tmr:FlxTimer)
		{
			effectsActive[effect]--;
			if (effectsActive[effect] < 0)
				effectsActive[effect] = 0;

			if (onEnd != null && (effectsActive[effect] <= 0 || alwaysEnd))
				onEnd();

			FlxDestroyUtil.destroy(tmr);
		});

		if (!noIcon)
		{
			if (lagOn)
			{
				var icon = new FlxSprite().loadGraphic(Paths.image("effectIcons/" + effect));
				icon.cameras = [camOther];
				icon.screenCenter(X);
				icon.y = (effectiveDownScroll ? FlxG.height - icon.height - 10 : 10);
				add(icon);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					icon.kill();
					remove(icon);
					FlxDestroyUtil.destroy(icon);
					FlxDestroyUtil.destroy(tmr);
				});
			}
			else
			{
				var icon = new FlxSprite().loadGraphic(Paths.image("effectIcons/" + effect));
				icon.cameras = [camOther];
				icon.screenCenter(X);
				icon.y = (effectiveDownScroll ? FlxG.height - icon.frameHeight - 10 : 10);
				icon.scale.x = icon.scale.y = 0.5;
				icon.updateHitbox();
				FlxTween.tween(icon, {"scale.x": 1, "scale.y": 1}, 0.1, {
					onUpdate: function(tween)
					{
						icon.updateHitbox();
						icon.screenCenter(X);
						icon.y = (effectiveDownScroll ? FlxG.height - icon.frameHeight - 10 : 10);
					}
				});
				add(icon);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					icon.kill();
					remove(icon);
					FlxDestroyUtil.destroy(icon);
					FlxDestroyUtil.destroy(tmr);
				});
			}
		}
	}

    function updateScrollUI()
	{
		ClientPrefs.data.downScroll = effectiveDownScroll;
		timeTxt.y = (effectiveDownScroll ? FlxG.height - 44 : 19);
		timeBar.y = (timeTxt.y + (timeTxt.height / 4)) + 4;
        modManager.queueEase(curStep, curStep+3, 'reverse', effectiveDownScroll ? 1 : 0, "sineInOut");
		healthBar.y = (effectiveDownScroll ? FlxG.height * 0.1 : FlxG.height * 0.875) + 4;
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		scoreTxt.y = (effectiveDownScroll ? FlxG.height * 0.1 - 72 : FlxG.height * 0.9 + 36);
	}

	function addNote(type:Int = 0, min:Int = 0, max:Int = 0, ?specificData:Int)
	{
		if (startingSong)
			return;
		var pickSteps = FlxG.random.int(min, max);
		var pickTime = Conductor.songPosition + pickSteps * Conductor.stepCrochet;
		var pickData:Int = 0;

		if (PlayState.SONG.notes.length <= Math.floor((curStep + pickSteps + 1) / 16))
			return;

		if (PlayState.SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)] == null)
			return;

		if (specificData == null)
		{
			if (PlayState.SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)].mustHitSection)
			{
				pickData = FlxG.random.int(0, PlayState.mania);
			}
			else
			{
				// pickData = FlxG.random.int(4, 7);
				pickData = FlxG.random.int(0, PlayState.mania);
			}
		}
		else if (specificData == -1)
		{
			var chooseFrom:Array<Int> = [];
			for (i in 0...severInputs.length)
			{
				if (!severInputs[i])
					chooseFrom.push(i);
			}

			if (chooseFrom.length <= 0)
				pickData = FlxG.random.int(0, PlayState.mania);
			else
				pickData = chooseFrom[FlxG.random.int(0, chooseFrom.length - 1)];
		}
		else
		{
			if (PlayState.SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)].mustHitSection)
			{
				pickData = specificData % Note.ammo[PlayState.mania];
			}
			else
			{
				// pickData = specificData % 4 + 4;
				pickData = specificData % Note.ammo[PlayState.mania];
			}
		}
		var swagNote:Note = new Note(pickTime, pickData);
		switch (type)
		{
			case 1:
				swagNote.noteType = 'Mine Note';
				swagNote.reloadNote('minenote');
				swagNote.isMine = true;
				swagNote.ignoreNote = true;
				swagNote.specialNote = true;
			case 2:
				swagNote.noteType = 'Warning Note';
				swagNote.reloadNote('warningnote');
				swagNote.isAlert = true;
				swagNote.specialNote = true;
			case 3:
				swagNote.noteType = 'Heal Note';
				swagNote.reloadNote('healnote');
				swagNote.isHeal = true;
				swagNote.specialNote = true;
			case 4:
				swagNote.noteType = 'Ice Note';
				swagNote.reloadNote('icenote');
				swagNote.isFreeze = true;
				swagNote.ignoreNote = true;
				swagNote.specialNote = true;
			case 5:
				swagNote.noteType = 'Fake Heal Note';
				swagNote.reloadNote('fakehealnote');
				swagNote.isFakeHeal = true;
				swagNote.ignoreNote = true;
				swagNote.specialNote = true;
			default:
				swagNote.ignoreNote = false;
				swagNote.specialNote = false;
		}
		swagNote.mustPress = true;
		if (chartModifier == "SpeedRando")
			{swagNote.multSpeed = FlxG.random.float(0.1, 2);}
		if (chartModifier == "SpeedUp")
			{}
		swagNote.x += FlxG.width / 2;

        if (swagNote.fieldIndex == -1 && swagNote.field == null)
            swagNote.field = swagNote.mustPress ? playerField : dadField;
        if (swagNote.field != null)
            swagNote.fieldIndex = playfields.members.indexOf(swagNote.field);
        var playfield:PlayField = playfields.members[swagNote.fieldIndex];
        if (playfield != null)
        {
            playfield.queue(swagNote); // queues the note to be spawned
            unspawnNotes.push(swagNote);
            allNotes.push(swagNote); // just for the sake of convenience
        }
        else
        {
            swagNote.destroy();
        }
		unspawnNotes.sort(sortByNotes);
        allNotes.sort(sortByNotes);
        for (field in playfields.members)
        {
            var goobaeg:Array<Note> = [];
            for (column in field.noteQueue)
            {
                if (column.length >= Note.ammo[PlayState.mania])
                {
                    for (nIdx in 1...column.length)
                    {
                        var last = column[nIdx - 1];
                        var current = column[nIdx];

                        if (Math.abs(last.strumTime - current.strumTime) <= Conductor.stepCrochet / (192 / 16))
                        {
                            if (last.sustainLength < current.sustainLength) // keep the longer hold
                                field.removeNote(last);
                            else
                            {
                                current.kill();
                                goobaeg.push(current); // mark to delete after, cant delete here because otherwise it'd fuck w/ stuff
                            }
                        }
                    }
                }
            }
            for (note in goobaeg)
                field.removeNote(note);
        }
	}

	var isFrozen:Bool = false;
    override public function update(elapsed:Float)
	{
        #if cpp			
		if(FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			@:privateAccess
			{
				var af = lime.media.openal.AL.createFilter(); // create AudioFilter
				lime.media.openal.AL.filteri( af, lime.media.openal.AL.FILTER_TYPE, lime.media.openal.AL.FILTER_LOWPASS ); // set filter type
				lime.media.openal.AL.filterf( af, lime.media.openal.AL.LOWPASS_GAIN, 1 ); // set gain
				lime.media.openal.AL.filterf( af, lime.media.openal.AL.LOWPASS_GAINHF, lowFilterAmount ); // set gainhf
				lime.media.openal.AL.sourcei( FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.DIRECT_FILTER, af ); // apply filter to source (handle)
				//lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.HIGHPASS_GAIN, 0);
			}
		}
		if(vocals != null && vocals.playing)
		{
			@:privateAccess
			{
				var af = lime.media.openal.AL.createFilter(); // create AudioFilter
				lime.media.openal.AL.filteri( af, lime.media.openal.AL.FILTER_TYPE, lime.media.openal.AL.FILTER_LOWPASS ); // set filter type
				lime.media.openal.AL.filterf( af, lime.media.openal.AL.LOWPASS_GAIN, 1 ); // set gain
				lime.media.openal.AL.filterf( af, lime.media.openal.AL.LOWPASS_GAINHF, vocalLowFilterAmount ); // set gainhf
				lime.media.openal.AL.sourcei( vocals._channel.__audioSource.__backend.handle, lime.media.openal.AL.DIRECT_FILTER, af ); // apply filter to source (handle)
				//lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.HIGHPASS_GAIN, 0);
			}
		}
		#end
        curEffect = FlxG.random.int(0, 40);
        if (isFrozen) boyfriend.stunned = true;
        if (notes != null)
		{
			notes.forEachAlive(function(note:Note)
			{
				if (severInputs[picked] == true && note.noteData == picked)
					note.blockHit = true;
				else
					note.blockHit = false;
			});
		}
        for (i in 0...unspawnNotes.length)
		{
			if (unspawnNotes[i].noteData == picked)
				unspawnNotes[i].blockHit = true;
		}

        if (!endingSong)
            FlxG.save.data.activeItems = activeItems;

        for (i in activeItems)
            if (i == 0)
                FlxG.save.data.activeItems = null;

        /*if (FlxG.keys.justPressed.F)
        {
            switch (FlxG.random.int(0, 2))
            {
                case 0:
                    activeItems[0] += 1;
                    ArchPopup.startPopupCustom('You Got an Item!', '+1 Shield ( ' + activeItems[0] + ' Left)', 'Color');
                case 1:
                    activeItems[1] = 1;
                    ArchPopup.startPopupCustom('You Got an Item!', "Blue Ball's Curse", 'Color');
                case 2:
                    activeItems[2] += 1;
                    ArchPopup.startPopupCustom('You Got an Item!', "Max HP Up!", 'Color');
                case 3:
                    keybindSwitch('SAND');
                    ArchPopup.startPopupCustom('You Got an Item!', "Keybind Switch (S A N D)", 'Color');
            }
        }*/

        if (activeItems[0] > 0 && health <= 0)
        {
            health = 1;
            activeItems[0]--;
            ArchPopup.startPopupCustom('You Used A Shield!', '-1 Shield ( ' + activeItems[0] + ' Left)', 'Color');
        }

        if (activeItems[1] == 1)
        {
            activeItems[1] = 0;
            die();
        }

        if (drainHealth)
		{
			health = Math.max(0.0000000001, health - (FlxG.elapsed * 0.425 * dmgMultiplier));
		}

		for (i in 0...spellPrompts.length)
		{
			if (spellPrompts[i] == null)
			{
				continue;
			}
			else if (spellPrompts[i].ttl <= 0)
			{
				health -= 0.5 * dmgMultiplier;
				FlxG.sound.play(Paths.sound('spellfail'));
				camOther.flash(FlxColor.RED, 1, null, true);
				spellPrompts[i].kill();
				FlxDestroyUtil.destroy(spellPrompts[i]);
				remove(spellPrompts[i]);
				spellPrompts.remove(spellPrompts[i]);
			}
			else if (!spellPrompts[i].alive)
			{
				remove(spellPrompts[i]);
				FlxDestroyUtil.destroy(spellPrompts[i]);
			}
		}

        for (timestamp in terminateTimestamps)
        {
            if (timestamp == null || !timestamp.alive)
                continue;

            if (timestamp.tooLate)
            {
                if (!timestamp.didLatePenalty)
                {
                    timestamp.didLatePenalty = true;
                    var healthToTake = health / 3 * dmgMultiplier;
                    health -= healthToTake;
                    boyfriend.playAnim('hit', true);
                    FlxG.sound.play(Paths.sound('theshoe'));
                    timestamp.kill();
                    terminateTimestamps.resize(0);

                    var theShoe = new FlxSprite();
                    theShoe.loadGraphic(Paths.image("theshoe"));
                    theShoe.x = boyfriend.x + boyfriend.width / 2 - theShoe.width / 2;
                    theShoe.y = -FlxG.height / defaultCamZoom;
                    add(theShoe);
                    FlxTween.tween(theShoe, {y: boyfriend.y + boyfriend.height - theShoe.height}, 0.2, {
                        onComplete: function(tween)
                        {
                            if (tween.executions >= 2)
                            {
                                theShoe.kill();
                                FlxDestroyUtil.destroy(theShoe);
                                tween.cancel();
                                FlxDestroyUtil.destroy(tween);
                            }
                        },
                        type: PINGPONG
                    });
                }
            }
        }
        super.update(elapsed);
    }

    override function doDeathCheck(?skipHealthCheck:Bool = false):Bool
    {
        if (activeItems[0] <= 0)
        {
            if ((((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead))
            {
                ClientPrefs.data.downScroll = ogScroll;
                if (effectTimer != null && effectTimer.active)
                    effectTimer.cancel();
                if (randoTimer != null && randoTimer.active)
                    randoTimer.cancel();
                noiseSound.pause();
            }
        }
        super.doDeathCheck();
        return true;
    }

    override public function endSong():Bool
    {
        if (effectTimer != null && effectTimer.active)
			effectTimer.cancel();

		ClientPrefs.data.downScroll = ogScroll;

        if (FlxG.save.data.manualOverride)
        {
            trace('Switch Back');
            PlayState.storyWeek = FlxG.save.data.storyWeek;
            Mods.currentModDirectory = FlxG.save.data.currentModDirectory;
            Difficulty.list = FlxG.save.data.difficulties;
            PlayState.SONG = FlxG.save.data.SONG;
            PlayState.storyDifficulty = FlxG.save.data.storyDifficulty;
            FlxG.save.data.manualOverride = false;
            FlxG.save.flush();
            FlxG.resetState();
            return true;
        }

        if (check == did)
		{
			states.FreeplayState.giveSong = true;
		}
        super.endSong();
        return true; //why does endsong need this?????
    }

    /**
	This needs to have two different keybinds since that's how ninjamuffin wanted it like bruh.

	yeah this is like 10X better than what it was before lmao
**/
	var TemporaryKeys:Map<String, Map<String, Array<FlxKey>>> = [
		"dfjk" => [
			'note_left' => [D, D],
			'note_down' => [F, F],
			'note_up' => [J, J],
			'note_right' => [K, K]
		],
		// ... other keybind configurations ...
	];

	var switched:Bool = false;

	function keybindSwitch(keybind:String = 'normal'):Void
	{
		switched = true;

		// Function to create keybinds dynamically
		function createKeybinds(bindString:String):Map<String, Array<FlxKey>>
		{
			var keybinds:Map<String, Array<FlxKey>> = new Map<String, Array<FlxKey>>();
			var keys:Array<FlxKey> = [];

			var keyNames:Array<String> = ['left', 'down', 'up', 'right'];

			for (i in 0...bindString.length)
			{
				var keyChar:String = bindString.charAt(i).toUpperCase();
				var key:FlxKey = FlxKey.fromString(keyChar);

				keys.push(key);
				keybinds.set('note_' + keyNames[i], [key, key]); // Modify as needed
			}
			trace(keybinds);
			return keybinds;
		}

		function switchKeys(newBinds:String):Void
		{
			var bindsTable:Array<String> = newBinds.split("");
			midSwitched = true;
			changeMania(PlayState.mania);

			keysArray = [];
			ClientPrefs.keyBinds = createKeybinds(newBinds);
			keysArray = [
                (ClientPrefs.keyBinds.get('note_left').copy()),
                (ClientPrefs.keyBinds.get('note_down').copy()),
                (ClientPrefs.keyBinds.get('note_up').copy()),
                (ClientPrefs.keyBinds.get('note_right').copy())
			];
		}

		// Switch based on the provided keybind
		switchKeys(keybind);
	}

    override public function keyShit()
    {
        // FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
        {
            if ((FlxG.keys.anyJustPressed(debugKeysDodge) && terminateTimestamps.length > 0 && !terminateCooldown) || cpuControlled)
            {
                boyfriend.playAnim('dodge', true);
                terminateCooldown = true;

                for (i in 0...terminateTimestamps.length)
                {
                    if (!terminateTimestamps[i].alive || terminateTimestamps[i] == null)
                        continue;

                    if (terminateTimestamps[i].alive && terminateTimestamps[i].canBeHit)
                    {
                        terminateTimestamps[i].wasGoodHit = true;
                        terminateTimestamps[i].kill();
                        terminateTimestamps.resize(0);
                    }
                }

                new FlxTimer().start(Conductor.stepCrochet * 2 / 1000, function(tmr)
                {
                    terminateCooldown = false;
                    FlxDestroyUtil.destroy(tmr);
                });
            }
        }
    }

    override function noteMiss(daNote:Note, field:PlayField)
    {
        var char:Character = boyfriend;
		if (opponentmode || field == dadField)
			char = dad;
		if (daNote.gfNote)
			char = gf;
		if (daNote.exNote && field == playerField)
			char = bf2;
		if (daNote.exNote && field == dadField)
			char = dad2;
        if (!boyfriend.invuln)
        {
            if (daNote.isAlert)
            {
                health -= daNote.missHealth * healthLoss * 2;
                FlxG.sound.play(Paths.sound('warning'));
                var fist:FlxSprite = new FlxSprite().loadGraphic("assets/images/thepunch.png");
                fist.x = FlxG.width / camGame.zoom;
                fist.y = char.y + char.height / 2 - fist.height / 2;
                add(fist);
                FlxTween.tween(fist, {x: char.x + char.frameWidth / 2}, 0.1, {
                    onComplete: function(tween)
                    {
                        if (tween.executions >= 2)
                        {
                            fist.kill();
                            FlxDestroyUtil.destroy(fist);
                            tween.cancel();
                            FlxDestroyUtil.destroy(tween);
                        }
                    },
                    type: PINGPONG
                });
            }

            if (daNote.isAlert)
            {
                char.playAnim('hit', true);
            }
            else if (char != null && !daNote.noMissAnimation && char.hasMissAnimations)
            {
                var animToPlay:String = 'sing' + Note.keysShit.get(PlayState.mania).get('anims')[daNote.noteData] + 'miss' + daNote.animSuffix;
                char.playAnim(animToPlay, true);
            }
            super.noteMiss(daNote, field);
        }
        else
        {
            // You didn't hit the key and let it go offscreen, also used by Hurt Notes
            // Dupe note remove
            notes.forEachAlive(function(note:Note)
            {
                if (daNote != note
                    && daNote.mustPress
                    && daNote.noteData == note.noteData
                    && daNote.isSustainNote == note.isSustainNote
                    && Math.abs(daNote.strumTime - note.strumTime) < 1)
                {
                    note.kill();
                    notes.remove(note, true);
                    note.destroy();
                }
            });
        }
    }

    public var check:Int = 0;
    override function goodNoteHit(note:Note, field:PlayField):Void
    {
        if (note.specialNote)
		{
			specialNoteHit(note, field);
			return;
		}
        if (note.isCheck)
        {
            check++;
            if (ClientPrefs.data.notePopup)
                ArchPopup.startPopupCustom('You Found A Check!', '$check/$itemAmount', 'Color'); // test
            trace('Got: ' + check + '/' + itemAmount);
            updateScore();
        }
        super.goodNoteHit(note, field);
    }

    function specialNoteHit(note:Note, field:PlayField):Void
	{
		if (!note.wasGoodHit)
		{
			if (note.isMine || note.isFakeHeal)
			{
				songMisses++;
				health -= FlxG.random.float(0.25, 0.5) * dmgMultiplier;
				if (note.isMine)
					FlxG.sound.play(Paths.sound('streamervschat/mine'));
				else if (note.isFakeHeal)
					FlxG.sound.play(Paths.sound('streamervschat/fakeheal'));
				var nope:FlxSprite = new FlxSprite(0, 0);
				nope.loadGraphic(Paths.image("streamervschat/cross"));
				nope.setGraphicSize(Std.int(nope.width * 4));
				nope.angle = 45;
				nope.updateHitbox();
				nope.alpha = 0.8;
				nope.cameras = [camHUD];

				for (spr in playerField.strumNotes)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						nope.x = (spr.x + spr.width / 2) - nope.width / 2;
						nope.y = (spr.y + spr.height / 2) - nope.height / 2;
					}
				};

				add(nope);

				FlxTween.tween(nope, {alpha: 0}, 1, {
					onComplete: function(tween)
					{
						nope.kill();
						remove(nope);
						nope.destroy();
					}
				});
			}
			else if (note.isFreeze)
			{
				songMisses++;
				FlxG.sound.play(Paths.sound('streamervschat/freeze'));
				frozenInput++;
				for (sprite in playerField.strumNotes)
				{
					sprite.color = 0x0073b5;
					isFrozen = true;
				};
				new FlxTimer().start(2, function(timer)
				{
					frozenInput--;
					if (frozenInput <= 0)
					{
						for (sprite in playerField.strumNotes)
						{
							sprite.color = 0xffffff;
							isFrozen = false;
							boyfriend.stunned = false;
						};
					}
					FlxDestroyUtil.destroy(timer);
				});
			}
			else if (note.isAlert)
			{
				FlxG.sound.play(Paths.sound('streamervschat/dodge'));
				boyfriend.playAnim('dodge', true);
			}
			else if (note.isHeal)
			{
				health += FlxG.random.float(0.3, 0.6);
				FlxG.sound.play(Paths.sound('streamervschat/heal'));
				boyfriend.playAnim('hey', true);
			}

			if (note.visible)
            {
                if (field.autoPlayed)
                {
                    var time:Float = 0.15;
                    if (note.isSustainNote && !note.animation.curAnim.name.endsWith('tail'))
                        time += 0.15;
    
                    StrumPlayAnim(field, Std.int(Math.abs(note.noteData)) % Note.ammo[PlayState.mania], time, note);
                }
                else
                {
                    var spr = field.strumNotes[note.noteData];
                    if (spr != null && field.keysPressed[note.noteData])
                        spr.playAnim('confirm', true, note);
                }
            }

			note.wasGoodHit = true;
			vocals.volume = 1 * volumeMultiplier;

			if (!note.isSustainNote)
			{
				note.kill();
			}

			popUpScore(note);
		}
	}

    override function beatHit()
    {
        switch (terminateStep)
		{
			case 3:
				var terminate = new TerminateTimestamp(Math.floor(Conductor.songPosition / Conductor.crochet) * Conductor.crochet + Conductor.crochet * 3);
				add(terminate);
				terminateTimestamps.push(terminate);
				terminateStep--;
			case 2 | 1 | 0:
				terminateMessage.loadGraphic(Paths.image("terminate" + terminateStep));
				terminateMessage.screenCenter(XY);
				terminateMessage.cameras = [camOther];
				terminateMessage.visible = true;
				if (terminateStep > 0)
				{
					terminateSound.volume = 0.6;
					terminateSound.play(true);
				}
				else if (terminateStep == 0)
				{
					FlxG.sound.play(Paths.sound('beep2'), 0.85);
				}
				terminateStep--;
			case -1:
				terminateMessage.visible = false;
		}
        super.beatHit();
    }

    override function closeSubState()
    {
        setBoyfriendInvuln(1 / 60);
        super.closeSubState();
    }

    override public function noteMissPress(direction:Int = 1)
    {
        super.noteMissPress(direction);
        setBoyfriendInvuln(4 / 60);
    }

    function setBoyfriendInvuln(time:Float = 5 / 60)
	{
		invulnCount++;
		var invulnCheck = invulnCount;

		boyfriend.invuln = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (invulnCount == invulnCheck)
			{
				boyfriend.invuln = false;
			}
		});
	}
}

class TerminateTimestamp extends FlxObject
{
	public var strumTime:Float = 0;
	public var canBeHit:Bool = false;
	public var wasGoodHit:Bool = false;
	public var tooLate:Bool = false;
	public var didLatePenalty:Bool = false;

	public function new(_strumTime:Float)
	{
		super();
		strumTime = _strumTime;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
			&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset);

		if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
			tooLate = true;
	}
}
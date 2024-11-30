package states;

import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;
import backend.Achievements;
import flixel.addons.plugin.FlxMouseControl;
import states.editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;
import shaders.ChromaticAberration;
import flixel.addons.effects.FlxTrail;

using StringTools;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var fridayVersion:String = '0.2.7-Git + 0.2.8-NG';
	public static var mixtapeEngineVersion:String = '0.4.0'; // this is used for Discord RPC
	public static var psychEngineVersion:String = '1.0'; // This is also used for Discord RPC
	public static var beta:Bool = false;
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = CENTER;
	public static var secretOverride:String = null;
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'freeplay',
		'credits'
	];
	public var iconBG:FlxSprite;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
	var rightOption:String = 'options';

	public var icon:HealthIcon;
	var debugKeys:Array<FlxKey>;

	public static var lastRoll:String = "bf";

	var camFollow:FlxObject;

	var checker:FlxBackdrop;

	var gradientBar:FlxSprite;

	var bg:FlxSprite;

	var date = Date.now();

	var logoBl:FlxSprite;

	var noname:Bool = false;

	//Secrets
	var PBTBM:FlxSprite;
	var FF:FlxSprite;
	var ohno:FlxSound;
	var TL:FlxSprite;
	var h:String;
	var chroma:ChromaticAberration;
	var logoTrail:FlxTrail;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if sys
		ArtemisIntegration.setGameState ("menu");
		ArtemisIntegration.resetModName ();
		#end

		checker = new FlxBackdrop(Paths.image('mainmenu/Main_Checker'), XY, Std.int(0.2), Std.int(0.2));

		debugKeys = ClientPrefs.keyBinds.get('debug_1').copy();

		FlxG.plugins.add(new FlxMouseControl());

		#if desktop
		trace(Sys.environment()["COMPUTERNAME"]); // sussy test for a next menu x1
		trace(Sys.environment()["USERNAME"]); // sussy test for a next menu x2
		#else
		trace(Sys.environment()["USER"]); // sussy test for a next menu x3
		#end

		persistentUpdate = persistentDraw = true;

		Cursor.show();

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.color = 0xff270138;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		add(bg);

		#if sys
		ArtemisIntegration.setBackgroundColor (StringTools.hex(bg.color));
		#end

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		if (!ClientPrefs.data.lowQuality)
		{
			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAAFFA319], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			add(gradientBar);
			gradientBar.scrollFactor.set(0, 0);

			add(checker);
			checker.scrollFactor.set(0, 0.07);
		}

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (num => option in optionShit)
		{
			var item:FlxSprite = createMenuItem(option, 0, (num * 140) + 180);
			item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
			item.screenCenter(X);
		}

		if (leftOption != null)
			leftItem = createMenuItem(leftOption, 60, 490);
		if (rightOption != null)
		{
			rightItem = createMenuItem(rightOption, FlxG.width - 60, 490);
			rightItem.x -= rightItem.width;
		}

		logoBl = new FlxSprite(-100, -100);

		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.scrollFactor.set();
		logoBl.antialiasing = ClientPrefs.data.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.6));
		logoBl.animation.play('bump');
		logoBl.alpha = 0;
		logoBl.angle = -4;
		logoBl.updateHitbox();
		add(logoBl);


		FlxTween.tween(logoBl, {
			y: logoBl.y + 50,
			x: logoBl.x + 450,
			angle: -4,
			alpha: 1
		}, 1.4, {ease: FlxEase.expoInOut});

		var funnytext:FlxText = new FlxText(12, FlxG.height - 104, 0, "", 12);
		funnytext.scrollFactor.set();
		funnytext.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(funnytext);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShitpsych:FlxText = new FlxText(12, FlxG.height - 44, 0, "", 12);
		versionShitpsych.scrollFactor.set();
		versionShitpsych.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShitpsych);

		#if !debug
		versionShit.text = "Mixtape Engine v" + mixtapeEngineVersion;
		#else
		versionShit.text = "Mixtape Engine v" + mixtapeEngineVersion + ' (debug)';
		#end

		if (ClientPrefs.data.username)
		{
			#if windows
				funnytext.text = "HI " + Sys.environment()["USERNAME"] + " :)";
			#elseif mac
				funnytext.text = "HI " + Sys.environment()["USER"] + " :)";
			#end
		}
		else funnytext.text = "You're safe, for now...";
		versionShitpsych.text = "Psych Engine v" + psychEngineVersion;
		funnytext.screenCenter(X);
		versionShit.screenCenter(X);
		versionShitpsych.screenCenter(X);
		var versionShitFriday:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF v" + fridayVersion, 12);
		versionShitFriday.scrollFactor.set();
		versionShitFriday.setFormat(Paths.font("FridayNightFunkin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShitFriday.screenCenter(X);
		add(versionShitFriday);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		FlxTransitionableState.skipNextTransOut = false;

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end
		if (FlxG.save.data.PBTBM == null) FlxG.save.data.PBTBM = false;
		if (FlxG.save.data.FF == null) FlxG.save.data.FF = false;
		if (FlxG.save.data.TL == null) FlxG.save.data.TL = false;
		FlxG.save.flush();


		var hh:Array<Chance> = [];
		if (FlxG.save.data.PBTBM != null && FlxG.save.data.PBTBM == false) hh.push({item: "PBTBM", chance: 99}); //56% chance to get the "Possessed by the Blood Moon" secret
		if (FlxG.save.data.FF != null && FlxG.save.data.FF == false) hh.push({item: "FF", chance: 99}); // 39% chance to get the "Fangirl Frenzy" secret
		if (FlxG.save.data.TL != null && FlxG.save.data.TL == false) hh.push({item: "TL", chance: 99}); // 53% chance to get the "Truly Lost" secret

		trace(hh);

		if (Achievements.isUnlocked('secretsuntold') && (FlxG.save.data.menuLocks != null && FlxG.save.data.menuLocks[3] == false)) {
			if (secretOverride != null) 
				h = secretOverride;
			else 
				h = ChanceSelector.selectOption(hh, false, true, true);
		} else {
			h = 'nothing';
		}
		
		trace(h);

		if (h == 'PBTBM')
		{
			PBTBM = new FlxSprite().loadGraphic(Paths.image('stages/pbtbm/moon'));
			PBTBM.setGraphicSize(Std.int(PBTBM.width * 0.3));
			PBTBM.scrollFactor.set();
			add(PBTBM);
			FlxG.autoPause = false;
			remove(logoTrail);
			logoTrail = new FlxTrail(PBTBM, null, 3, 6, 0.3, 0.002);
			add(logoTrail);
		}
		else if (h == 'FF')
		{
			ohno = new FlxSound();
			ohno.loadEmbedded(Paths.music("The Shift"), true);
			ohno.volume = 0;
			ohno.play();
		}

		chroma = new ChromaticAberration();

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
		menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
		menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.globalAntialiasing;
		menuItem.scrollFactor.set();
		menuItems.add(menuItem);
		return menuItem;
	}

	function setChrome(chromeOffset:Float):Void
	{
		chroma.data.rOffset.value = [chromeOffset];
		chroma.data.gOffset.value = [0.0];
		chroma.data.bOffset.value = [chromeOffset * -1];
	}

	var selectedSomethin:Bool = false;
	var timeNotMoving:Float = 0;
	var volTween:Bool = false;
	var resetGrad:Bool = false;
	var initShader:Bool = false;
	override function update(elapsed:Float)
	{
		if (h != 'FF')
		{	
			if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		if (FlxG.keys.justPressed.END) 
		{
			trace("resetting progress");
			Achievements.relock();
			FlxG.save.data.enableCodes = false;
			FlxG.save.data.menuLocks = null;
			FlxG.save.data.slowdown = false;
			FlxG.save.data.PBTBM = false;
			FlxG.save.data.TL = false;
			FlxG.save.data.FF = false;
			FlxG.save.data.allowedSongs = null;
			ClientPrefs.data.gotit = false;
			CategoryState.menuLocks[3] = true; 
		}

		if (h == 'PBTBM')
		{
			PBTBM.x = logoBl.x + 130;
			PBTBM.y = logoBl.y + 50;
			PBTBM.alpha = logoBl.alpha;
			logoBl.visible = false;
			PBTBM.updateHitbox();

			#if cpp			
			if(FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				@:privateAccess
				{
					var aux = lime.media.openal.AL.createAux();
					var af = lime.media.openal.AL.createEffect(); // create AudioFilter
					lime.media.openal.AL.effecti( af, lime.media.openal.AL.EFFECT_TYPE, lime.media.openal.AL.EFFECT_REVERB ); // set filter type
					lime.media.openal.AL.effectf( af, lime.media.openal.AL.REVERB_DECAY_TIME, 5 ); // set gain
					lime.media.openal.AL.effectf( af, lime.media.openal.AL.REVERB_GAIN, 0.4); // set gainhf
					lime.media.openal.AL.auxi(aux, lime.media.openal.AL.EFFECTSLOT_EFFECT, af);
					lime.media.openal.AL.source3i(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.AUXILIARY_SEND_FILTER, aux, 0, lime.media.openal.AL.FILTER_NULL);
				}
			}
			#end
		}
		else if (h == 'FF')
		{
			logoBl.color = FlxColor.fromRGB(49, 176, 209);
			logoBl.updateHitbox();
			
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.color = FlxColor.fromRGB(49, 176, 209);
			});
			if (!resetGrad) 
			{
				gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x5559CFE4, 0xAA00AEFF], 1, 90, true);
				resetGrad = true;
			}
			checker.color = FlxColor.fromRGB(49, 176, 209);
			bg.color = FlxColor.fromRGB(49, 176, 209);

			if (FlxG.mouse.overlaps(logoBl) && !volTween)
			{
				volTween = true;
				FlxTween.tween(ohno, {volume: 0.5}, 1, {ease:FlxEase.sineOut});
				FlxTween.tween(FlxG.sound.music, {volume: 0.2}, 1, {ease:FlxEase.sineOut});
			}
			else if (!FlxG.mouse.overlaps(logoBl) && volTween)
			{
				volTween = false;
				FlxTween.tween(ohno, {volume: 0}, 0.5, {ease:FlxEase.sineOut});
				FlxTween.tween(FlxG.sound.music, {volume: 0.8}, 0.5, {ease:FlxEase.sineOut});
			}

			#if cpp			
			if(ohno != null && ohno.playing)
			{
				@:privateAccess
				{
					var aux = lime.media.openal.AL.createAux();
					var af = lime.media.openal.AL.createEffect(); // create AudioFilter
					lime.media.openal.AL.effecti( af, lime.media.openal.AL.EFFECT_TYPE, lime.media.openal.AL.EFFECT_REVERB ); // set filter type
					lime.media.openal.AL.effectf( af, lime.media.openal.AL.REVERB_DECAY_TIME, 5 ); // set gain
					lime.media.openal.AL.effectf( af, lime.media.openal.AL.REVERB_GAIN, 0.4); // set gainhf
					lime.media.openal.AL.auxi(aux, lime.media.openal.AL.EFFECTSLOT_EFFECT, af);
					lime.media.openal.AL.source3i(ohno._channel.__audioSource.__backend.handle, lime.media.openal.AL.AUXILIARY_SEND_FILTER, aux, 0, lime.media.openal.AL.FILTER_NULL);
				}
			}
			#end
		}
		else if (h == 'TL')
		{
			if (!initShader)
			{
				logoBl.shader = chroma;
			}
			var ch = FlxG.random.int(1, 10) / 1000;
			setChrome(ch);
			logoBl.updateHitbox();

			if (FlxG.mouse.overlaps(logoBl))
			{	
				FlxG.sound.music.pitch = 0.1;
				logoBl.color = FlxColor.fromRGB(0, 0, 0, 30);
				menuItems.forEach(function(spr:FlxSprite)
				{
					spr.color = FlxColor.fromRGB(0, 0, 0, 255);
				});
				if (!resetGrad) 
				{
					gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x00ff0000, 0x00ff0000], 1, 90, true);
					resetGrad = true;
				}
				checker.color = FlxColor.fromRGB(0, 0, 0, 255);
				bg.color = FlxColor.fromRGB(0, 0, 0, 255);
			}
			else 
			{
				FlxG.sound.music.pitch = 1;
				logoBl.color = FlxColor.fromRGB(255, 255, 255, 255);
				menuItems.forEach(function(spr:FlxSprite)
				{
					spr.color = FlxColor.fromRGB(255, 255, 255, 255);
				});
				if (resetGrad) 
				{
					gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAAFFA319], 1, 90, true);
					resetGrad = false;
				}
				checker.color = FlxColor.fromRGB(255, 255, 255, 255);
				bg.color = 0xff270138;
			} 

			#if cpp			
			if(FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				@:privateAccess
				{
					var aux = lime.media.openal.AL.createAux();
					var af = lime.media.openal.AL.createEffect(); // create AudioFilter
					lime.media.openal.AL.effecti( af, lime.media.openal.AL.EFFECT_TYPE, lime.media.openal.AL.EFFECT_REVERB ); // set filter type
					lime.media.openal.AL.effectf( af, lime.media.openal.AL.REVERB_DECAY_TIME, 20 ); // set gain
					lime.media.openal.AL.effectf( af, lime.media.openal.AL.REVERB_GAIN, 1); // set gainhf
					lime.media.openal.AL.auxi(aux, lime.media.openal.AL.EFFECTSLOT_EFFECT, af);
					lime.media.openal.AL.source3i(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.AUXILIARY_SEND_FILTER, aux, 0, lime.media.openal.AL.FILTER_NULL);
				}
			}
			#end
		}

		Conductor.songPosition = FlxG.sound.music.time;

		if(FlxG.keys.justPressed.F11)
    		FlxG.fullscreen = !FlxG.fullscreen;

		if(FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		checker.x -= 0.45 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.16 / (ClientPrefs.data.framerate / 60);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P) changeItem(-1);

			if (controls.UI_DOWN_P) changeItem(1);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				Cursor.show();
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case CENTER:
						selectedItem = menuItems.members[curSelected];
					case LEFT:
						selectedItem = leftItem;
					case RIGHT:
						selectedItem = rightItem;
				}

				if(leftItem != null && FlxG.mouse.overlaps(leftItem))
				{
					Cursor.cursorMode = Pointer;
					allowMouse = true;
					if(selectedItem != leftItem)
					{
						curColumn = LEFT;
						changeItem();
					}
				}
				else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
				{
					Cursor.cursorMode = Pointer;
					allowMouse = true;
					if(selectedItem != rightItem)
					{
						curColumn = RIGHT;
						changeItem();
					}
				}
				else
				{
					var dist:Float = -1;
					var distItem:Int = -1;
					for (i in 0...optionShit.length)
					{
						var memb:FlxSprite = menuItems.members[i];
						if(FlxG.mouse.overlaps(memb))
						{
							Cursor.cursorMode = Pointer;
							var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
							if (dist < 0 || distance < dist)
							{
								dist = distance;
								distItem = i;
								allowMouse = true;
							}
						}
					}

					if(distItem != -1 && selectedItem != menuItems.members[distItem])
					{
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			}
			else
			{

				timeNotMoving += elapsed;
				if(timeNotMoving > 2) Cursor.hide();
			}

			switch(curColumn)
			{
				case CENTER:
					if(controls.UI_LEFT_P && leftOption != null)
					{
						curColumn = LEFT;
						changeItem();
					}
					else if(controls.UI_RIGHT_P && rightOption != null)
					{
						curColumn = RIGHT;
						changeItem();
					}

				case LEFT:
					if(controls.UI_RIGHT_P)
					{
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(controls.UI_LEFT_P)
					{
						curColumn = CENTER;
						changeItem();
					}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				TransitionState.transitionState(TitleState, null, [], true);
				// Main Menu Back Animations
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				if (!ClientPrefs.data.lowQuality)
				{
					FlxTween.tween(logoBl, {
						alpha: 0,
						x: -100,
						y: -100,
						angle: 4
					}, 0.5, {ease: FlxEase.quadOut});
				}
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed))
			{
				if (optionShit[curSelected] != 'donate')
				{
					var item:FlxSprite;
					var option:String;
					switch(curColumn)
					{
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];

						case LEFT:
							option = leftOption;
							item = leftItem;

						case RIGHT:
							option = rightOption;
							item = rightItem;
					}

					if (h == 'PBTBM')
					{
						if (!FlxG.mouse.overlaps(PBTBM))
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							item.updateHitbox();
							// spr.x += -300;
							FlxTween.tween(item, {x: item.x - FlxG.random.int(-240, 240)}, 2, {ease: FlxEase.sineInOut});
							FlxTween.tween(item, {y: 1000}, 1, {ease: FlxEase.backIn});
						}
						else if (FlxG.mouse.overlaps(PBTBM))
						{
							FlxG.save.data.PBTBM = true;
							FlxG.save.flush();
							FreeplayState.allowedSongs.push('pbtbm');
							Achievements.unlock('secretsunveiled');
							MusicBeatState.playSong(['possessed-by-the-blood-moon'], false, 0, 'TransitionState', 'stickers', ['FNF', 'NITG', 'POSSESSED']);
							FlxG.autoPause = ClientPrefs.data.autoPause;
						}
					}
					else if (h == 'TL')
					{
						if (!FlxG.mouse.overlaps(logoBl))
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							item.updateHitbox();
							// spr.x += -300;
							FlxTween.tween(item.scale, {x: 0}, 2, {ease: FlxEase.sineInOut});
							FlxTween.tween(item.scale, {y: 0}, 1, {ease: FlxEase.backIn});
						}
						else if (FlxG.mouse.overlaps(logoBl))
						{
							FlxG.save.data.TL = true;
							FlxG.save.flush();
							FreeplayState.allowedSongs.push('lost');
							Achievements.unlock('secretsunveiled');
							selectedSomethin = true;
							Cursor.hide();
							FlxG.sound.music.stop();
							FlxG.camera.fade(FlxColor.BLACK, 0.00001);
							new FlxTimer().start(5, function(ct:FlxTimer)
							{
								MusicBeatState.playSong(['truly-lost', 'everlost', 'nowitness'], true, 2, 'FlxG');
							});
							FlxG.autoPause = ClientPrefs.data.autoPause;
						}
					}
					else if (h == 'FF')
					{
						if (FlxG.mouse.overlaps(logoBl))
						{
							FlxG.save.data.FF = true;
							FlxG.save.flush();
							ohno.stop();
							FreeplayState.allowedSongs.push('frenzy');
							Achievements.unlock('secretsunveiled');
							MusicBeatState.playSong(['fangirl-frenzy'], true, 2, 'TransitionState', 'stickers');
						}
						else
						{
							selectedSomethin = true;
							Cursor.hide();
							FlxG.sound.play(Paths.sound('confirmMenu'));
							// Main Menu Select Animations
							FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
							{
								FlxG.camera.zoom = 1;
							}});
							FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
							if (!ClientPrefs.data.lowQuality)
							{
								FlxTween.tween(checker, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
								FlxTween.tween(logoBl, {
									alpha: 0,
									x: logoBl.x - 30,
									y: logoBl.y - 30,
									angle: 4
								}, 0.8, {ease: FlxEase.quadOut});
							}
	
							new FlxTimer().start(0.2, function(tmr:FlxTimer)
							{
								hideit(0.6);
							});
	
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								goToState(option);
							});
	
							menuItems.forEach(function(spr:FlxSprite)
							{
								if (curSelected != spr.ID)
								{
									FlxTween.tween(spr, {alpha: 0.1, x: 1500}, 1, {
										ease: FlxEase.quadOut,
										onComplete: function(twn:FlxTween)
										{
											spr.kill();
										}
									});
									FlxTween.tween(spr, {x: 1500}, 1, {
										ease: FlxEase.quadOut
									});
								}
								else
								{
									spr.updateHitbox();
									// spr.x += -300;
									FlxTween.tween(spr, {x: spr.x - 240, y: 260}, 0.5, {ease: FlxEase.quadOut});
									FlxTween.tween(spr.scale, {x: 1.2, y: 1.2}, 0.8, {ease: FlxEase.quadOut});
	
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										goToState(option);
									});
								}
							});
						}
					}
					else
					{
						selectedSomethin = true;
						Cursor.hide();
						FlxG.sound.play(Paths.sound('confirmMenu'));
						// Main Menu Select Animations
						FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
						{
							FlxG.camera.zoom = 1;
						}});
						FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						if (!ClientPrefs.data.lowQuality)
						{
							FlxTween.tween(checker, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
							FlxTween.tween(logoBl, {
								alpha: 0,
								x: logoBl.x - 30,
								y: logoBl.y - 30,
								angle: 4
							}, 0.8, {ease: FlxEase.quadOut});
						}

						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							hideit(0.6);
						});

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							goToState(option);
						});

						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0.1, x: 1500}, 1, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
								FlxTween.tween(spr, {x: 1500}, 1, {
									ease: FlxEase.quadOut
								});
							}
							else
							{
								spr.updateHitbox();
								// spr.x += -300;
								FlxTween.tween(spr, {x: spr.x - 240, y: 260}, 0.5, {ease: FlxEase.quadOut});
								FlxTween.tween(spr.scale, {x: 1.2, y: 1.2}, 0.8, {ease: FlxEase.quadOut});

								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState(option);
								});
							}
						});
					}
				}
			}
			#if desktop
			if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			
		}

		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	function goToState(daChoice:String)
	{
		trace(daChoice);
		if(ohno != null && ohno.playing) ohno.stop(); 
		switch (daChoice)
		{
			case 'freeplay':
				TransitionState.transitionState(states.CategoryState, {transitionType: "stickers"},[], true);
			case 'socials':
				MusicBeatState.switchState(new SocialsState());
			#if MODS_ALLOWED
			case 'mods':
				MusicBeatState.switchState(new ModsMenuState());
			#end
			case 'achievements':
				TransitionState.transitionState(AchievementsMenuState, {transitionType: "fallRandom"}, [], true);
			case 'credits':
				MusicBeatState.switchState(new CreditsState());
			case 'options':
				MusicBeatState.switchState(new options.OptionsState());
		}
	}

	function hideit(time:Float)
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 0.0}, time, {ease: FlxEase.quadOut});
		});
		FlxTween.tween(bg, {alpha: 0}, time, {ease: FlxEase.expoIn});
		if (!ClientPrefs.data.lowQuality)
		{
			FlxTween.tween(checker, {alpha: 0}, time, {ease: FlxEase.expoIn});
			FlxTween.tween(gradientBar, {alpha: 0}, time, {ease: FlxEase.expoIn});
		}
	}

	function changeItem(change:Int = 0)
	{
		if(change != 0) curColumn = CENTER;
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
		switch(curColumn)
		{
			case CENTER:
				selectedItem = menuItems.members[curSelected];
			case LEFT:
				selectedItem = leftItem;
			case RIGHT:
				selectedItem = rightItem;
		}
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		camFollow.y = selectedItem.getGraphicMidpoint().y;
	}

	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null)
			logoBl.animation.play('bump', true);

		if (!selectedSomethin)
		{
			FlxG.camera.zoom = zoomies;

			FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
				ease: FlxEase.quadOut
			});
		}
	}
}

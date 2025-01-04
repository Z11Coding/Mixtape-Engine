package states;
import backend.Threader;
#if sys
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxState;
// import backend.GPUBitmap;
import options.CacheSettings;
import flixel.ui.FlxBar;
import openfl.system.System;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
#end
import backend.JSONCache;
import objects.VideoSprite;
import backend.cache.ImageCache;
import backend.cache.SoundCache;

class CacheState extends MusicBeatState
{
	public var cacheNeeded:Bool = false;
	public static var didPreCache:Bool = false;
	public static var bitmapData:Map<String, FlxGraphic>;
	public static var loaded:Bool = false;
	var images:Array<String> = [];
	var music:Array<String> = [];
	var json:Array<String> = [];
	var videos:Array<String> = [];
	var modImages:Array<String> = [];
	var modMusic:Array<String> = [];
	var modVideos:Array<String> = [];
	

	var boolshit = true;
	var daMods:Array<String> = [];
	var pathList:Array<String> = 
	[
		"", "/characters", "/dialogue", "/pauseAlt", "/pixelUI", "/weeb", 
		"/achievements", "/credits", "/icons", "/loading", "/mainmenu", "/menubackgrounds", 
		"/menucharacters", "/menudifficulties", "/storymenu", "/pixelUI/noteskins", "/cursor", 
		"/editors", "/effects", "/globalIcons", "/HUD", "/mechanics", "/noteColorMenu", "/noteskins", 
		"/pause", "/soundtray", "/stages"
	]; //keep it here just in case
	
	var shitz:FlxText;
	var totalthing = [];
	var curThing:String;
	var menuBG:FlxSprite;
	var cacheStart:Bool = false;
	var startCachingModImages:Bool = false;
	var startCachingSoundsAndMusic:Bool = false;
	var startCachingSoundsAndMusicMods:Bool = false;
	var songsCached:Bool;
	var graphicsCached:Bool;
	var startCachingVideos:Bool;
	var startCachingVideoMods:Bool;
    var startCachingGraphics:Bool = false;
	var musicCached:Bool;
	var modImagesCached:Bool;
	var gameCached:Bool = false;
	var dontBother:Bool = false;
	var totalToDo:Int = 0;
	var modImI:Int = 0;
	var gfxI:Int = 0;
	var sNmI:Int = 0;
	var sNmmI:Int = 0;
	var gfxV:Int = 0;
	var gfxMV:Int = 0;
	var allowMusic:Bool = false;
	var pause:Bool = false;
	var loadingWhat:FlxText;
	var loadingBar:FlxBar;
	var loadingBox:FlxSprite;
	var loadingWhatMini:FlxText;
	var loadingBoxMini:FlxSprite;
	public static var cacheInit:Bool = false;
	var currentLoaded:Int = 0;
	var loadTotal:Int = 0;
	var thread:ThreadQueue;
	var memSafety:MemLimitThreadQ;
	var memSafety2:MemLimitThreadQ;
	
	var listoSongs:Array<String> = [
		'breakfast', 
		'breakfast-(pico)', 
		'tea-time', 
		'celebration', 
		'drippy-genesis', 
		'Reglitch', 
		'false-memory', 
		'funky-genesis', 
		'late-night-cafe', 
		'late-night-jersey', 
		'silly-little-sample-song'
	];

	public static var newDest:FlxState;
	var prevAutoPause:Bool;
	public static var imageCache:ImageCache = new ImageCache("", "png");
    public static var soundCache:SoundCache;
	override function create()
	{
		ClientPrefs.data.highPriorityCache ? backend.window.Priority.setPriority(5) : backend.window.Priority.setPriority(ClientPrefs.data.gamePriority);
		trace('ngl pretty cool');
		prevAutoPause = FlxG.autoPause;
		FlxG.autoPause = false;
		if (!cacheInit && (FlxG.save.data.musicPreload2 == null || FlxG.save.data.graphicsPreload2 == null || FlxG.save.data.videoPreload2 == null)) {
			openPreloadSettings();
			cacheInit = true;
			pause = true;
			allowMusic = false;
			FlxG.switchState(new CacheSettings());
		}

		//Cursor.cursorMode = Cross;
		FlxTransitionableState.skipNextTransOut = false;
		switch (FlxG.random.bool(89))
		{
			case true:
				newDest = new SplashScreen();
			case false:
				newDest = new What();

		}
		//FlxG.sound.play(Paths.music('celebration'));
		for (folder in Mods.getModDirectories())
		{
			if(!Mods.ignoreModFolders.contains(folder))
			{
				daMods.push(folder);
			}
		}

		pathList = [];
		Paths.crawlDirectoryOG("mods", "", pathList);
		
		if((FlxG.save.data.musicPreload2 != null && ClientPrefs.data.musicPreload2 == false)
			&& (FlxG.save.data.graphicsPreload2 != null && ClientPrefs.data.graphicsPreload2 == false)
				&& (FlxG.save.data.videoPreload2 != null && ClientPrefs.data.videoPreload2 == false)) {
				FlxG.switchState(newDest);
				FlxG.autoPause = prevAutoPause;
				dontBother = true;
				allowMusic = false;
		}	
		else 
		{
			allowMusic = true;
			dontBother = false;
			didPreCache = true;
		}

		menuBG = new FlxSprite().loadGraphic(Paths.image('loading/' + FlxG.random.int(1, 8)));
		menuBG.screenCenter();
		add(menuBG);

		#if cpp
		if (ClientPrefs.data.graphicsPreload2)
		{
			Paths.crawlDirectoryOG("assets", ".png", images);
			Paths.crawlDirectoryOG("mods", ".png", modImages);
			/*
				var cache:Array<String> = [];
				cache = cache.concat(Paths.crawlDirectoryOG("assets", ".png", images));
				cache = cache.concat(Paths.crawlDirectoryOG("mods", ".png", modImages));

				if (ClientPrefs.data.saveCache) {
					ImageCache.loadCache();
				}

				for (image in cache) {
					if (ImageCache.exists(image)) {
						if (images.indexOf(image) != -1) {
							images.splice(images.indexOf(image), 1);
						} else if (modImages.indexOf(image) != -1) {
							modImages.splice(modImages.indexOf(image), 1);
						}
					}
				}
			*/
		
		}

		if (ClientPrefs.data.musicPreload2)
		{
			Paths.crawlDirectoryOG("assets", ".ogg", music);
			Paths.crawlDirectoryOG("mods", ".ogg", modMusic);
		}

		if (ClientPrefs.data.videoPreload2)
		{
			Paths.crawlDirectoryOG("assets", ".mp4", videos);
			Paths.crawlDirectoryOG("mods", ".mp4", modVideos);
		}

		var jsonCache = function() {
			Paths.crawlDirectory("assets", ".json", json);
			Paths.crawlDirectory("mods", ".json", json);
			
			for (json in json)
			{
				JSONCache.addToCache(json);
			}
			return true;
		}

		jsonCache();

		//trace(JSONCache.charts());


		#end


		loadTotal = images.length + modImages.length + music.length + modMusic.length + videos.length + modVideos.length;
		//trace("Files: " + "Images: " + images + "Images(Mod): " + modImages + "Music: " + music + "Music(Mod): " + modMusic + "Video: " + videos + "Video(Mod): " + modVideos);
		trace(loadTotal + " files to load");

		/*
		var cacheArr:Array<() -> Void> = [];

		for (a in images)
		{
			var image =
			function() 
			{
				if(!ImageCache.exists(a)){
					ImageCache.add(a);
				}
				currentLoaded++;
			};
			cacheArr.push(image);
		}

		for (a in modImages)
		{
			var imageMod =
			function() 
			{
				if(!ImageCache.exists(a)){
					ImageCache.add(a);
				}
				currentLoaded++;
			};
			cacheArr.push(imageMod);
		}

		for (a in music)
		{
			var music =
			function() 
			{
				if(CoolUtil.exists(a)){
					if(CoolUtil.exists(Paths.cacheInst(a))){
						FlxG.sound.cache(Paths.cacheInst(a));
					}
					if(CoolUtil.exists(Paths.cacheVoices(a))){
						FlxG.sound.cache(Paths.cacheVoices(a));
					}
					if(CoolUtil.exists(Paths.cacheSound(a))){
						FlxG.sound.cache(Paths.cacheSound(a));
					}
					if(CoolUtil.exists(Paths.cacheMusic(a))) {
						FlxG.sound.cache(Paths.cacheMusic(a));
					}
					currentLoaded++;
				}
				else{
					trace("Music/Sound: File at " + a + " not found, skipping cache.");
				}
			};
			cacheArr.push(music);
		}

		for (a in modMusic)
		{
			var modMusic =
			function() 
			{
				try
				{
					if(CoolUtil.exists(Paths.cacheInst(a))){
						FlxG.sound.cache(Paths.cacheInst(a));
					}
					if(CoolUtil.exists(Paths.cacheVoices(a))){
						FlxG.sound.cache(Paths.cacheVoices(a));
					}
					if(CoolUtil.exists(Paths.cacheSound(a))){
						FlxG.sound.cache(Paths.cacheSound(a));
					}
					if(CoolUtil.exists(Paths.cacheMusic(a))) {
						FlxG.sound.cache(Paths.cacheMusic(a));
					}
					currentLoaded++;
				}
				catch(e)
				{
					trace("Music/Sound: File at " + a + " not found, skipping cache.");
				}
			};
			cacheArr.push(modMusic);
		}

		for (a in videos)
		{
			var video =
			function() 
			{
				try {
					var a = StringTools.replace(a, '.mp4', '');
					a = StringTools.replace(a, 'assets/videos/', '');
					preloadVideo(StringTools.replace(a, '.mp4', ''));
					currentLoaded++;
				}
				catch(e){
					trace("Video: File at " + a + " not found, skipping cache.");
				}
			};
			cacheArr.push(video);
		}

		for (a in modVideos)
		{
			var video =
			function() 
			{
				try{
					preloadVideoMods(a);
					currentLoaded++;
				}
				catch(e){
					trace("Video: File at " + a + " not found, skipping cache.");
				}
			};
			cacheArr.push(video);
		}
		*/

		if(loadTotal > 0){
			loadingBar = new FlxBar(0, 605, LEFT_TO_RIGHT, 600, 24, this, 'currentLoaded', 0, loadTotal);
			loadingBar.createGradientBar([0xFF333333, 0xFFFFFFFF], [0xFF7233D8, 0xFFD89033]);
			loadingBar.screenCenter(X);
			loadingBar.visible = false;
			add(loadingBar);
		}

		loadingWhat = new FlxText(FlxG.width/2 - 500, 0, 0, "Press ENTER to see cache options\nLoading will being soon", 24);
		loadingWhat.setFormat(Paths.font("DS-DIGIB.TTF"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingWhat.screenCenter(XY);

		loadingWhatMini = new FlxText(loadingWhat.x, loadingWhat.y+285, 0, "Currently Loading: Music", 24);
		loadingWhatMini.setFormat(Paths.font("DS-DIGIB.TTF"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingWhatMini.setGraphicSize(Std.int(loadingWhatMini.width) * 0.5);
		loadingWhatMini.screenCenter(X);

		loadingBox = new FlxSprite(FlxG.width/2 - 500, 0).makeGraphic(Std.int(loadingWhat.width), Std.int(loadingWhat.height), FlxColor.BLACK);
		loadingBox.screenCenter(XY);
		loadingBox.alpha = 0.5;

		add(loadingBox);
		add(loadingWhat);
		add(loadingWhatMini);

		if(ClientPrefs.data.graphicsPreload2){
			//GPUBitmap.disposeAll(); //cuz we moved to a pack without the undertale or origins and i didnt wanna complain about it cuz i know they were causing issues so i was being
			//ImageCache.cache.clear();
		}
		else{
			modImagesCached = true;
			graphicsCached = true;
		}

		if(ClientPrefs.data.musicPreload2){
			Assets.cache.clear("music");
		}
		else{
			songsCached = true;
		}

		if (allowMusic && !cacheInit) FlxG.sound.playMusic(Paths.music(listoSongs[FlxG.random.int(0, 10)]), 1, true);

		//thread = new ThreadQueue(3);
		//thread.preloadMulti(cacheArr);
		if(!cacheStart){
			#if web
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				modImagesCached = true;
				graphicsCached = true;
				songsCached = true;
			});
			#else
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				cacheStart = true;
				cache();
			});
			#end
		}

		super.create();
	}

	function openPreloadSettings(){
        #if desktop
        FlxG.sound.play(Paths.sound('cancelMenu'));
        FlxG.switchState(new CacheSettings());
        #end
    }

	var move:Bool = false;
	var timeSinceLastCache:Float = 0;
	var lastTotal:Int = 0;
	var loadingImages:Bool = false;
	override function update(elapsed) 
	{
		/*
		if (!loadingImages && thread.length == 0)
		{
			loadingImages = true;
			loadingWhat = new FlxText(FlxG.width/2 - 500, 0, 0, "LOADING\n(THIS MAY TAKE AWHILE IF YOU HAVE ALOT OF MODS!!)\nPLEASE WAIT...", 24);
			loadingWhat.setFormat(Paths.font("DS-DIGIB.TTF"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			loadingWhat.screenCenter(XY);
			add(loadingWhat);
			memSafety = new MemLimitThreadQ(images.concat(modImages), function(a:String) {
				if(!ImageCache.exists(a)){
					ImageCache.add(a);	
				}
				currentLoaded++;
			}, 3, true, thread);

			preloadMusic();
			videos.forEachT(function(a:String) {
				try {
					var a = StringTools.replace(a, '.mp4', '');
					a = StringTools.replace(a, 'assets/videos/', '');
					preloadVideo(StringTools.replace(a, '.mp4', ''));
					currentLoaded++;
				}
				catch(e){
					trace("Video: File at " + a + " not found, skipping cache.");
				}
			});

			modVideos.forEachT(function(a:String) {
				try{
					preloadVideoMods(a);
					currentLoaded++;
				}
				catch(e){
					trace("Video: File at " + a + " not found, skipping cache.");
				}
			});
		}
		timeSinceLastCache += elapsed;
		// trace("Time since last cache: " + timeSinceLastCache);
		if (currentLoaded != lastTotal)
		{
			lastTotal = currentLoaded;
			timeSinceLastCache = 0;
		}
		*/
		if (!dontBother && !pause)
		{
			loadingBox.width = Std.int(loadingWhat.width);
			loadingBox.height = Std.int(loadingWhat.height);
			if (currentLoaded == loadTotal /*|| thread.length == 0*/) gameCached = true;

			//if (!ClientPrefs.data.graphicsPreload2 && !ClientPrefs.data.musicPreload2) gameCached = true;

			if (loadingWhat.text == "Loading: null") 
			{
				gameCached = true; //I love null checking
			}

			if (!cacheStart && FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.autoPause = prevAutoPause;
				FlxG.switchState(newDest); 
			}

			if(menuBG.alpha == 0){
				if (ClientPrefs.data.saveCache) {
					menuBG.updateHitbox();
					FlxG.sound.music.fadeOut(1, 0);
					loadingWhat.text = "Saving cache...";
					loadingWhat.screenCenter(XY);
					loadingWhatMini.text = "Saving cache...";
					loadingWhatMini.screenCenter(X);
	
					// backend.Threader.runInThread(ImageCache.saveCache());
					// backend.Threader.runInThread(ImageCache.cacheToGPU());
					// GPUBitmap.removeCallbacks();
				}
				FlxG.sound.music.time = 0;
				if (ClientPrefs.data.cacheCharts) {
					var charts:Array<String> = Paths.crawlDirectory("assets/shared/data", ".json");
					PlayState.cachingSongs = charts;
					PlayState.CacheMode = true;
					trace("Charts: " + charts);
					trace("Caching charts...");
					FlxG.switchState(new PlayState());
				}
				else {
					FlxG.autoPause = prevAutoPause;
					FlxG.switchState(newDest);
				}
			}

			if(!gameCached)
			{
				loadingWhat.text = 'Loading...\n(${loadingBar.percent}% // $currentLoaded out of $loadTotal)';
				loadingWhat.screenCenter();
			}

			if(gameCached && menuBG.alpha == 1){
				FlxTween.tween(FlxG.camera, {zoom: 0}, 1, {ease: FlxEase.sineOut});
				FlxTween.tween(FlxG.camera, {angle: 360}, 1, {ease: FlxEase.sineOut});
				FlxTween.tween(menuBG, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
				loadingWhat.text = "Done!";
				loadingWhat.screenCenter(XY);
				loadingWhatMini.text = "Done!";
				loadingWhatMini.screenCenter(X);
				if(loadingBar != null){
					FlxTween.tween(loadingBar, {alpha: 0}, 0.3);
				}
				menuBG.updateHitbox();
				FlxG.sound.music.fadeOut(1, 0);
			}

			if(!cacheStart){
				if(FlxG.keys.justPressed.ANY){
					openPreloadSettings();
				}
			}
		}

		/*
		if (timeSinceLastCache >= 3 && !gameCached)
		{
			trace("No update after so long... Resetting thread");
			thread.reset(true);
			timeSinceLastCache = 0;
			trace("Attempting thread reset");
		}
		*/
		
		super.update(elapsed);
	}

	public var videoCutscene:VideoSprite = null;
	function preloadVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);
		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var cutscene:VideoSprite = new VideoSprite(fileName, true, true, false);
			add(cutscene);
			return cutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else
			//trace("Mod Video not found: " + fileName);
		#else
		else
			//trace("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function preloadVideoMods(name:String)
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = name;
		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var cutscene:VideoSprite = new VideoSprite(fileName, true, true, false);
			add(cutscene);
			return cutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else
			//trace("Mod Video not found: " + fileName);
		#else
		else
			//trace("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function cache()
	{
		if(loadingBar != null){
            loadingBar.visible = true;
        }
		for (i in images)
		{
            imageCache.cacheGraphic(StringTools.replace(i, '.png', ''), true);
			currentLoaded++;
		}
		for (i in modImages)
		{
            imageCache.cacheGraphic(StringTools.replace(i, '.png', ''), false);
			currentLoaded++;
		}
		for (i in music)
		{
			try
			{
				soundCache.cacheSound(StringTools.replace(i, '.ogg', ''));
			}
			catch(e)
			{
				trace("Failed to load sound: "+i);
			}
			currentLoaded++;
		}
		for (i in modMusic)
		{
			try
			{
				soundCache.cacheSound(StringTools.replace(i, '.ogg', ''));
			}
			catch(e)
			{
				trace("Failed to load sound: "+i);
			}
			currentLoaded++;
		}
		videos.forEachT(function(a:String) {
			try {
				var a = StringTools.replace(a, '.mp4', '');
				a = StringTools.replace(a, 'assets/videos/', '');
				preloadVideo(StringTools.replace(a, '.mp4', ''));
				currentLoaded++;
			}
			catch(e){
				trace("Video: File at " + a + " not found, skipping cache.");
			}
		});

		modVideos.forEachT(function(a:String) {
			try{
				preloadVideoMods(a);
				currentLoaded++;
			}
			catch(e){
				trace("Video: File at " + a + " not found, skipping cache.");
			}
		});
		gameCached = true;
	}

	function preloadMusic(){
        for(x in music){
			if(CoolUtil.exists(Paths.cacheInst(x))){
                FlxG.sound.cache(Paths.cacheInst(x));
            }
			if(CoolUtil.exists(Paths.cacheVoices(x))){
                FlxG.sound.cache(Paths.cacheVoices(x));
            }
			if(CoolUtil.exists(Paths.cacheSound(x))){
                FlxG.sound.cache(Paths.cacheSound(x));
            }
            if(CoolUtil.exists(Paths.cacheMusic(x))) {
                FlxG.sound.cache(Paths.cacheMusic(x));
            }
			//loadingWhat.text = 'Loading: ' + x;
			currentLoaded++;
        }

		for(x in modMusic){
            if(CoolUtil.exists(Paths.cacheInst(x))){
                FlxG.sound.cache(Paths.cacheInst(x));
            }
			if(CoolUtil.exists(Paths.cacheVoices(x))){
                FlxG.sound.cache(Paths.cacheVoices(x));
            }
			if(CoolUtil.exists(Paths.cacheSound(x))){
                FlxG.sound.cache(Paths.cacheSound(x));
            }
            if(CoolUtil.exists(Paths.cacheMusic(x))) {
                FlxG.sound.cache(Paths.cacheMusic(x));
            }
			//loadingWhat.text = 'Loading: ' + x;
			currentLoaded++;
        }
		loadingWhat.screenCenter(XY);
        //FlxG.sound.play(Paths.sound("tick"), 1);
        songsCached = true;
    }
}
#else
import flixel.FlxG;
import flixel.FlxState;
using StringTools;
class CacheState extends MusicBeatState
{
	public static var newDest:FlxState;
	override function create()
	{
		Paths.clearStoredMemory();
		Main.dumpCache();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

		ClientPrefs.loadPrefs();
		super.create();
		newDest = new SplashScreen();
		trace('simply be better');
		FlxG.switchState(newDest);
	}
}
#end
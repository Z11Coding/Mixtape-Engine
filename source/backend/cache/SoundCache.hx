package backend.cache;

import openfl.Assets;
import openfl.media.Sound;
import openfl.utils.AssetType;

/*
    DO NOT USE THIS IT'S STUPID
    Class to cache sounds into OpenFL's sound cache.
    Cached sounds can be played with FlxG.sound.play(path); or FlxG.sound.playMusic(path);
    Pretty much just FlxG.sound.cache with a few extra features.
*/
class SoundCache {
    public function new() {}
    public function cacheSound(path:String):Sound {
        #if sys
        if (FileSystem.exists(path))
            return Sound.fromFile(path);
        #else
        if (OpenFlAssets.exists(path, SOUND) || OpenFlAssets.exists(path, MUSIC))
            return OpenFlAssets.getSound(path);
        #end
		trace('Sound not found at ' + path);
		return null;
    }
    public function cacheSoundGroup(keys:Array<String>):Void {
        for (i in keys) {
            cacheSound(i);
        }
    }
}
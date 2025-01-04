package backend;

import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.Assets;
import lime.utils.Assets as LimeAssets;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3D;
import lime.app.Application;

using StringTools;

/**
	Creates textures that exist only in VRAM and not standard RAM.
	Originally written by Smokey, additional developement by Rozebud.
**/

class GPUBitmap
{
	static var trackedTextures:Array<TexAsset> = new Array<TexAsset>();
	static var tasks:Array<Dynamic> = new Array<Dynamic>();

	public static function textureExists(key:String):Bool
	{
		for (tex in trackedTextures)
		{
			if (tex.cacheKey == key)
			{
				return true;
			}
		}
		return false;
	}

	/**

		* Creates BitmapData for a sprite and deletes the reference stored in RAM leaving only the texture in VRAM.
		*
		* @param   path                The file path.
		* @param   texFormat           The texture format.
		* @param   optimizeForRender   Generates mipmaps.
		* @param   cachekey            Key for the Texture Buffer cache. 
		*
	 */
	
	 public static function create(path:String, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = true, ?_cachekey:String, callback:BitmapData->Void):Void {
        if (_cachekey == null)
            _cachekey = path;

        for (tex in trackedTextures) {
            if (tex.cacheKey == _cachekey) {
                //trace('Texture $_cachekey already exists! Reusing existing tex');
                callback(BitmapData.fromTexture(tex.texture));
                return;
            }
        }

		var updateCallback:Dynamic;

        // Schedule texture creation on the main thread
		updateCallback = function(_) {
			try {
			// ImageCache.acquireMutex();
			//trace('creating new texture');
			var bmp = openfl.utils.Assets.getBitmapData(path);
			var _texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, texFormat, optimizeForRender);
			_texture.uploadFromBitmapData(bmp);
			bmp.dispose();
			bmp.disposeImage();
			var trackedTex = new TexAsset(_texture, _cachekey);
			trackedTextures.push(trackedTex);
			callback(BitmapData.fromTexture(_texture));
			removeCallback(updateCallback);
			} catch (e:Dynamic) {
				// ImageCache.releaseMutex();
			// Handle the error, e.g., log it or call the callback with null
			trace('Error creating texture: ' + e);
			try {
				trace("Trying to load backup bitmap...");
				BitmapData.loadFromFile(path).onComplete(function(fallbackBmp:BitmapData) {
					callback(createFromBitmapData(fallbackBmp));
					trace("Loaded backup bitmap.");
				}).onError(function(e) {
					trace('Error loading fallback bitmap: ' + e);
					callback(null);
				});
				removeCallback(updateCallback);
				// callback(fallbackBmp);
			} catch (e:Dynamic) {
				// ImageCache.releaseMutex();
				trace('Error loading fallback bitmap: ' + e);
				callback(null);
				removeCallback(updateCallback);
			}
			}
			// ImageCache.releaseMutex();
		};

		Application.current.onUpdate.add(updateCallback, true);
		// Store the callback to remove it later if needed
		tasks.push(updateCallback);
		// removeCallback();
    }

	static public function removeCallback(c):Void {
		Application.current.onUpdate.remove(c);
	}

	static public function removeCallbacks():Void {
		for (task in tasks) {
			Application.current.onUpdate.remove(task);
		}
		tasks = new Array<Dynamic>();
	}


	public static function createFromBitmapData(bmp:BitmapData, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = true, ?_cachekey:String):BitmapData
	{
		if (_cachekey == null)
			_cachekey = "bitmapData_" + Std.string(Math.random() * 1000000);

		for (tex in trackedTextures){
			if (tex.cacheKey == _cachekey){
				//trace('Texture $_cachekey already exists! Reusing existing tex');
				return BitmapData.fromTexture(tex.texture);
			}
		}

		//trace('creating new texture');
		var _texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, texFormat, optimizeForRender);
		_texture.uploadFromBitmapData(bmp);
		bmp.dispose();
		bmp.disposeImage();
		var trackedTex = new TexAsset(_texture, _cachekey);
		trackedTextures.push(trackedTex);
		return BitmapData.fromTexture(_texture);
	}

	public static function disposeAllTextures():Void
	{
		var counter:Int = 0;
		for (texture in trackedTextures){
			texture.texture.dispose();
			trackedTextures.remove(texture);
			counter++;
		}
		//trace('Disposed $counter textures');
	}

	public static function disposeTexturesByKey(key:String)
	{
		var counter:Int = 0;
		for (i in 0...trackedTextures.length)
		{
			if (trackedTextures[i].cacheKey.contains(key))
			{
				trackedTextures[i].texture.dispose();
				trackedTextures.remove(trackedTextures[i]);
				counter++;
			}
		}
		//trace('Disposed $counter textures using key $key');
	}

	public static function disposeAll()
	{
		for (i in 0...trackedTextures.length)
		{
			trackedTextures[i].texture.dispose();
		}

		trackedTextures = new Array<TexAsset>();

	}
}

class TexAsset
{
	public var texture:Texture;
	public var cacheKey:String;

	public function new(texture:Texture, cacheKey:String)
	{
		this.texture = texture;
		this.cacheKey = cacheKey;
	}
}
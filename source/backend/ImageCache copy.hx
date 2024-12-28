package backend;

import yutautil.save.MixSaveWrapper;
import yutautil.save.MixSave;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.util.FlxSave;
import haxe.Json;
import haxe.crypto.Base64;
import flash.utils.ByteArray;

class ImageCache {

    public static var cache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
    //private static var save:FlxSave = new FlxSave(); This was actually useless...
    public static var fileCache:MixSaveWrapper = new MixSaveWrapper(new MixSave(), "save/cache.json");

    inline public static function add(path:String):Void {
        try {
            var data:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
            data.persist = true;
            data.destroyOnNoUse = false;
            //trace(cache);
            trace(path);
            cache.set(path, data);
        } catch (e:Dynamic) {
            trace("Error adding image to cache: "+ e);
        }
    }
    public static function get(path:String):FlxGraphic {
        try {
            if (fileCache.mixSave.content.exists(path)) {
                var base64Data:String = fileCache.mixSave.content.get(path);
                var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromBase64(base64Data));
                graphic.persist = true;
                graphic.destroyOnNoUse = false;
                return graphic;
            } else {
                trace("Image not found in cache for path: " + path);
                return null;
            }
        } catch (e:Dynamic) {
            trace("Error getting image from cache: " + e);
            return null;
        }
    }

    public static function saveC():Void {
        try {
            trace("Saving cache...");
            fileCache = new MixSaveWrapper(new MixSave(), "save/cache.json", false);
            fileCache.fancyFormat = true;
            var keysArray:Array<Dynamic> = cache.toArray();
            var bytes:Array<ByteArray> = [];
            for (key in keysArray) {
                try {
                    trace("Encoding image: " + key.key);
                    var graphic:FlxGraphic = cache.get(key.key);
                    if (graphic != null && graphic.bitmap != null) {
                        var byte:ByteArray = graphic.bitmap.encode(graphic.bitmap.rect, new openfl.display.PNGEncoderOptions());
                        bytes.push(byte);
                    } else {
                        trace("Graphic or bitmapData is null for key: " + key);
                    }
                } catch (e:Dynamic) {
                    trace("Error encoding bitmap for key: " + key + " - " + e);
                }
            }
            fileCache.mixSave.content = new Map<String, String>();
            for (byte in bytes) {
                try {
                    var index = bytes.indexOf(byte);
                    var name = keysArray[index].key;
                    // trace("Saving image: " + name);
                    fileCache.mixSave.content.set(name, Base64.encode(byte));
                } catch (e:Dynamic) {
                    trace("Error encoding byte to Base64 for index: " + bytes.indexOf(byte) + " - " + e);
                }
            }
            trace("Finishing save...");
            fileCache.save();
            trace("Cache saved.");
            cache.clear();
        } catch (e:Dynamic) {
            trace("Error saving cache: " + e);
        }
        // Trace the keys in the file cache for testing purposes
        var keys = fileCache.mixSave.content.keys();
        for (key in keys) {
            trace("Cache key: " + key);
        }
    }

    public static function exists(path:String):Bool {
        try {
            if (fileCache.mixSave.content.exists(path)) {
                return true;
            } else {
                var absolutePath:String = Sys.getCwd() + "/" + path;
                return fileCache.mixSave.content.exists(absolutePath);
            }
        } catch (e:Dynamic) {
            trace("Error checking if image exists in cache: "+ e);
            return false;
        }
    }

    public static function testEncode():Void {
        // Create a small, simple bitmapData for testing
        var bitmapData:BitmapData = new BitmapData(2, 2, false, 0xFF0000); // Red square
        try {
            var bytes:ByteArray = bitmapData.encode(bitmapData.rect, new openfl.display.PNGEncoderOptions());
            var base64Data:String = Base64.encode(bytes);
            openfl.Lib.application.window.alert("Test encode success: " + base64Data);
        } catch (e:Dynamic) {
            openfl.Lib.application.window.alert("Test encode failed: " + e);
        }
    }

    

    // Function to serialize and save the cache using MixSaveWrapper
    public static function saveCache():Void {
        var cacheData:Array<{ id: String, imageData: String }> = [];
        for (id in cache.keys()) {
            var graphic:FlxGraphic = cache.get(id);
            if (graphic == null || graphic.bitmap == null) {
                trace("Graphic or bitmapData is null for id: " + id);
                continue; // Skip this iteration
            }
            var originalBitmapData:BitmapData = graphic.bitmap;
            trace("Processing id: " + id + ", size: " + originalBitmapData.width + "x" + originalBitmapData.height);
        
            // Create a new BitmapData object
            var newBitmapData:BitmapData = new BitmapData(originalBitmapData.width, originalBitmapData.height, true, 0x00000000);
            newBitmapData.draw(originalBitmapData); // Draw the original bitmap onto the new one
        
            // Encode the new BitmapData
            var bytes:ByteArray = newBitmapData.encode(newBitmapData.rect, new openfl.display.PNGEncoderOptions());
            if (bytes == null) {
                trace("Encoded bytes are null for id: " + id);
                continue; // Skip this iteration
            }
            bytes.position = 0; // Reset position before encoding to Base64
            var base64Data:String = Base64.encode(bytes);
            // Use the base64Data as needed
            cacheData.push({id: id, imageData: base64Data});
        }
        // var cacheJson:String = Json.stringify(cacheData); // Never trace this, OR WAIT FOREVER

        var save = new MixSaveWrapper(new MixSave(), "save/cache.json");
        var cacheMap:Map<String, Dynamic> = new Map<String, Dynamic>();
        for (data in cacheData) {
            cacheMap.set(data.id, data.imageData);
        }
        save.mixSave.content = cacheMap;
        save.save();
    }

    // Function to load and deserialize the cache
    public static function loadCache():Void {
        try {
            var cacheJson:MixSaveWrapper = new MixSaveWrapper(new MixSave(), "save/cache.json");
            if (cacheJson.mixSave.content.toArray().length <= 0) {
                var rawData:Array<Dynamic> = cacheJson.mixSave.content.toArray();
                var cacheData:Array<{ id: String, imageData: String }> = rawData.map(function(item:Dynamic) return { id: item.key, imageData: item.value });
                for (data in cacheData) {
                    var bytes:ByteArray = Base64.decode(data.imageData);
                    var bitmapData:BitmapData = BitmapData.fromBytes(bytes);
                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
                    graphic.persist = true;
                    graphic.destroyOnNoUse = false;
                    cache.set(data.id, graphic);
                }
            }
        }
        catch (e:Dynamic) {
            trace("Error loading cache: " + e + " Likely doesn't exist.");
        }
    }
}
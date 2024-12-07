package backend.modules;

import haxe.Timer;
import haxe.Http;
import flixel.util.FlxTimer;

class SyncUtils
{
	// Wait for a specified amount of time (in milliseconds)
	public extern inline overload static function wait(milliseconds:Int, ?conD:String):Void
	{
		if (conD != null)
		{
			trace(conD);
		}
		trace("Waiting for " + milliseconds + " milliseconds... (" + milliseconds / 1000 + " seconds.)");
		var timer = new FlxTimer();
		timer.start(milliseconds / 1000, function(nothing)
		{
			timer.active = false;
			trace("Timer completed");
		});
		wait(() -> !timer.active);
		trace("Done!");
	}

	// Wait for a specified amount of time (in seconds)
	public extern inline overload static function wait(seconds:Float, ?conD:String):Void
	{
		if (conD != null)
		{
			trace(conD);
		}
		trace("Waiting for " + seconds + " seconds...");
		var timer = new FlxTimer();
		timer.start(seconds, function(nothing)
		{
			timer.active = false;
			trace("Timer completed");
		});
		wait(() -> !timer.active);
		trace("Done!");
	}

	// Wait until a boolean condition is true
	public extern inline overload static function wait(condition:() -> Bool, ?conD:String):Void
	{
		// trace("Waiting for condition...");
		if (conD != null)
		{
			trace(conD);
		}
		else
		{
			trace("Waiting for condition...");
		}
		while (!condition())
		{
			// Busy wait
		}
		trace("Done!");
	}

	// Example of a synchronous version of an async function (e.g., HTTP request)
	public static inline function syncHttpRequest(url:String, ?post:Bool = false, ?data:Dynamic = null):String
	{
		var http = new Http(url);
		var response:String = null;
		var completed:Bool = false;

		http.onData = function(data:String)
		{
			response = data;
			completed = true;
		};

		http.onError = function(error:String)
		{
			trace("HTTP request to " + url + " failed: " + error);
			completed = true;
		};

		if (post && data != null)
		{
			http.setPostData(data);
		}

		http.request(post);

		// Wait for the HTTP request to complete
		wait(() -> completed, "Waiting for HTTP request to complete... (" + url + ")");
		trace("(HTTP request completed.)");
		// Treat empty strings as null
		return response != "" ? response : null;
	}

	// Example of a synchronous version of an async function (e.g., tween)
	// public static function syncTween(start: Float, end: Float, duration: Int): Void {
	//     trace("Starting tween from " + start + " to " + end);
	// 	var tween = FlxTween.tween(start, end, duration, { onUpdate: function(value: Float) {
	// 		// Update the value during the tween
	// 		// You can do something with the value here if needed
	// 	}});
	//     wait(() -> tween.active == false);
	//     trace("Tween completed");
	// }
}

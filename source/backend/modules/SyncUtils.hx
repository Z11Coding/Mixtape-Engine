package backend.modules;

import haxe.Timer;
import haxe.Http;

class SyncUtils {
	// Wait for a specified amount of time (in milliseconds)
	public extern overload static function wait(milliseconds: Int): Void {
		trace("Waiting for " + milliseconds + " milliseconds...");
		var timer = new Timer(milliseconds);
		timer.run = function() {
			timer.stop();
		};
		while (timer.active) {
			// Busy wait
		}
	}

	// Wait until a boolean condition is true
	public extern overload static function wait(condition: () -> Bool): Void {
		trace("Waiting for condition...");
		while (!condition()) {
			// Busy wait
		}
	}

	// Example of a synchronous version of an async function (e.g., HTTP request)
	public static function syncHttpRequest(url: String): Void {
		var http = new Http(url);
		http.onData = function(data) {
			trace("HTTP request to " + url + " completed");
		};
		http.request(false);
		wait(() -> http.responseData != null);
	}

    // Example of a synchronous version of an async function (e.g., tween)
    public static function syncTween(start: Float, end: Float, duration: Int): Void {
        trace("Starting tween from " + start + " to " + end);
        var tween = FlxTween.tween(start, end, duration, function(value: Float) {
            // Update the value during the tween
            // You can do something with the value here if needed
        });
        wait(() -> tween.active == false);
        trace("Tween completed");
    }
}


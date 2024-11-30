package undertale;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Timer;
import openfl.events.TimerEvent;

class BULLETPATTERNX {
	private var events:Array<BulletEvent>;
	private var timer:Timer;

	public function new() {
		events = [];
		timer = new Timer(1000); // Adjust the interval as needed
		timer.addEventListener(TimerEvent.TIMER, onTimer);
	}

	public function addEvent(event:BulletEvent):Void {
		events.push(event);
	}

	public function start():Void {
		timer.start();
	}

	private function onTimer(event:TimerEvent):Void {
		for (e in events) {
			if (e.shouldTrigger()) {
				e.execute();
			}
		}
	}
}

enum DamageType {
	WHITE;
	ORANGE;
	BLUE;
	RED;
}

class BULLET extends Sprite {
	public var damageType:DamageType;
    public var damage:Float;

	public function new(damageType:DamageType) {
		super();
		this.damageType = damageType;
		// Initialize sprite and hitbox here
	}

	public function checkCollision(soul:SOUL):Bool {
		// Implement collision detection with the SOUL object
		return false;
	}

	public function applyDamage(soul:SOUL):Void {
		switch (damageType) {
			case WHITE:
				soul.takeDamage(damage);
			case ORANGE:
				if (!soul.isMoving()) soul.takeDamage(damage);
			case BLUE:
				if (soul.isMoving()) soul.takeDamage(damage);
			case RED:
				soul.takeDamage(soul.health);
		}
	}
}

class BulletEvent {
	private var time:Int;
	private var action:Void -> Void;
	private var triggered:Bool;

	public function new(time:Int, action:Void -> Void) {
		this.time = time;
		this.action = action;
		this.triggered = false;
	}

	public function shouldTrigger():Bool {
		// Implement logic to check if the event should trigger based on time
		return !triggered && (getTimer() >= time);
	}

	public function execute():Void {
		action();
		triggered = true;
	}
}


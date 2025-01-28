package yutautil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.postprocess.FlxPostProcess;
import flixel.effects.postprocess.FlxBlur;

class GameCamera extends PsychCamera {
    private var blurEffect:FlxBlur;
    private var blurIntensity:Float;

    public function new() {
        super();
        blurEffect = new FlxBlur();
        blurIntensity = 0;
    }

    public function setBlurIntensity(intensity:Float):Void {
        blurIntensity = intensity;
        blurEffect.strength = intensity;
    }

    public override function update(elapsed:Float):Void {
        super.update(elapsed);
-        if (blurIntensity > 0) {
            applyBlurEffect();
        }
    }

    private function applyBlurEffect():Void {
        if (target != null) {
            blurEffect.focusX = target.x + target.width / 2;
            blurEffect.focusY = target.y + target.height / 2;
        }
        FlxG.postProcess.add(blurEffect);
    }
}
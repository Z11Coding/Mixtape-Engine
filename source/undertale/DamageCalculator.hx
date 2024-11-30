package undertale;

import undertale.*;
class DamageCalculator {

    //simplistic for now, but i plan to expand this entire class
    public static function getDamage(rating:Int, hSoul:SOUL, mSoul:MSOUL):Float {
        var initalDamage:Float = hSoul.atk;
        if (rating >= 0 && rating <= 24 || rating >= 55 && rating <= 90)
        {
            initalDamage *= FlxG.random.float(1.1, 1.3) * hSoul.LOVE;
        }
        else if (rating >= 25 && rating <= 34 || rating >= 45 && rating <= 54)
        {
            initalDamage *= FlxG.random.float(1.4, 1.9) * hSoul.LOVE;
        }
        else if (rating >= 35 && rating <= 44 && rating != 41)
        {
            initalDamage *= FlxG.random.float(2, 2.9) * hSoul.LOVE;
        }
        else if (rating == 41)
        {
            initalDamage *= FlxG.random.float(3, 50) * hSoul.LOVE;
        }
        initalDamage -= mSoul.def;
        initalDamage = Std.int(initalDamage);
        return initalDamage;
    }
}
package yutautil;

import haxe.Int64;

abstract FlatNumber(Int64) {
    public inline function new(value:Int64) {
        this = normalize(value);
    }

    @:from public static inline function fromInt(value:Int):FlatNumber {
        return new FlatNumber(value);
    }

    @:to public inline function toInt():Int {
        return this.toInt();
    }

    private static function normalize(value:Int64):Int64 {
        var result:Int64 = 0;
        var multiplier:Int64 = 1;
        while (value > 0) {
            var digit = value % 10;
            if (digit > 9) {
                digit = 9;
            }
            result += digit * multiplier;
            multiplier *= 10;
            value /= 10;
        }
        return result;
    }

    public function toString():String {
        return this.toInt().toString();
    }
}
package yutautil;

// import haxe.Random;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class CollectionUtils {
    public static function mapT<T, R>(input:Dynamic, func:T -> R):Dynamic {
        if (Std.is(input, Array)) {
            return (input: Array<T>).map(func);
        } else if (Std.is(input, IMap)) {
            var result = new Map<Dynamic, R>();
            for (key in (input: Map<Dynamic, T>).keys()) {
                result.set(key, func(input.get(key)));
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var result = [];
            for (item in (input: Iterable<T>)) {
                result.push(func(item));
            }
            return result;
        } else {
            return func(input);
        }
    }

    public static function filterT<T>(input:Dynamic, func:T -> Bool):Dynamic {
        if (Std.is(input, Array)) {
            return (input: Array<T>).filter(func);
        } else if (Std.is(input, IMap)) {
            var result = new Map<Dynamic, T>();
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                if (func(value)) {
                    result.set(key, value);
                }
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var result = [];
            for (item in (input: Iterable<T>)) {
                if (func(item)) {
                    result.push(item);
                }
            }
            return result;
        } else {
            return func(input) ? input : null;
        }
    }

    public static function forEachT<T>(input:Dynamic, func:T -> Void):Void {
        if (Std.is(input, Array)) {
            for (item in (input: Array<T>)) {
                func(item);
            }
        } else if (Std.is(input, IMap)) {
            for (key in (input: Map<Dynamic, T>).keys()) {
                func(input.get(key));
            }
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            for (item in (input: Iterable<T>)) {
                func(item);
            }
        } else {
            func(input);
        }
    }

    public static function generateRandomString(length:Int):String {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var str = "";
        for (i in 0...length) {
            str += chars.charAt(Std.random(chars.length));
        }
        return str;
    }

    public static function generateRandomNumber():Float {
        return Math.random() * 1000000;
    }

    public static function createTestData():Void {
        var stringArray = [];
        var numberArray = [];
        var stringMap = new StringMap<String>();
        var numberMap = new StringMap<Float>();

        for (i in 0...1000) {
            var randomString = generateRandomString(100);
            var randomNumber = generateRandomNumber();
            stringArray.push(randomString);
            numberArray.push(randomNumber);
            stringMap.set("key" + i, randomString);
            numberMap.set("key" + i, randomNumber);
        }

        // Test mapT function
        trace("Testing mapT function:");
        trace(mapT(stringArray, function(s) return s.toUpperCase()));
        trace(mapT(numberArray, function(n) return n * 2));
        trace(mapT(stringMap, function(s) return s.toUpperCase()));
        trace(mapT(numberMap, function(n) return n * 2));

        // Test filterT function
        trace("Testing filterT function:");
        trace(filterT(stringArray, function(s) return s.length > 50));
        trace(filterT(numberArray, function(n) return n > 500000));
        trace(filterT(stringMap, function(s) return s.length > 50));
        trace(filterT(numberMap, function(n) return n > 500000));

        // Test forEachT function
        trace("Testing forEachT function:");
        forEachT(stringArray, function(s) trace(s));
        forEachT(numberArray, function(n) trace(n));
        forEachT(stringMap, function(s) trace(s));
        forEachT(numberMap, function(n) trace(n));

        // Test ChanceSelector functions
        trace("Testing ChanceSelector functions:");

        // Create chances for stringArray
        var stringChances = ChanceSelector.fromArray(stringArray);
        trace("String chances: " + stringChances);

        // Select a random string from stringArray
        var selectedString = ChanceSelector.selectOption(stringChances);
        trace("Selected string: " + selectedString);

        // Create chances for numberArray
        var numberChances = ChanceSelector.fromArray(numberArray);
        trace("Number chances: " + numberChances);

        // Select a random number from numberArray
        var selectedNumber = ChanceSelector.selectOption(numberChances);
        trace("Selected number: " + selectedNumber);

        // Create chances for stringMap
        var stringMapChances = ChanceExtensions.chanceDynamicMap(stringMap);
        trace("String map chances: " + stringMapChances);
        // Select a random string from stringMap
        // var selectedStringFromMap = ChanceSelector.selectOption(stringMapChances);
        // trace("Selected string from map: " + selectedStringFromMap);

        // Create chances for numberMap using ChanceExtension's chanceDynamicMap
        var numberMapChances =
        ChanceExtensions.chanceDynamicMap(numberMap);
        trace("Number map chances: " + numberMapChances);

        // // Select a random number from numberMap
        // var selectedNumberFromMap = ChanceSelector.selectOption(numberMapChances);
        // trace("Selected number from map: " + selectedNumberFromMap);
    }
}
package yutautil;

// import haxe.Random;
import cpp.abi.Abi;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

// @:inline

// enum ListFunc {
//     pop;
//     get(item:T):Bool;
// }
class CollectionUtils {

    public static inline function isIterable<T>(input:Dynamic):Bool {
        return Std.is(input, Array) || Std.is(input, IMap) || (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next")));
    }

    private static function list<T>(l:List<T>):List<T> {
        return l;
    }

    public static extern overload inline function addAndReturn<T>(l:List<T>, item:T):List<T> {
        l.add(item);
        return l;
    }

    public static extern overload inline function addAndReturn<K, V>(m:Map<K, V>, key:K, value:V):Map<K, V> {
        m.set(key, value);
        return m;
    }

    public static extern overload inline function addAndReturn<T>(a:Array<T>, item:T):Array<T> {
        a.push(item);
        return a;
    }

    public static inline function funcAndReturn<T>(func:T -> Void, item:T):T {
        func(item);
        return item;
    }



    public static inline function toList<T>(input:Dynamic):List<Any>
    {
        if (Std.is(input, Array)) {
        var list = new List<T>();
    for (item in (input: Array<T>)) {
        list.add(item);
    }
    return list;
        } else if (Std.is(input, IMap)) {
            var list = new List<Any>();
            for (key in (input: Map<Dynamic, T>).keys()) {
                list.add({key: key, value: input.get(key)});
            }
            return list;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var list = new List<T>();
            for (item in (input: Iterable<T>)) {
                list.add(item);
            }
            return list;
        } else {
            return new List<T>().addAndReturn(input);
        }
    }

    public static inline function toArray<T>(input:Dynamic):Array<Any>
    {
        if (Std.is(input, Array)) {
            return input;
        } else if (Std.is(input, IMap)) {
            var result = [];
            for (key in (input: Map<Dynamic, T>).keys()) {
                result.push({key: key, value: input.get(key)});
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var result = [];
            for (item in (input: Iterable<T>)) {
                result.push(item);
            }
            return result;
        } else {
            return [input];
        }
    }

    public static inline function listIndexOf<T>(list:List<T>, item:T):Int {
        var index = 0;
        for (current in list) {
            if (current == item) {
                return index;
            }
            index++;
        }
        return -1;
    }

    public static inline function listIndex<T>(list:List<T>, index:Int):T {
        var i = 0;
        for (item in list) {
            if (i == index) {
                return item;
            }
            i++;
        }
        return null;
    }




    // public static inline function getFromList<T>(list:List<T>, func:ListFunc):Dynamic {
    //     switch (func) {
    //         case ListFunc.pop:
    //             return list.pop();
    //         case ListFunc.get(item):
    //             return list.filter(function(i) return i == item).first();
    //     }
    //     return null;
    // }

    public static inline function mapIndexOf<T>(map:Map<Dynamic, T>, item:T):Dynamic {
        for (key in map.keys()) {
            if (map.get(key) == item) {
                return key;
            }
        }
        return null;
    }

    public static inline function mapIndex<T>(map:Map<Dynamic, T>, index:Int):Dynamic {
        var i = 0;
        for (key in map.keys()) {
            if (i == index) {
                return key;
            }
            i++;
        }
        return null;
    }

    public static inline function mapKYIndexOf<K, V>(map:Map<K, V>, key:K, value:V):Int {
        var index = 0;
        for (k in map.keys()) {
            if (k == key && map.get(k) == value) {
                return index;
            }
            index++;
        }
        return -1;
    }

    public static inline function mapKYIndex<K, V>(map:Map<K, V>, index:Int):{key:K, value:V} {
        var i = 0;
        for (key in map.keys()) {
            if (i == index) {
                return {key: key, value: map.get(key)};
            }
            i++;
        }
        return null;
    }




    public static inline function mapT<T, R>(input:Dynamic, func:T -> R):Dynamic {
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

    public static inline function filterT<T>(input:Dynamic, func:T -> Bool):Dynamic {
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

    public static inline function forEachT<T>(input:Dynamic, func:T -> Void):Void {
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

    public static inline function toIterable<T>(input:Dynamic):Iterable<T> {
        if (Std.is(input, Array)) {
            return input;
        } else if (Std.is(input, IMap)) {
            var result = [];
            for (key in (input: Map<Dynamic, T>).keys()) {
                result.push(input.get(key));
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            return input;
        } else {
            return [input];
        }
    }

    public static inline function asCallable<T>(func:T -> Void):Void -> Void {
        return function() func(arguments[0]);
    }

    public static inline function asTypedCallable<T, R>(func:T -> R):T -> R {
        return func;
    }

    public static inline function toCallable<T>(item:T):Void -> T {
        return function() return item;
    }

    public static inline function forEachIf<T>(input:Dynamic, predicate:T -> Bool, func:T -> Void):Void {
        if (Std.is(input, Array)) {
            for (item in (input: Array<T>)) {
                if (predicate(item)) {
                    func(item);
                }
            }
        } else if (Std.is(input, IMap)) {
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                if (predicate(value)) {
                    func(value);
                }
            }
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            for (item in (input: Iterable<T>)) {
                if (predicate(item)) {
                    func(item);
                }
            }
        } else {
            if (predicate(input)) {
                func(input);
            }
        }
    }

    public static inline function mapTIf<T, R>(input:Dynamic, predicate:T -> Bool, func:T -> R):Dynamic {
        inline function identity<T, R>(value:T):R {
            return cast value;
        }


        if (Std.is(input, Array)) {
            return (input: Array<T>).map(function(item) return predicate(item) ? func(item) : identity(item));
        } else if (Std.is(input, IMap)) {
            var result = new Map<Dynamic, R>();
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                result.set(key, predicate(value) ? func(value) : cast value);
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var result = [];
            for (item in (input: Iterable<T>)) {
                result.push(predicate(item) ? func(item) : cast item);
            }
            return result;
        } else {
            return predicate(input) ? func(input) : input;
        }
    }

    public static inline function forEachIfElse<T>(input:Dynamic, predicate:T -> Bool, ifFunc:T -> Void, elseFunc:T -> Void):Void {
        if (Std.is(input, Array)) {
            for (item in (input: Array<T>)) {
                if (predicate(item)) {
                    ifFunc(item);
                } else {
                    elseFunc(item);
                }
            }
        } else if (Std.is(input, IMap)) {
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                if (predicate(value)) {
                    ifFunc(value);
                } else {
                    elseFunc(value);
                }
            }
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            for (item in (input: Iterable<T>)) {
                if (predicate(item)) {
                    ifFunc(item);
                } else {
                    elseFunc(item);
                }
            }
        } else {
            if (predicate(input)) {
                ifFunc(input);
            } else {
                elseFunc(input);
            }
        }
    }

    public static inline function forEachIfElseTree<T>(input:Dynamic, conditions:Map<T -> Bool, T -> Void>, elseFunc:T -> Void):Void {
        if (Std.is(input, Array)) {
            for (item in (input: Array<T>)) {
                var matched = false;
                for (predicate in conditions.keys()) {
                    if (predicate(item)) {
                        conditions.get(predicate)(item);
                        matched = true;
                        break;
                    }
                }
                if (!matched) {
                    elseFunc(item);
                }
            }
        } else if (Std.is(input, IMap)) {
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                var matched = false;
                for (predicate in conditions.keys()) {
                    if (predicate(value)) {
                        conditions.get(predicate)(value);
                        matched = true;
                        break;
                    }
                }
                if (!matched) {
                    elseFunc(value);
                }
            }
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            for (item in (input: Iterable<T>)) {
                var matched = false;
                for (predicate in conditions.keys()) {
                    if (predicate(item)) {
                        conditions.get(predicate)(item);
                        matched = true;
                        break;
                    }
                }
                if (!matched) {
                    elseFunc(item);
                }
            }
        } else {
            var matched = false;
            for (predicate in conditions.keys()) {
                if (predicate(input)) {
                    conditions.get(predicate)(input);
                    matched = true;
                    break;
                }
            }
            if (!matched) {
                elseFunc(input);
            }
        }
    }

    public static inline function mapTIfElse<T, R>(input:Dynamic, predicate:T -> Bool, ifFunc:T -> R, elseFunc:T -> R):Dynamic {
        if (Std.is(input, Array)) {
            return (input: Array<T>).map(function(item) return predicate(item) ? ifFunc(item) : elseFunc(item));
        } else if (Std.is(input, IMap)) {
            var result = new Map<Dynamic, R>();
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                result.set(key, predicate(value) ? ifFunc(value) : elseFunc(value));
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var result = [];
            for (item in (input: Iterable<T>)) {
                result.push(predicate(item) ? ifFunc(item) : elseFunc(item));
            }
            return result;
        } else {
            return predicate(input) ? ifFunc(input) : elseFunc(input);
        }
    }

    public static inline function mapTIfElseTree<T, R>(input:Dynamic, conditions:Map<T -> Bool, T -> R>, elseFunc:T -> R):Dynamic {
        if (Std.is(input, Array)) {
            return (input: Array<T>).map(function(item) {
                for (predicate in conditions.keys()) {
                    if (predicate(item)) {
                        return conditions.get(predicate)(item);
                    }
                }
                return elseFunc(item);
            });
        } else if (Std.is(input, IMap)) {
            var result = new Map<Dynamic, R>();
            for (key in (input: Map<Dynamic, T>).keys()) {
                var value = input.get(key);
                for (predicate in conditions.keys()) {
                    if (predicate(value)) {
                        result.set(key, conditions.get(predicate)(value));
                        break;
                    }
                }
                if (!result.exists(key)) {
                    result.set(key, elseFunc(value));
                }
            }
            return result;
        } else if (Reflect.hasField(input, "iterator") || (Reflect.hasField(input, "hasNext") && Reflect.hasField(input, "next"))) {
            var result = [];
            for (item in (input: Iterable<T>)) {
                for (predicate in conditions.keys()) {
                    if (predicate(item)) {
                        result.push(conditions.get(predicate)(item));
                        break;
                    }
                }
                if (result.length == 0) {
                    result.push(elseFunc(item));
                }
            }
            return result;
        } else {
            for (predicate in conditions.keys()) {
                if (predicate(input)) {
                    return conditions.get(predicate)(input);
                }
            }
            return elseFunc(input);
        }
    }

    public static inline function generateRandomString(length:Int):String {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var str = "";
        for (i in 0...length) {
            str += chars.charAt(Std.random(chars.length));
        }
        return str;
    }

    public static inline function generateRandomNumber():Float {
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
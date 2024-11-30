class ArrayToMapConverterTest {
    static function main() {
        testConvert();
        testReverseConvert();
    }

    static function testConvert() {
        var input1:Array<Array<Dynamic>> = [["key1", 1], ["key2", 2], ["key3", 3]];
        var expected1:StringMap<Dynamic> = new StringMap<Dynamic>();
        expected1.set("key1", 1);
        expected1.set("key2", 2);
        expected1.set("key3", 3);
        var result1:StringMap<Dynamic> = ArrayToMapConverter.convert(input1);
        assert(result1 == expected1);

        var input2:Array<Dynamic> = ["key", "value"];
        var expected2:StringMap<Dynamic> = new StringMap<Dynamic>();
        expected2.set("key", "value");
        var result2:StringMap<Dynamic> = ArrayToMapConverter.convert(input2);
        assert(result2 == expected2);

        // Add more test cases here...
    }

    static function testReverseConvert() {
        var input1:StringMap<Dynamic> = new StringMap<Dynamic>();
        input1.set("key1", 1);
        input1.set("key2", 2);
        input1.set("key3", 3);
        var expected1:Array<Array<Dynamic>> = [["key1", 1], ["key2", 2], ["key3", 3]];
        var result1:Array<Array<Dynamic>> = ArrayToMapConverter.reverseConvert(input1);
        assert(result1 == expected1);

        var input2:StringMap<Dynamic> = new StringMap<Dynamic>();
        input2.set("key", "value");
        var expected2:Array<Array<Dynamic>> = [["key", "value"]];
        var result2:Array<Array<Dynamic>> = ArrayToMapConverter.reverseConvert(input2);
        assert(result2 == expected2);

        // Add more test cases here...
    }

    static function assert(condition:Bool) {
        if (!condition) throw "Test failed";
    }
}
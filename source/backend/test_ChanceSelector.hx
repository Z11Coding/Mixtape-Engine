import haxe.unit.TestCase;

class ChanceSelectorTest extends TestCase {
    public function new() {
        super();
    }

    public function testSelectOption(): Void {
        var options:Array<Chance> = [
            { item: "A", chance: 50 },
            { item: "B", chance: 30 },
            { item: "C", chance: 20 }
        ];

        var selectedOption = ChanceSelector.selectOption(options);
        assertEquals(true, options.contains(selectedOption));
    }

    public function testFromArray(): Void {
        var items:Array<Dynamic> = ["A", "B", "C"];

        var options:Array<Chance> = ChanceSelector.fromArray(items);
        assertEquals(items.length, options.length);

        for (option in options) {
            assertEquals(true, items.contains(option.item));
            assertEquals(100 / items.length, option.chance);
        }
    }

    public function testChanceArrays(): Void {
        var items:Array<Dynamic> = ["A", "B", "C"];
        var chances:Array<Float> = [50, 30, 20];

        var selectedOption = ChanceSelector.chanceArrays(items, chances);
        assertEquals(true, items.contains(selectedOption.item));
    }

    public function testSelectFromOptions(): Void {
        var options:Array<Chance> = [
            { item: "A", chance: 50 },
            { item: "B", chance: 30 },
            { item: "C", chance: 20 }
        ];

        var selectedOption = ChanceSelector.selectFromOptions(options);
        assertEquals(true, options.contains(selectedOption));
    }

    public function testSelectFromMap(): Void {
        var itemChancesMap:Map<Dynamic, Float> = new Map<Dynamic, Float>();
        itemChancesMap.set("A", 50);
        itemChancesMap.set("B", 30);
        itemChancesMap.set("C", 20);

        var selectedOption = ChanceSelector.selectFromMap(itemChancesMap);
        assertEquals(true, itemChancesMap.keys().contains(selectedOption.item));
    }

    public function testExecuteChanceFunction(): Void {
        var executed:Bool = false;
        var chanceFunc:ChanceFunction = { func: function() executed = true; }, chance: 50 };

        ChanceSelector.executeChanceFunction(chanceFunc);
        assertEquals(true, executed);
    }

    public function testChanceFunction(): Void {
        var executed:Bool = false;
        var chance:Float = 50;

        ChanceSelector.chanceFunction(function() executed = true, chance);
        assertEquals(true, executed);
    }
}import haxe.unit.TestCase;

class ChanceSelectorTest extends TestCase {
    public function new() {
        super();
    }

    public function testSelectOption(): Void {
        var options:Array<Chance> = [
            { item: "A", chance: 50 },
            { item: "B", chance: 30 },
            { item: "C", chance: 20 }
        ];

        var selectedOption = ChanceSelector.selectOption(options);
        assertEquals(true, options.contains(selectedOption));
    }

    public function testFromArray(): Void {
        var items:Array<Dynamic> = ["A", "B", "C"];

        var options:Array<Chance> = ChanceSelector.fromArray(items);
        assertEquals(items.length, options.length);

        for (option in options) {
            assertEquals(true, items.contains(option.item));
            assertEquals(100 / items.length, option.chance);
        }
    }

    public function testChanceArrays(): Void {
        var items:Array<Dynamic> = ["A", "B", "C"];
        var chances:Array<Float> = [50, 30, 20];

        var selectedOption = ChanceSelector.chanceArrays(items, chances);
        assertEquals(true, items.contains(selectedOption.item));
    }

    public function testSelectFromOptions(): Void {
        var options:Array<Chance> = [
            { item: "A", chance: 50 },
            { item: "B", chance: 30 },
            { item: "C", chance: 20 }
        ];

        var selectedOption = ChanceSelector.selectFromOptions(options);
        assertEquals(true, options.contains(selectedOption));
    }

    public function testSelectFromMap(): Void {
        var itemChancesMap:Map<Dynamic, Float> = new Map<Dynamic, Float>();
        itemChancesMap.set("A", 50);
        itemChancesMap.set("B", 30);
        itemChancesMap.set("C", 20);

        var selectedOption = ChanceSelector.selectFromMap(itemChancesMap);
        assertEquals(true, itemChancesMap.keys().contains(selectedOption.item));
    }

    public function testExecuteChanceFunction(): Void {
        var executed:Bool = false;
        var chanceFunc:ChanceFunction = { func: function() executed = true; }, chance: 50 };

        ChanceSelector.executeChanceFunction(chanceFunc);
        assertEquals(true, executed);
    }

    public function testChanceFunction(): Void {
        var executed:Bool = false;
        var chance:Float = 50;

        ChanceSelector.chanceFunction(function() executed = true, chance);
        assertEquals(true, executed);
    }
}
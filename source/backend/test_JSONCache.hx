import haxe.unit.TestCase;
import backend.JSONCache;
import objects.Note;

class JSONCacheTest extends TestCase {
    public function new() {
        super();
    }

    public function testLoadJson(): Void {
        var filePath:String = "path/to/file.json";
        var callbackCalled:Bool = false;

        JSONCache.loadJson(filePath, function(data:Dynamic) {
            callbackCalled = true;
            assertNotNull(data);
        });

        assertTrue(callbackCalled);
    }

    public function testAddToCache(): Void {
        var filePath:String = "path/to/file.json";

        JSONCache.addToCache(filePath);

        assertTrue(JSONCache.exists(filePath));
    }

    public function testGet(): Void {
        var filePath:String = "path/to/file.json";
        var data:Dynamic = { "key": "value" };

        JSONCache.addToCache(filePath);
        JSONCache.update(filePath, data);

        assertEquals(data, JSONCache.get(filePath));
    }

    public function testExists(): Void {
        var filePath:String = "path/to/file.json";

        JSONCache.addToCache(filePath);

        assertTrue(JSONCache.exists(filePath));
    }

    public function testClearCache(): Void {
        var filePath:String = "path/to/file.json";

        JSONCache.addToCache(filePath);
        JSONCache.clearCache();

        assertFalse(JSONCache.exists(filePath));
    }

    public function testRemove(): Void {
        var filePath:String = "path/to/file.json";

        JSONCache.addToCache(filePath);
        JSONCache.remove(filePath);

        assertFalse(JSONCache.exists(filePath));
    }

    public function testUpdate(): Void {
        var filePath:String = "path/to/file.json";
        var data:Dynamic = { "key": "value" };

        JSONCache.addToCache(filePath);
        JSONCache.update(filePath, data);

        assertEquals(data, JSONCache.get(filePath));
    }

    public function testSave(): Void {
        var filePath:String = "path/to/file.json";
        var data:Dynamic = { "key": "value" };

        JSONCache.addToCache(filePath);
        JSONCache.update(filePath, data);
        JSONCache.save(filePath);

        var loadedData = JSONCache.get(filePath);
        assertEquals(data, loadedData);
    }

    public function testSaveAll(): Void {
        var filePath1:String = "path/to/file1.json";
        var filePath2:String = "path/to/file2.json";
        var data1:Dynamic = { "key1": "value1" };
        var data2:Dynamic = { "key2": "value2" };

        JSONCache.addToCache(filePath1);
        JSONCache.addToCache(filePath2);
        JSONCache.update(filePath1, data1);
        JSONCache.update(filePath2, data2);
        JSONCache.saveAll();

        var loadedData1 = JSONCache.get(filePath1);
        var loadedData2 = JSONCache.get(filePath2);
        assertEquals(data1, loadedData1);
        assertEquals(data2, loadedData2);
    }

    public function testLoadAll(): Void {
        var filePath1:String = "path/to/file1.json";
        var filePath2:String = "path/to/file2.json";
        var data1:Dynamic = { "key1": "value1" };
        var data2:Dynamic = { "key2": "value2" };

        JSONCache.addToCache(filePath1);
        JSONCache.addToCache(filePath2);
        JSONCache.update(filePath1, data1);
        JSONCache.update(filePath2, data2);
        JSONCache.loadAll();

        var loadedData1 = JSONCache.get(filePath1);
        var loadedData2 = JSONCache.get(filePath2);
        assertEquals(data1, loadedData1);
        assertEquals(data2, loadedData2);
    }

    public function testPrintCache(): Void {
        var filePath:String = "path/to/file.json";
        var data:Dynamic = { "key": "value" };

        JSONCache.addToCache(filePath);
        JSONCache.update(filePath, data);

        // Redirect trace output to a variable
        var output:String = "";
        var oldTrace = trace;
        trace = function(msg:Dynamic) {
            output += msg + "\n";
        };

        JSONCache.printCache();

        // Restore trace function
        trace = oldTrace;

        assertTrue(output.contains(filePath));
        assertTrue(output.contains("value"));
    }

    public function testPushCache(): Void {
        var filePath:String = "path/to/file.json";
        var data:Dynamic = { "key": "value" };

        JSONCache.addToCache(filePath);
        JSONCache.update(filePath, data);

        var cacheCopy = JSONCache.pushCache();

        assertEquals(data, cacheCopy.get(filePath));
    }

    public function testPopCache(): Void {
        var filePath:String = "path/to/file.json";
        var data:Dynamic = { "key": "value" };
        var newCache:Map<String, Dynamic> = new Map<String, Dynamic>();

        JSONCache.addToCache(filePath);
        JSONCache.update(filePath, data);
        newCache.set(filePath, { "newKey": "newValue" });

        JSONCache.popCache(newCache);

        assertEquals(newCache.get(filePath), JSONCache.get(filePath));
    }

    public function testCharts(): Void {
        var filePath1:String = "path/to/file1.json";
        var filePath2:String = "path/to/file2.json";
        var data1:Dynamic = { "notes": [{ "sectionNotes": {} }] };
        var data2:Dynamic = { "notes": [{ "sectionNotes": {} }, { "sectionNotes": {} }] };

        JSONCache.addToCache(filePath1);
        JSONCache.addToCache(filePath2);
        JSONCache.update(filePath1, data1);
        JSONCache.update(filePath2, data2);

        var chartList = JSONCache.charts();

        assertTrue(chartList.contains(filePath1));
        assertTrue(chartList.contains(filePath2));
    }
}
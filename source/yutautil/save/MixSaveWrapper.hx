package yutautil.save;

import sys.io.File;

using yutautil.save.MixSave;

class MixSaveWrapper {
    public var mixSave:MixSave;
    private var filePath:String;

    public function new(mixSave:MixSave, filePath:String = "save/mixsave.json") {
        this.mixSave = mixSave;
        this.filePath = filePath;
        if (!filePath.endsWith(".json")) {
            filePath += ".json";
            this.filePath = filePath;
        }
        if (sys.FileSystem.exists(filePath)) {
            load();
        }
    }

    public function save():Void {
        var fileContent = new Map<String, String>();
        for (key in mixSave.content.keys()) {
            fileContent.set(key, mixSave.saveContent(key));
        }
        if (!sys.FileSystem.exists(haxe.io.Path.directory(filePath))) {
            sys.FileSystem.createDirectory(haxe.io.Path.directory(filePath));
        }
        File.saveContent(filePath, haxe.Json.stringify(fileContent));
    }

    public function load():Void {
        if (sys.FileSystem.exists(filePath)) {
            var jsonContent = File.getContent(filePath);
            var parsedContent = haxe.Json.parse(jsonContent);
            var fileContent:Map<String, String> = new Map();
            for (key in Reflect.fields(parsedContent)) {
                fileContent.set(key, Reflect.field(parsedContent, key));
            }
            trace(fileContent);
            for (key in fileContent.keys()) {
                mixSave.loadContent(key, fileContent.get(key));
            }
        }
    }
}
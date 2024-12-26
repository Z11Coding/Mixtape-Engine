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
            filepath += ".json";
        }
        if (File.exists(filePath)) {
            load();
        }
    }

    public function save():Void {
        var fileContent = new Map<String, String>();
        for (key in mixSave.content.keys()) {
            fileContent.set(key, mixSave.saveContent(key));
        }
        if (!sys.FileSystem.exists(sys.FileSystem.directory(filePath))) {
            sys.FileSystem.createDirectory(sys.FileSystem.directory(filePath));
        }
        File.saveContent(filePath, haxe.Json.stringify(fileContent));
    }

    public function load():Void {
        if (File.exists(filePath)) {
            var fileContent = haxe.Json.parse(File.getContent(filePath));
            for (key in fileContent.keys()) {
                mixSave.loadContent(key, fileContent.get(key));
            }
        }
    }
}
package backend;

// import backend.modules.SyncUtils;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
import haxe.io.Bytes;
import haxe.macro.Type;
import haxe.macro.Compiler;

class Embed {

    public static var globalMaps:Array<Map<String, Bytes>> = [];
    public static var fileHandlers:Map<String, String -> Bytes> = new Map();

    public static macro function embedFile(filePath:String, global:Bool = false):Expr {
        // Read the file content as bytes
        var fileContent:Bytes = handleFile(filePath);

        // backend.modules.SyncUtils.wait(() -> fileContent != null || fileContent.length > 0);
        trace("Embedding file: " + filePath);
        trace("File: + " + fileContent);

        // Store in global maps if global is true
        if (global) {
            var varName = filePath.split("/").pop().split(".")[0];
            for (map in globalMaps) {
                if (map.exists(varName)) {
                    Context.error("Duplicate file embed found: " + varName, Context.currentPos());
                }
            }
            var newMap = new Map<String, Bytes>();
            newMap.set(varName, fileContent);
            globalMaps.push(newMap);
            return macro $v{fileContent};
        } else {
            return macro $v{fileContent};
        }
    }

    public static function defineFileHandler(extension:String, handler:String -> Dynamic):Void {
        fileHandlers.set(extension, handler);
    }

    private static function handleFile(filePath:String):Dynamic {
        var extension = filePath.split(".").pop();
        if (fileHandlers.exists(extension)) {
            return fileHandlers.get(extension)(filePath);
        } else {
            return File.getBytes(filePath);
        }
    }
}
package backend;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Type;
import haxe.macro.Compiler;
import haxe.xml.Parser;

class Embed {

    public static var globalMap:Map<String, String> = new Map();
    public static macro function embedFile(filePath:String, global:Bool = false):Expr {
        // Read the file content
        var fileContent:String = File.getContent(filePath);

        // Determine the output directory from project.xml
        var outputDir = getOutputDirectory(filePath);

        // Schedule file deletion after generation
        Context.onAfterGenerate(function() {
            var outputFilePath = outputDir + "/" + filePath;
            if (FileSystem.exists(outputFilePath)) {
                FileSystem.deleteFile(outputFilePath);
            }
        });



        // Store in global map if global is true
        if (global) {
            var varName = filePath.split("/").pop().split(".")[0];
            globalMap.set(varName, fileContent);
            return macro {
                $v{fileContent};
            };
        } else {
            return macro $v{fileContent};
        }
    }

    private static function getOutputDirectory(filePath:String):String {
        // Parse project.xml to find the output directory and handle renames
        var projectXml = File.getContent("project.xml");
        var xml = Parser.parse(projectXml);
        var outputDir = "bin"; // Default output directory
    
        for (asset in xml.elementsNamed("assets")) {
            var path = asset.get("path");
            var rename = asset.get("rename");
            var condition = asset.get("if");
            var unlessCondition = asset.get("unless");
    
            // Check if the condition is met
            var conditionMet = true;
            if (condition != null) {
                conditionMet = Context.defined(condition);
            }
            if (unlessCondition != null) {
                conditionMet = !Context.defined(unlessCondition);
            }
    
            if (conditionMet && path != null && filePath.startsWith(path)) {
                if (rename != null) {
                    filePath = filePath.replace(path, rename);
                }
                break;
            }
        }
    
        var regex = ~/output\s*=\s*"(.*?)"/;
        var match = regex.match(projectXml);
        if (match != null) {
            outputDir = match.matched(1);
        }
    
        return outputDir;
    }
}
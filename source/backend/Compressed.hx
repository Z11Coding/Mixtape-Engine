package backend;

package backend;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.Serializer;
import haxe.Unserializer;

class Compressed<T> {
    public var original:T;
    public var compressed:Bytes;
    public var compressionMethod:Int;

    public function new(value:T) {
        this.original = value;
        this.compressed = null;
        this.compressionMethod = -1;

        // Check if the value is a class with compress and uncompress methods
        var methods = [
            {method: compressBase64, id: 1},
            {method: compressByteData, id: 2}
            // Add more compression methods here
        ];

        if (Reflect.hasField(value, "compress") && Reflect.hasField(value, "uncompress")) {
            var compressedValue = Reflect.callMethod(value, Reflect.field(value, "compress"), []);
            this.compressed = compressData(compressedValue);
            this.compressionMethod = 0; // Custom compression method
            // methods.push({method: (v) -> this.compressed, id: 0});
        }

        var minSize = Int.MAX_VALUE;
        for (method in methods) {
            var compressedData = method.method(value);
            if (compressedData.length < minSize) {
            minSize = compressedData.length;
            this.compressed = compressedData;
            this.compressionMethod = method.id;
            }
        }

            var minSize = Int.MAX_VALUE;
            for (method in methods) {
                var compressedData = method.method(value);
                if (compressedData.length < minSize) {
                    minSize = compressedData.length;
                    this.compressed = compressedData;
                    this.compressionMethod = method.id;
                }
            }
        }

    private function compressData(data:Dynamic):Bytes {
        var serialized = Serializer.run(data);
        return Bytes.ofString(serialized);
    }

    private static function compressBase64(value:Dynamic):Bytes {
        var serialized = Serializer.run(value);
        var base64 = Base64.encode(Bytes.ofString(serialized));
        return base64;
    }

    private static function compressByteData(value:Dynamic):Bytes {
        var serialized = Serializer.run(value);
        return Bytes.ofString(serialized);
    }

    public function uncompress():T {
        if (this.compressionMethod == 0) {
            var uncompressedValue = Reflect.callMethod(this.original, Reflect.field(this.original, "uncompress"), []);
            return cast uncompressedValue;
        } else {
            var serialized = this.compressed.toString();
            var unserialized = Unserializer.run(serialized);
            return cast unserialized;
        }
    }
}
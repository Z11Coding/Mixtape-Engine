import backend.modules.SoundGroup;
import backend.modules.SoundLayer;
import flixel.system.FlxSound;

class SoundGroupTest {
    static function main() {
        var soundPaths:Map<String, String> = new Map<String, String>();
        soundPaths.set("sound1", "path/to/sound1.mp3");
        soundPaths.set("sound2", "path/to/sound2.mp3");

        var group:SoundGroup = SoundGroup.createGroupFromFiles(soundPaths);

        // Test adding layers
        var layer1:SoundLayer = new SoundLayer("layer1", "path/to/layer1.mp3");
        var layer2:SoundLayer = new SoundLayer("layer2", "path/to/layer2.mp3");
        group.addLayer(layer1);
        group.addLayer(layer2);

        // Test playing all layers
        group.playAll();

        // Test stopping all layers
        group.stopAll();

        // Test setting volume for a specific layer
        group.setVolumeForLayer("layer1", 0.5);

        // Test FlxSound properties
        var sound:FlxSound = group.layers[0].sound;
        sound.volume = 0.8;
        sound.looped = false;

        // Test SoundLayer methods
        layer1.play();
        layer1.stop();
        layer1.setVolume(0.7);
    }
}
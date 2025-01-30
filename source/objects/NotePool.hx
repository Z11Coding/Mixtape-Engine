package objects;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import backend.Conductor;
import objects.playfields.PlayField;
import objects.Note;

class NotePool
{
    private static var _instance:NotePool;
    public static var instance(get, null):NotePool;

    private static function get_instance():NotePool {
        if (_instance == null) _instance = new NotePool();
        return _instance;
    }

    // The FlxManager instance for managing notes
    private var _manager:yutautil.FlxManager;

    // A reference to the PlayField
    private var _playField:PlayField;

    // Timer for spawning notes
    private var _spawnTimer:FlxTimer;

    public function new() {
        _manager = new yutautil.FlxManager("noteManager");
        _spawnTimer = new FlxTimer();
    }

    /**
     * Initialize the NotePool with a PlayField and an array of notes to spawn.
     * @param playField The PlayField instance to manage notes for.
     * @param notes An array of `PreloadedChartNote` objects.
     */
    public function initialize(playField:PlayField, notes:Array<PreloadedChartNote>):Void {
        _playField = playField;
        _playField.noteQueue = []; // Clear the note queue
        _playField.spawnedNotes = []; // Clear the spawned notes

        // Queue the notes into the PlayField
        for (noteData in notes) {
            var note:Note = getNote();
            note.resetNote(noteData.strumTime, noteData.noteData, noteData.isSustainNote, null);
            _playField.queue(note);
        }

        startSpawning();
    }

    /**
     * Start spawning notes based on their strumTime.
     */
    private function startSpawning():Void {
        if (_playField.noteQueue.length == 0) return;

        // Schedule the first note to spawn
        scheduleNextNote();
    }

    /**
     * Schedule the next note to spawn.
     */
    private function scheduleNextNote():Void {
        var nextNote:Note = getNextNote();
        if (nextNote == null) return;

        var timeUntilSpawn:Float = nextNote.strumTime - Conductor.songPosition;

        if (timeUntilSpawn <= 0) {
            // If the note is already overdue, spawn it immediately
            spawnNote(nextNote);
            scheduleNextNote();
        } else {
            // Schedule the note to spawn in the future
            _spawnTimer.start(timeUntilSpawn / 1000, function(timer:FlxTimer) {
                spawnNote(nextNote);
                scheduleNextNote();
            });
        }
    }

    /**
     * Get the next note to spawn from the PlayField's note queue.
     * @return The next `Note` to spawn, or `null` if there are no more notes.
     */
    private function getNextNote():Note {
        for (column in _playField.noteQueue) {
            if (column.length > 0) {
                return column[0];
            }
        }
        return null;
    }

    /**
     * Spawn a note and add it to the PlayField.
     * @param note The `Note` to spawn.
     */
    private function spawnNote(note:Note):Void {
        _playField.spawnNote(note);
    }

    /**
     * Get a note from the pool or create a new one if the pool is empty.
     * @return A `Note` object.
     */
    public function getNote():Note {
        var note:Note = cast _manager.getObject(Note);
        if (note == null) {
            note = new Note();
        }
        return note;
    }

    /**
     * Return a note to the pool when it's no longer needed.
     * @param note The note to return.
     */
    public function returnNote(note:Note):Void {
        _manager.returnObject(note);
        _playField.removeNote(note);
    }

    /**
     * Update the NotePool (called every frame).
     */
    public function update(elapsed:Float):Void {
        // Check for notes that are offscreen and return them to the pool
        for (note in _playField.spawnedNotes) {
            if (note != null && note.exists && note.strumTime < Conductor.songPosition - Conductor.safeZoneOffset) {
                returnNote(note);
            }
        }
    }
}
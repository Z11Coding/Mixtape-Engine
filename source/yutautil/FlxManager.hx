package yutautil;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfFour;
import flixel.FlxG;

typedef FuncType<T> = OneOfFour<
    T->Dynamic, T->Void, ()->Dynamic, ()->Void
>;

typedef Confirmer<T> = OneOfTwo<
    T->Bool, ()->Bool
>;

typedef ContainerFunction<T> = OneOfTwo<
    FuncType<T>, Confirmer<T>
>;

class FlxManager extends FlxBasic {
    // Consolidated object tracking
    private var trackedObjects:Map<FlxBasic, ObjectData> = new Map();

    // Object pooling
    private var objectPool:Map<String, Array<FlxBasic>> = new Map();

    public static var globalAccesses:Map<String, FlxManager> = new Map();

    public function new(?name:String) {
        super();
        init();
        if (name != null) {
            globalAccesses.set(name, this);
        } else {
            trace("Warining: FlxManager created without a name. It will not be accessible globally.");
        }
    }

    public function init():Void {
        // Listen for state switches to clean up objects
        FlxG.signals.preStateSwitch.add(onStateSwitch);
    }

    // Add an object to the manager
    public function addObject(obj:FlxBasic):Void {
        if (obj != null && !trackedObjects.exists(obj)) {
            trackedObjects.set(obj, new ObjectData());
        }
    }

    // Add an object to a group
    public function addToGroup(group:FlxGroup, obj:FlxBasic):Void {
        if (group != null && obj != null) {
            group.add(obj);
            var data = trackedObjects.get(obj);
            if (data != null) {
                data.groups.push(group);
            } else {
                trackedObjects.set(obj, new ObjectData([group]));
            }
        }
    }

    // Add an object to a state
    public function addToState(state:FlxState, obj:FlxBasic):Void {
        if (state != null && obj != null) {
            state.add(obj);
            var data = trackedObjects.get(obj);
            if (data != null) {
                data.states.push(state);
            } else {
                trackedObjects.set(obj, new ObjectData([], [state]));
            }
        }
    }

    // Add an object to an array
    public function addToArray(array:Array<Dynamic>, obj:Dynamic):Void {
        if (array != null && obj != null) {
            array.push(obj);
            var data = trackedObjects.get(obj);
            if (data != null) {
                data.arrays.push(array);
            } else {
                trackedObjects.set(obj, new ObjectData([], [], [array]));
            }
        }
    }

    // Add an object to a custom container
    public function addToContainer<T>(container:T, obj:Dynamic, addMethod:ContainerFunction<T>, removeMethod:ContainerFunction<T>):Void {
        if (container != null && obj != null) {
            Reflect.callMethod(container, cast addMethod, [obj]);
            var data = trackedObjects.get(obj);
            if (data != null) {
                data.containers.push(new ContainerData<T>(container, addMethod, removeMethod));
            } else {
                trackedObjects.set(obj, new ObjectData([], [], [], [new ContainerData<T>(container, addMethod, removeMethod)]));
            }
        }
    }

    // Get an object from the pool or create a new one
    public function getObject(type:Class<FlxBasic>):FlxBasic {
        var key = Type.getClassName(type);
        if (objectPool.exists(key) && objectPool.get(key).length > 0) {
            var obj = objectPool.get(key).pop();
            obj.revive(); // Reactivate the object
            return obj;
        }
        return Type.createInstance(type, []);
    }

    public function getObjectWithArgs(type:Class<FlxBasic>, args:Array<Dynamic>):FlxBasic {
        var key = Type.getClassName(type);
        if (objectPool.exists(key) && objectPool.get(key).length > 0) {
            var obj = objectPool.get(key).pop();
            obj.revive(); // Reactivate the object
            return obj;
        }
        return Type.createInstance(type, args);
    }

    // Return an object to the pool
    public function returnObject(obj:FlxBasic):Void {
        if (obj != null) {
            var key = Type.getClassName(Type.getClass(obj));
            if (!objectPool.exists(key)) {
                objectPool.set(key, []);
            }
            objectPool.get(key).push(obj);
            obj.kill(); // Deactivate the object
            destroyObject(obj, false); // Clean up without destroying
        }
    }

        // Mark an object as protected
        public function protectObject(obj:FlxBasic):Void {
            if (obj != null) {
            if (!trackedObjects.exists(obj)) {
                addObject(obj);
            }
            trackedObjects.get(obj).protected = true;
            }
        }
        
        // Unmark an object as protected
        public function unprotectObject(obj:FlxBasic):Void {
            if (obj != null) {
            if (!trackedObjects.exists(obj)) {
                addObject(obj);
            }
            trackedObjects.get(obj).protected = false;
            }
        }
    

    // Destroy an object and clean up references
    public function destroyObject(obj:FlxBasic, destroy:Bool = true):Void {
        if (obj == null || trackedObjects.get(obj).protected) return;

        var data = trackedObjects.get(obj);
        if (data != null) {
            // Remove from groups
            for (group in data.groups) {
                group.members.remove(obj);
            }
            // Remove from states
            for (state in data.states) {
                state.members.remove(obj);
            }
            // Remove from arrays
            for (array in data.arrays) {
                array.remove(obj);
            }
            // Remove from containers
            for (containerData in data.containers) {
                try {
                    Reflect.callMethod(containerData.container, cast containerData.removeMethod, [obj]);
                } catch (e:Dynamic) {
                    trace('Error removing object from container: ' + e);
                }
            }
            // Remove from tracked objects
            trackedObjects.remove(obj);
        }

        // Destroy the object if requested
        if (destroy && obj != null) {
            obj.destroy();
        }
    }

    // Clean up all objects before switching states
    private function onStateSwitch():Void {
        for (obj in trackedObjects.keys()) {
            destroyObject(obj);
        }
        trackedObjects.clear();
    }

    // Debugging: Log the number of tracked objects
    public function logObjectCount():Void {
        trace('Tracked Objects: ' + trackedObjects.keys().lengthTo());
    }
}

// Metadata for tracked objects
class ObjectData {
    public var groups:Array<FlxGroup>;
    public var states:Array<FlxState>;
    public var arrays:Array<Array<Dynamic>>;
    public var containers:Array<ContainerData<Dynamic>>;
    public var protected:Bool = false;

    public function new(?groups:Array<FlxGroup>, ?states:Array<FlxState>, ?arrays:Array<Array<Dynamic>>, ?containers:Array<ContainerData<Dynamic>>) {
        this.groups = groups != null ? groups : [];
        this.states = states != null ? states : [];
        this.arrays = arrays != null ? arrays : [];
        this.containers = containers != null ? containers : [];
    }
}

// Data for custom containers
class ContainerData<T> {
    public var container:T;
    public var addMethod:ContainerFunction<T>;
    public var removeMethod:ContainerFunction<T>;

    public function new(container:T, addMethod:ContainerFunction<T>, removeMethod:ContainerFunction<T>) {
        this.container = container;
        this.addMethod = addMethod;
        this.removeMethod = removeMethod;
    }
}
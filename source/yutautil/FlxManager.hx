package yutautil;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfFour;

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
    private var objects:Array<FlxBasic>;
    private var groups:Array<FlxGroup>;
    private var states:Array<FlxState>;
    private var arrays:Array<Array<Dynamic>>;
    private var containers:Array<ContainerData<Dynamic>>;

    public function new() {
        objects = [];
        groups = [];
        states = [];
        arrays = [];
        containers = [];
        super();
    }

    public function addObject(obj:FlxBasic):Void {
        if (obj != null) {
            objects.push(obj);
        }
    }

    public function addGroup(group:FlxGroup):Void {
        if (group != null) {
            groups.push(group);
        }
    }

    public function addState(state:FlxState):Void {
        if (state != null) {
            states.push(state);
        }
    }

    public function addToArray(array:Array<Dynamic>, obj:Dynamic):Void {
        if (array != null && obj != null) {
            array.push(obj);
            arrays.push(array);
            objects.push(obj);
        }
    }

    public function addToArrayAt(array:Array<Dynamic>, obj:Dynamic, index:Int):Void {
        if (array != null && obj != null) {
            array.insert(index, obj);
            arrays.push(array);
            objects.push(obj);
        }
    }

    public function addToState(state:FlxState, obj:Dynamic):Void {
        if (state != null && obj != null) {
            state.add(obj);
            states.push(state);
            objects.push(obj);
        }
    }

    public function addToGroup(group:FlxGroup, obj:Dynamic):Void {
        if (group != null && obj != null) {
            group.add(obj);
            groups.push(group);
            objects.push(obj);
        }
    }

    public function insertIntoGroup(group:FlxGroup, obj:Dynamic, index:Int):Void {
        if (group != null && obj != null) {
            group.members.insert(index, obj);
            groups.push(group);
            objects.push(obj);
        }
    }

    public function insertIntoState(state:FlxState, obj:Dynamic, index:Int):Void {
        if (state != null && obj != null) {
            state.members.insert(index, obj);
            states.push(state);
            objects.push(obj);
        }
    }

    public function addToContainer<T>(container:T, obj:Dynamic, addMethod:ContainerFunction<T>, removeMethod:ContainerFunction<T>):Void {
        if (container != null && obj != null) {
            Reflect.callMethod(container, cast addMethod, [obj]);
            containers.push(new ContainerData<T>(container, addMethod, removeMethod));
            objects.push(obj);
        }
    }

    public override function update(e:Float):Void {
        for (obj in objects) {
            if (obj != null) {
                // obj.update();
            } else {
                destroyObject(obj);
            }
        }
    }

    private function destroyObject(obj:FlxBasic):Void {
        // Remove from objects array
        objects.remove(obj);
        // Remove from any groups
        for (group in groups) {
            group.members.remove(obj);
        }
        // Remove from any arrays
        for (array in arrays) {
            array.remove(obj);
        }
        // Remove from any containers
        for (containerData in containers) {
            try {
                Reflect.callMethod(containerData.container, cast containerData.removeMethod, [obj]);
            } catch (e:Dynamic) {
                trace('Error removing object from container: ' + e);
            }
        }
        // If the object is not null, call destroy on it
        if (obj != null) {
            obj.destroy();
        }
        // Nullify references
        obj = null;
    }

    public function manualDestroy(obj:FlxBasic):Void {
        destroyObject(obj);
    }

    // public function manualUpdate():Void {
    //     // update();
    // }

    public static function testContainer():Void {
        var list = new PyList<FlxBasic>();
        var manager = new FlxManager();
        var obj = new FlxBasic();
        manager.addToContainer(list, obj, list.add, list.items.remove);
        manager.update(0);
        trace(list.items);
        var list2 = new PyList<FlxBasic>();
        var obj2 = new FlxBasic();
        // trace(listTogether.items);
    }
}

class ContainerData<T> {
    public var container:T;
    public var addMethod:ContainerFunction<T>;
    public var removeMethod:ContainerFunction<T>;

    public function new(container:T, addMethod:FuncType<T>, removeMethod:FuncType<T>) {
        this.container = container;
        this.addMethod = addMethod;
        this.removeMethod = removeMethod;
    }
}


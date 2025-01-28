package yutautil;

class PyList<T> {
    public var items:Array<T>;

    public function new(initialItems:Array<T> = null) {
        this.items = initialItems != null ? initialItems : [];
    }

    public function add(item:T):Void {
        this.items.push(item);
    }

    public function concat(other:PyList<T>):PyList<T> {
        return new PyList<T>(this.items.concat(other.items));
    }
    @:op(A + B)
    public static function opPlus<T>(A:PyList<T>, B:PyList<T>):PyList<T> {
        return A.concat(B);
    }

    public function toString():String {
        return '[' + this.items.join(', ') + ']';
    }
}
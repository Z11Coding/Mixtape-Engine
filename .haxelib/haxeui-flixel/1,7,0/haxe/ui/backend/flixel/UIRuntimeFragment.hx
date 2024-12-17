package haxe.ui.backend.flixel;

import haxe.ui.RuntimeComponentBuilder;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import haxe.ui.events.EventType;
import haxe.ui.backend.flixel.UIRTTITools.*;

using StringTools;

@:rtti
class UIRuntimeFragment extends UIFragmentBase implements IComponentDelegate { // uses rtti to "build" a class with a similar experience to using macros
	public var root:Component;

	public function new() {
		super();

		scrollFactor.set(0, 0); // ui doesn't scroll by default

        var rtti = haxe.rtti.Rtti.getRtti(Type.getClass(this));
        root = buildViaRTTI(rtti);
        linkViaRTTI(rtti, this, root);
        if (root != null) {
            root.registerEvent(UIEvent.READY, (_) -> {
                onReady();
            });
            add(root);
        }
	}

    private function onReady() {
    }

    public var component(get, set):Component;
    private function get_component():Component {
        return root;
    }
    private function set_component(value:Component):Component {
        root = value;
        var rtti = haxe.rtti.Rtti.getRtti(Type.getClass(this));
        linkViaRTTI(rtti, this, root);
        return value;
    }

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// util functions
	/////////////////////////////////////////////////////////////////////////////////////////////////
	public function addComponent(child:Component):Component {
		if (root == null) {
			throw "no root component";
		}

		return root.addComponent(child);
	}

	public function removeComponent(child:Component):Component {
		if (root == null) {
			throw "no root component";
		}

		return root.removeComponent(child);
	}

	public function findComponent<T:Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
		if (root == null) {
			throw "no root component";
		}

		return root.findComponent(criteria, type, recursive, searchType);
	}

	public function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
		if (root == null) {
			throw "no root component";
		}

		return root.findComponents(styleName, type, maxDepth);
	}

	public function findAncestor<T:Component>(criteria:String = null, type:Class<T> = null, searchType:String = "id"):Null<T> {
		if (root == null) {
			throw "no root component";
		}

		return root.findAncestor(criteria, type, searchType);
	}

	public function findComponentsUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Array<Component> {
		if (root == null) {
			throw "no root component";
		}

		return root.findComponentsUnderPoint(screenX, screenY, type);
	}

    public function dispatch<T:UIEvent>(event:T) {
		if (root == null) {
			throw "no root component";
		}

        root.dispatch(event);
    }

    public function registerEvent<T:UIEvent>(type:EventType<T>, listener:T->Void, priority:Int = 0) {
		if (root == null) {
			throw "no root component";
		}

        root.registerEvent(type, listener, priority);
    }

	public function show() {
		if (root == null) {
			throw "no root component";
		}
		root.show();
	}

	public function hide() {
		if (root == null) {
			throw "no root component";
		}
		root.hide();
	}

	public override function destroy() {
		if (root != null) {
			remove(root);
		}
		root = null;
	}
}
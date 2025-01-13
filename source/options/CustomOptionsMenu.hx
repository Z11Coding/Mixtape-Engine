package options;

import haxe.macro.Expr.Var;



class CustomOptionsMenu extends BaseOptionsMenu {

    private static var GlobalOptionsMenuArray:Array<CustomOptionsMenu> = [];

	public function new() {
		super();
	}

    public function createCustomMenu(
        title:String, 
        options:Array<options.Option.VarOption>, 
        rpcTitle:String = null, 
        openImmediately:Bool = false, 
        registerGlobally:Bool = false
    ):CustomOptionsMenu {
        this.title = title;
        this.rpcTitle = rpcTitle != null ? rpcTitle : "Custom Options"; // for Discord Rich Presence

        for (option in options) {
            addOption(option);
        }

        if (registerGlobally) {
            // Remove existing menu with the same title
            for (i in 0...GlobalOptionsMenuArray.length) {
                if (GlobalOptionsMenuArray[i].title == title) {
                    GlobalOptionsMenuArray.splice(i, 1);
                    break;
                }
            }
            GlobalOptionsMenuArray.push(this);
        }

        if (openImmediately) {
            openMenu();
        }

        return this;
    }

    private function openMenu():Void {
        FlxG.state.openSubState(this);
    }

    public function doClose():Void {
        for (option in optionsArray) {
            option.setValue(option.getValue());
        }

        close()
        }

    public static function openCustomOptionsMenu(title:String):Void {
        for (menu in GlobalOptionsMenuArray) {
            if (menu.title == title) {
                menu.openMenu();
                return;
            }
        }
        trace("Menu with title '" + title + "' not found");
    }
}

// class TempOption extends Option {
//     public var key:String;
//     public var defaultValue:Dynamic;
//     private var getter:Void -> Dynamic;
//     private var setter:Dynamic -> Void;
//     public var immediateUpdate:Bool = false;

//     public function new(title:String, description:String, key:String, type:String, ?options:Array<String>, ?defaultValue:Dynamic, getter:Void -> Dynamic = null, setter:Dynamic -> Void = null) {
//         super(title, description, null, type, options); // key is used for the variable
//         this.key = key;
//         this.defaultValue = defaultValue != null ? defaultValue : getDefaultByType(type);
//         this.getter = getter;
//         this.setter = setter;
//     }

//     private function getDefaultByType(type:String):Dynamic {
//         switch (type) {
//             case "bool":
//                 return false;
//             case "int":
//                 return 0;
//             case "float":
//                 return 0;
//             case "percent":
//                 return 1;
//             case "string":
//                 return "";
//             case "keybind":
//                 return {gamepad: "NONE", keyboard: "NONE"};
//             default:
//                 return null;
//         }
//     }

//     private function whenChanged():Void {
//         if (this.onChange != null) {
//             this.onChange();
//         }
//         // Use setValue and getValue

        
//     }

//     public function getValue():Dynamic {
//         if (this.getter != null && this.immediateUpdate) {
//             return this.getter();
//         }
//         // Implement logic to get the value of the variable by key
//         return Reflect.field(Reflect.getProperty(Reflect, this.key), this.key) != null ? Reflect.field(Reflect.getProperty(Reflect, this.key), this.key) : this.defaultValue;
//     }

//     public function setValue(value:Dynamic):Void {
//         if (this.setter != null) {
//             this.setter(value);
//         } else {
//             // Implement logic to set the value of the variable by key
//             Reflect.setField(Reflect.getProperty(Reflect, this.key), this.key, value);
//         }
//     }
// }




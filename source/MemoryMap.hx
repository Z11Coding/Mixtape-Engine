import haxe.macro.Expr;
import haxe.macro.Context;

#if useHTable
// import haxe.ds.HTable;
#else
import haxe.ds.Map;
#end

class MemoryMapMacro {
    #if useHTable
    // public static var memoryMap:HTable<String, Dynamic> = new HTable<String, Dynamic>();
    #else
    public static var memoryMap:Map<String, Dynamic> = new Map<String, Dynamic>();
    #end

    public static macro function trackVariable(expr:Expr):Expr {
        return switch (expr.expr) {
            case EVars(vars):
                var newVars = vars.map(function(v) {
                    var name = v.name;
                    var init = v.expr;
                    if (init != null) {
                        var resourceName = name;
                        return {
                            name: name,
                            type: v.type,
                            expr: macro {
                                var value = $init;
                                MemoryMapMacro.memoryMap.set($resourceName, value);
                                value;
                            }
                        };
                    } else {
                        return v;
                    }
                });
                return { expr: EVars(newVars), pos: expr.pos };
            default:
                expr;
        };
    }

    public static function updateVariable(name:String, value:Dynamic):Void {
        memoryMap.set(name, value);
    }
}

package;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class SwitchStateMacro {
    public static function checkSwitchState():Void {
        Context.onAfterTyping(function(exprs:Array<Expr>):Array<Expr> {
            for (i in 0...exprs.length) {
                exprs[i] = macroTransform(exprs[i]);
            }
            return exprs;
        });
    }

    static function macroTransform(expr:Expr):Expr {
        return switch (expr.expr) {
            case ECall(e, args):
                switch (e.expr) {
                    case EField(obj, field) if (field == "switchState" && obj.expr == EField(_, "FlxG")):
                        return macro {
                            if (TransitionState.currenttransition != null) {
                                trace("Transitioning right now... Can't cut states.");
                            } else {
                                $e(args);
                            }
                        };
                    default:
                        return expr;
                }
            default:
                return expr;
        }
    }
}
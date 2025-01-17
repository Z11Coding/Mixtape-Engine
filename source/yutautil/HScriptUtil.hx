package yutautil;

#if hscript
import hscript.Parser;
import hscript.Interp;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class HScriptUtil {
    public static macro function functionToString(func:Expr):Expr {
        var funcStr = Context.toString(func);
        return macro $v{funcStr};
    }

    public static function runFunctionFromString(funcStr:String, context:Dynamic):Dynamic {
        var parser = new Parser();
        var interp = new Interp();
        interp.variables.set("context", context);

        // Convert the expression string into a format that HScript can read
        var hscriptExprStr = convertToHScriptExpr(funcStr);
        var expr = parser.parseString(hscriptExprStr);
        return interp.execute(expr);
    }

    private static function convertToHScriptExpr(exprStr:String):String {
        // Replace Haxe macro expression parts with HScript-compatible parts
        exprStr = exprStr.replace("haxe.macro.Expr.ExprDef.EFunction", "function");
        exprStr = exprStr.replace("haxe.macro.Expr.FunctionKind.FAnonymous", "");
        exprStr = exprStr.replace("haxe.macro.Expr.ExprDef.EBlock", "{");
        exprStr = exprStr.replace("haxe.macro.Expr.ExprDef.EReturn", "return");
        exprStr = exprStr.replace("haxe.macro.Expr.ExprDef.EConst", "");
        exprStr = exprStr.replace("haxe.macro.Expr.Constant.CString", "");
        exprStr = exprStr.replace("haxe.macro.Expr.StringLiteralKind.DoubleQuotes", "");
        exprStr = exprStr.replace("ret : null, params : [], expr :", "");
        exprStr = exprStr.replace("args : []", "");
        exprStr = exprStr.replace("expr :", "");
        exprStr = exprStr.replace("(", "");
        exprStr = exprStr.replace(")", "");
        exprStr = exprStr.replace("[", "");
        exprStr = exprStr.replace("]", "");
        exprStr = exprStr.replace(",", "");
        exprStr = exprStr.replace(":", "");
        exprStr = exprStr.replace(";", "");
        exprStr = exprStr.trim();
        return exprStr;
    }
}
#end

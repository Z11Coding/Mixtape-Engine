package backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Printer;

class Threader {
    public static macro function runInThread(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
        var sleepExpr = Context.makeExpr(sleepDuration, Context.currentPos());
        var nameExpr = Context.makeExpr(name, Context.currentPos());
        trace("Preparing a threaded section of code:" + expr + " with sleep duration: " + sleepDuration + " and name: " + name);
        return macro {
            #if sys
            var thrd = Thread.create(function() {
                try {
                    trace("Set command to run in a thread...");
                    if ($nameExpr != "") {
                        trace("Thread name: " + $nameExpr);
                    }
                    $expr;
                    if ($sleepExpr > 0) {
                        Sys.sleep($sleepExpr);
                    }
                    trace("Thread finished running command: " + $nameExpr);
                    // trace($expr);
                } catch (e:Dynamic) {
                    trace("Exception in thread: " + e + " ... " + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
                    if ($nameExpr != "") {
                        trace("Errored Thread name: " + $nameExpr);
                    }
                }
            });
            #else
            $expr;
            #end
        };
        trace("Threaded section of code prepared.");
    }

    // public static macro function addLogging(expr:Expr):Expr {
    //     return switch (expr.expr) {
    //         case EFunction(args, body):
    //             var newExprs = [];
    //             newExprs.push(macro trace("Starting function..."));
    //             for (e in body.exprs) {
    //                 newExprs.push(addLogging(e));
    //             }
    //             newExprs.push(macro trace("Function execution completed."));
    //             body.exprs = newExprs;
    //             return macro $expr;
    //         case EIf(cond, e1, e2):
    //             return macro {
    //                 trace("Evaluating condition: " + $cond.toString());
    //                 if ($cond) {
    //                     trace("Condition true");
    //                     $addLogging(e1);
    //                 } else {
    //                     trace("Condition false");
    //                     $addLogging(e2);
    //                 }
    //             };
    //         default:
    //             return expr;
    //     }
    // }
}

class ThreadQueue {
    private var queue:Array<() -> Void>;
    private var maxConcurrent:Int;
    private var running:Int;
    private var blockUntilFinished:Bool;

    public function new(maxConcurrent:Int = 1, blockUntilFinished:Bool = false) {
        this.queue = [];
        this.maxConcurrent = maxConcurrent;
        this.running = 0;
        this.blockUntilFinished = blockUntilFinished;
    }

    public static function doInQueue(func:() -> Void, maxConcurrent:Int = 1, blockUntilFinished:Bool = false):ThreadQueue {
        var tq = new ThreadQueue(maxConcurrent, blockUntilFinished);
        tq.addFunction(func);
        return tq;
    }

    public static function tempQueue(funcs:Array<() -> Void>, maxConcurrent:Int = 1, blockUntilFinished:Bool = false):ThreadQueue {
        var tq = new ThreadQueue(maxConcurrent, blockUntilFinished);
        tq.addFunctions(funcs);
        return tq;
    }

    public static function quickQueue(funcs:Array<() -> Void>, maxConcurrent:Int = 1, blockUntilFinished:Bool = false):ThreadQueue {
        var tq = new ThreadQueue(maxConcurrent, blockUntilFinished);
        tq.addFunctions(funcs);
        tq.waitUntilFinished();
        tq = null;
        return tq;
    }

    public function addFunction(func:() -> Void):Void {
        queue.push(func);
        processQueue();
    }

    public function addFunctions(funcs:Array<() -> Void>):Void {
        for (func in funcs) {
            queue.push(func);
        }
        processQueue();
    }

    private function processQueue():Void {
        while (running < maxConcurrent && queue.length > 0) {
            var func = queue.shift();
            running++;
            sys.thread.Thread.create(function() {
                func();
                running--;
                processQueue();
            });
        }

        if (blockUntilFinished && queue.length == 0 && running == 0) {
            // All functions are finished
            trace("All functions are finished.");
        }
    }

    public function waitUntilFinished():Void {
        while (queue.length > 0 || running > 0) {
            // Busy wait
        }
    }
}

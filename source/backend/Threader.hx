package backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Printer;

   typedef BakedThread = {
    expr:Expr,
    sleepDuration:Float,
    name:String
};

typedef QuietThread = String;

class Threader {

 

    public static var threadQueue:ThreadQueue;
    public static var specialThreads:Array<BakedThread> = [];
    public static var quietThreads:Array<QuietThread> = [];

    public static macro function runInQueue(expr:Expr, ?maxConcurrent:Int = 1, ?blockUntilFinished:Bool = false):Expr {
        return macro {
            var tq = ThreadQueue.doInQueue(function() {
                $expr;
            }, $v{Context.makeExpr(maxConcurrent, Context.currentPos())}, $v{Context.makeExpr(blockUntilFinished, Context.currentPos())});
        };
    }
    public static macro function runInThread(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
        var sleepExpr = Context.makeExpr(sleepDuration, Context.currentPos());
        var nameExpr = Context.makeExpr(name != "" && name != null ? name : "Thread_" + Std.random(1000000) + "_" + (stringRandomizer(8)), Context.currentPos());
        var generatedName:String = ExprTools.toString(nameExpr);
        trace("Preparing a threaded section of code:" + expr + " with sleep duration: " + sleepDuration + " and name: " + generatedName);
        var threadExpr = macro {
            #if sys
            // backend.Threader.ThreadChecker.checkForWaitForThreads($expr, $nameExpr);
            backend.Threader.quietThreads.push($nameExpr);
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
                backend.Threader.quietThreads.remove($nameExpr);
            } catch (e:Dynamic) {
                trace("Exception in thread: " + e + " ... " + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
                if ($nameExpr != "") {
                trace("Errored Thread name: " + $nameExpr);
                }
                backend.Threader.quietThreads.remove($nameExpr);
            }
            }
            );
            #else
            $expr;
            #end
        };
        return macro backend.Threader.ThreadChecker.safeThread($threadExpr, $nameExpr);
        trace("Threaded section of code prepared.");
    }

    // public static macro function runThreaded(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
    //     return runInThread(expr, sleepDuration, name);
    // }

    private static function stringRandomizer(length:Int):String {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var str = "";
        for (i in 0...length) {
            str += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return str;
    }

    // public static function runSpecialThreads():Void {
    //     for (thread in specialThreads) {
    //         trace("Running special thread: " + thread.name);
    //         runInThread(thread.expr, thread.sleepDuration, thread.name);
    //     }
    // }

    public static function waitForThreads():Void { // Never use this. It will cause a deadlock.
        while (quietThreads.length > 0) {
            // Busy wait
        }
    }

    public static function waitForThread(name:String):Void {
        if (quietThreads.indexOf(name) == -1) {
            trace("Thread " + name + " does not exist.");
            return;
        }
        trace("Waiting for thread: " + name);
        while (quietThreads.indexOf(name) != -1) {
            // Busy wait
        }
        trace("Freedom! Thread " + name + " has finished, or ceased to exist.");
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

        while (blockUntilFinished && queue.length == 0 && running == 0) {
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

class ThreadChecker {
    public static macro function safeThread(expr:Expr, ?thread:QuietThread):Expr {
        var hasWaitForThreads = containsWaitForThreads(expr);
        if (hasWaitForThreads) {
            Context.error("You can't create an infinite waiting thread." + (thread != null ? " (" + thread + ")" : ""), expr.pos);
        }
        return expr;
    }

    private static function containsWaitForThreads(expr:Expr):Bool {
        switch (expr.expr) {
            case ECall(e, _):
                switch (e.expr) {
                    case EField(_, "waitForThreads"):
                        return true;
                    default:
                        return false;
                }
            case EBlock(exprs):
                for (e in exprs) {
                    if (containsWaitForThreads(e)) {
                        return true;
                    }
                }
                return false;
            default:
                return false;
        }
    }
}

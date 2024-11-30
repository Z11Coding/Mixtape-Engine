package backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Printer;
import sys.thread.Thread;

class Threader {
    private static var threadCounter:Int = 0;
    private static var threads:Map<String, Thread> = new Map();
    //WIP

    public static macro function runInThread(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
        var sleepExpr = Context.makeExpr(sleepDuration, Context.currentPos());
        var nameExpr = Context.makeExpr(name, Context.currentPos());
        trace("Preparing a threaded section of code:" + expr + " with sleep duration: " + sleepDuration + " and name: " + name);
        return macro {
            #if sys
            var thrdName = $nameExpr != "" ? $nameExpr : "Thread_" + (Threader.threadCounter++);
            var thrd = Thread.create(function() {
                try {
                    trace("Set command to run in a thread...");
                    if (thrdName != "") {
                        trace("Thread name: " + thrdName);
                    }
                    $expr;
                    if ($sleepExpr > 0) {
                        Sys.sleep($sleepExpr);
                    }
                    trace("Thread finished running command.");
                } catch (e:Dynamic) {
                    trace("Exception in thread: " + e);
                    if (thrdName != "") {
                        trace("Errored Thread name: " + thrdName);
                    }
                }
            });
            Threader.registerThread(thrdName, thrd);
            #else
            $expr;
            #end
        };
        trace("Threaded section of code prepared.");
    }

    private static function registerThread(name:String, thread:Thread):Void {
        trace("Thread registered: " + name + " in Threader at " + Context.currentPos());
        threads.set(name, thread);
    }

    // public static function stopAllThreads():Void {
    //     for (name in threads.keys()) {
    //         threads.get(name).kill();
    //         threads.remove(name);
    //         trace("Thread " + name + " stopped.");
    //     }
    // }

    // public static function stopThread(name:String):Void {
    //     if (threads.exists(name)) {
    //         threads.get(name).kill();
    //         threads.remove(name);
    //         trace("Thread " + name + " stopped.");
    //     } else {
    //         trace("Thread " + name + " not found.");
    //     }
    // }

    // public static function listThreads():Array<String> {
    //     return threads.keys();
    // }

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
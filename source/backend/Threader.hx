package backend;

import haxe.Exception;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Printer;

/**
 * Represents a thread baked into compilation.
 */
typedef BakedThread = {
    expr:Expr,
    sleepDuration:Float,
    name:String
};

/**
 * Represents a thread that is running in the background.
 */
typedef QuietThread = String;

/**
 * Manages threading operations, including running expressions in threads and queues.
 * 
 * Used for threading function calls for performance, and for running multiple functions concurrently.
 * Will NOT work with regular expressions.
 */
class Threader {
    public static var threadQueue:ThreadQueue;
    public static var specialThreads:Array<BakedThread> = [];
    public static var quietThreads:Array<QuietThread> = [];
    private static var baked:BakedThread;
    private static var usedthreads:Bool = false;
    private static var generatedThreads:Array<QuietThread> = [];
    private static var bakedThreads:Array<BakedThread> = [];

    /**
     * Runs an expression in a queue with specified concurrency and blocking behavior.
     * @param expr The expression to run.
     * @param maxConcurrent The maximum number of concurrent threads.
     * @param blockUntilFinished Whether to block until all threads are finished.
     * @return The macro expression to run the queue.
     */
    public static macro function runInQueue(expr:Expr, ?maxConcurrent:Int = 1, ?blockUntilFinished:Bool = false):Expr {
        return macro {
            var tq = ThreadQueue.doInQueue(function() {
                $expr;
            }, $v{Context.makeExpr(maxConcurrent, Context.currentPos())}, $v{Context.makeExpr(blockUntilFinished, Context.currentPos())});
        };
    }

    /**
     * Runs multiple expressions in a queue with specified concurrency and blocking behavior.
     * @param exprs The expressions to run.
     * @param maxConcurrent The maximum number of concurrent threads.
     * @param blockUntilFinished Whether to block until all threads are finished.
     * @return The macro expression to run the queue.
     */
    public static macro function runQueue(exprs:Array<Expr>, ?maxConcurrent:Int = 1, ?blockUntilFinished:Bool = false):Expr {
        return macro {
            var tq = ThreadQueue.tempQueue([
                for (e in $a{exprs}) {
                    function() {
                        e;
                    }
                }
            ], $v{Context.makeExpr(maxConcurrent, Context.currentPos())}, $v{Context.makeExpr(blockUntilFinished, Context.currentPos())});
        };
    }

    /**
     * Runs an expression in a thread with optional sleep duration and name.
     * @param expr The expression to run.
     * @param sleepDuration The sleep duration after running the expression.
     * @param name The name of the thread.
     * @return The macro expression to run the thread.
     */
    public static macro function runInThread(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
        if (!usedthreads) {
            trace("Initializing Threader...");
            Context.onAfterGenerate(function() {
            trace("All threads are generated: " + generatedThreads);
            // remove threads from array that have finished
            for (thread in generatedThreads) {
                if (generatedThreads.indexOf(thread) == -1) {
                quietThreads.remove(thread);
                trace("Finished generation of " + thread);
                }
            }
            });
            baked = { expr: expr, sleepDuration: sleepDuration, name: name };
            bakedThreads.push(baked);
        }
        usedthreads = !usedthreads ? true : usedthreads;
        var sleepExpr = Context.makeExpr(sleepDuration, Context.currentPos());
        var nameExpr = Context.makeExpr(name != "" && name != null ? name : "Thread_" + Std.random(1000000) + "_" + (stringRandomizer(8)), Context.currentPos());
        var generatedName:String = ExprTools.toString(nameExpr);
        generatedThreads.push(generatedName);
        trace("Preparing a threaded section of code:" + expr + " with sleep duration: " + sleepDuration + " and name: " + generatedName);
        var threadExpr = macro {
            #if sys
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
                    backend.Threader.quietThreads.remove($nameExpr);
                } catch (e:Dynamic) {
                    trace("Exception in thread: " + e + " ... " + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
                    if ($nameExpr != "") {
                        trace("Errored Thread name: " + $nameExpr);
                    }
                    backend.Threader.quietThreads.remove($nameExpr);
                }
            });
            #else
            $expr;
            #end
        };
        return macro backend.Threader.ThreadChecker.safeThread($threadExpr, $nameExpr);
        trace("Threaded section of code prepared.");
    }

    /**
     * Generates a random string of the specified length.
     * @param length The length of the string.
     * @return The generated random string.
     */
    private static function stringRandomizer(length:Int):String {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var str = "";
        for (i in 0...length) {
            str += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return str;
    }

    /**
     * Waits for all quiet threads to finish. This may cause permanent blocking if a thread is stuck, or is meant to run indefinitely.
     * 
     * This function is not recommended for production use, as it may cause permanent blocking.
     * 
     * This function is intended for debugging purposes only.
     * 
     * Use with caution.
     * Will cause a compiler error if used as a threaded expression.
     * @see waitForThread
     * 
     */
    public static function waitForThreads():Void {
        while (quietThreads.length > 0) {
            // Busy wait
        }
    }

    /**
     * Waits for a specific thread to finish.
     * 
     * You cannot wait for unnamed threads. If you need to wait for an unnamed thread, you should name it.
     * @param name The name of the thread.
     */
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
}

/**
 * Manages a queue of functions to be executed in threads.
 */
class ThreadQueue {
    private var queue:Array<() -> Void>;
    private var maxConcurrent:Int;
    private var running:Int;
    private var blockUntilFinished:Bool;
    private var done:Bool = true;

    /**
     * Creates a new ThreadQueue.
     * @param maxConcurrent The maximum number of concurrent threads.
     * @param blockUntilFinished Whether to block until all threads are finished.
     */
    public function new(maxConcurrent:Int = 1, blockUntilFinished:Bool = false) {
        this.queue = [];
        this.maxConcurrent = maxConcurrent;
        this.running = 0;
        this.blockUntilFinished = blockUntilFinished;
    }
    
    /**
     * Runs the queue, if there is anything to run. Only should be used if you preloaded functions while it wasn't already running.
     * 
     * This function checks if the queue is already running or if there are no threads available to run.
     * If the queue is already running, it logs a message and returns without doing anything.
     * If there are no threads available, it logs a message and throws an exception.
     * Otherwise, it proceeds to process the queue.
     * 
     * @throws NoThread if there are no threads available to run.
     */
    public function run():Void {
        if (!done) {
            trace("Attempted a thread queue run while already running a queue in " + this);
            return;
        }
        if (queue.length == 0) {
            trace("Attempted a thread queue run with no threads available.");
            throw new Exception("Attempted a thread queue run with no threads available.");
        }
        processQueue();
    }

    /**
     * Returns a string representation of the ThreadQueue.
     * @return The string representation.
     */
    public function toString():String {
        return "ThreadQueue: " + queue.length + " functions in queue, " + running + " functions running, maxConcurrent: " + maxConcurrent + ", blockUntilFinished: " + blockUntilFinished;
    }

    /**
     * Creates a new ThreadQueue.
     * @param maxConcurrent The maximum number of concurrent threads.
     * @param blockUntilFinished Whether to block until all threads are finished.
     * @return The created ThreadQueue.
     */
    public static function create(maxConcurrent:Int = 1, blockUntilFinished:Bool = false):ThreadQueue {
        return new ThreadQueue(maxConcurrent, blockUntilFinished);
    }

    /**
     * Adds a function to the queue.
     * @param func The function to add.
     */
    public function add(func:() -> Void):Void {
        addFunction(func);
    }

    /**
     * Adds a function to the queue and runs it immediately if possible.
     * @param func The function to add.
     */
    public function softAdd(func:() -> Void):Void {
        if (running < maxConcurrent) {
            running++;
            sys.thread.Thread.create(function() {
                func();
                running--;
                processQueue();
            });
        } else {
            queue.push(func);
        }
    }

    /**
     * Preloads multiple functions into the queue.
     * 
     * Warning: If currently running functions, these will be added to the same CURRENT queue.
     * @param funcs The functions to preload.
     */
    public function preloadMulti(funcs:Array<() -> Void>):Void {
        for (func in funcs) {
            queue.push(func);
        }
    }

    /**
     * Preloads a function into the queue.
     * 
     * Warning: If currently running functions, this will be added to the same CURRENT queue.
     * @param func The function to preload.
     */
    public function preload(func:() -> Void):Void {
        queue.push(func);
    }

    /**
     * Adds a function to the queue and processes the queue.
     * @param func The function to add.
     */
    public function addFunction(func:() -> Void):Void {
        queue.push(func);
        processQueue();
    }

    /**
     * Adds multiple functions to the queue and processes the queue.
     * @param funcs The functions to add.
     */
    public function addFunctions(funcs:Array<() -> Void>):Void {
        for (func in funcs) {
            queue.push(func);
        }
        processQueue();
    }

    /**
     * Processes the queue, running functions in threads.
     */
    private function processQueue():Void {
        if (done && queue.length > 0) {
            done = false;
            trace("Processing queue...");
        }
        while (running < maxConcurrent && queue.length > 0) {
            var func = queue.shift();
            running++;
            sys.thread.Thread.create(function() {
                func();
                running--;
                processQueue();
            });
        }

        while (blockUntilFinished && queue.length == 0 && running == 0 && !done) {
            // All functions are finished
            trace("All functions are finished.");
            done = true;
        }
        if (queue.length == 0 && running == 0) {
            trace("Queue is empty.");
            done = true;
        }
    }

    /**
     * Waits until all functions in the queue are finished.
     */
    public function waitUntilFinished():Void {
        while (queue.length > 0 || running > 0 || !done) {
            // Busy wait
        }
    }
}

/**
 * Checks for safe threading operations.
 */
class ThreadChecker {
    /**
     * Ensures that a thread does not contain an infinite waiting loop.
     * @param expr The expression to check.
     * @param thread The name of the thread.
     * @return The checked expression.
     */
    public static macro function safeThread(expr:Expr, ?thread:QuietThread):Expr {
        var hasWaitForThreads = containsWaitForThreads(expr);
        if (hasWaitForThreads) {
            Context.error("You can't create an infinite waiting thread." + (thread != null ? " (" + thread + ")" : ""), expr.pos);
        }
        return expr;
    }

    /**
     * Checks if an expression contains a call to waitForThreads.
     * @param expr The expression to check.
     * @return Whether the expression contains a call to waitForThreads.
     */
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
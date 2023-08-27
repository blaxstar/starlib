package net.blaxstar.debug.benchmark {
  public class BenchmarkUtil {

    static private var timers:Vector.<Timer> = new Vector.<Timer>();
    static private var functions:Vector.<Function> = new Vector.<Function>();
    static private var parameters:Vector.<Array> = new Vector.<Array>();

    static public function timedFunction(func:Function, params:Array, delay:uint=2000):void {
        if (func == null) {
            return;
        }
        if (delay <= 0) {
            func.apply(null, params);
            return;
        }

        timers.push(new Timer(delay, 1));
        timers[timers.length - 1].addEventListener(TimerEvent.TIMER, BenchmarkUtil.onTimer);
        functions.push(func);
        parameters.push(params);
        timers[timers.length - 1].start();
    }

    static private function onTimer(e:TimerEvent):void {
        for (var i:uint = 0; i < timers.length; i++) {
            if (timers[i] === e.target) {
                timers[i].removeEventListener(TimerEvent.TIMER, onTimer);
                functions[i].apply(null, parameters[i]);
                timers.splice(i, 1);
                functions.splice(i, 1);
                parameters.splice(i, 1);
                return;
            }
        }
    }
  }
}

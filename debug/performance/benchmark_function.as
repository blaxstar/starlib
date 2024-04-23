package net.blaxstar.starlib.debug.performance
{
  import flash.utils.Timer;
  import flash.events.TimerEvent;

  public function benchmark_function(target_function:Function, function_params:Array, timer_interval:uint=2000):void {
    var timers:Vector.<Timer> = new Vector.<Timer>();
    var functions:Vector.<Function> = new Vector.<Function>();
    var parameters:Vector.<Array> = new Vector.<Array>();
    var on_timer:Function = function (e:TimerEvent):void {
        for (var i:uint = 0; i < timers.length; i++) {
            if (timers[i] === e.target) {
                timers[i].removeEventListener(TimerEvent.TIMER, on_timer);
                functions[i].apply(null, parameters[i]);
                timers.splice(i, 1);
                functions.splice(i, 1);
                parameters.splice(i, 1);
                return;
            }
        }
    };

    if (target_function == null) {
            return;
        }
        if (timer_interval <= 0) {
            target_function.apply(null, function_params);
            return;
        }

        timers.push(new Timer(timer_interval, 1));
        timers[timers.length - 1].addEventListener(TimerEvent.TIMER, on_timer);
        functions.push(target_function);
        parameters.push(function_params);
        timers[timers.length - 1].start();
  }
}
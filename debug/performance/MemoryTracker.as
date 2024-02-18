package net.blaxstar.starlib.debug.performance {

    import flash.events.Event;
    import flash.utils.getTimer;
    import flash.system.System;
    import flash.utils.Dictionary;
    import flash.display.Sprite;

    public class MemoryTracker {
        // megabyte constant to convert from bytes to megabytes.
        private static const _MEGABYTE:int = 1024 * 1024;
        // used to calculate the real frame rate.
        private static var _start_time:int = getTimer();
        // used to generate trace output intermittently.
        private static var _update_interval:int = 0;
        // used to allow direct access to the stage so we can monitor framerate.
        private static var _main:Sprite;
        // used to store weak references to objects that you want to track.
        private static var _tracker_lookup:Dictionary = new Dictionary(true);
        // used to trigger a report on the tracked objects.
        private static var _can_report:Boolean;
        // used to (help) ensure gc takes place.
        private static var _gc_call_count:int;
        // this is the variable that will store the update_frequency value that you pass.
        private static var _update_frequency:int;
        // the current framerate of the application, in number of frames per second.
        private static var _current_fps:int;
        // the current memory used by the application, in megabytes (MB).
        private static var _current_memory:int;

        /**
         * a static class that reports framerate and memory consumption, as well as lists any objects that are still in memory.
         */
        public function MemoryTracker() {
        }

        /**
         * the listener function for the ENTER_FRAME event used by _main. if
         * the game is running at its maximum frame rate (== stage.frameRate),
         * this function will be called stage.frameRate times per second.
         * @param e event -- this function is a delegate.
         */
        private static function print_fps_and_memory(e:Event):void {
            _update_interval++;
            // This conditional ensures update occurs no more frequently than every `_update_frequency` seconds
            if (_update_interval % (_update_frequency * _main.stage.frameRate) == 0) {
                // this is used to (try and) force gc. 
                _gc_call_count = 0;
                force_gc();
                _current_fps = int(_update_interval * 1000 / (getTimer() - _start_time));
                _current_memory = int(100 * System.totalMemory / _MEGABYTE) / 100;
                _update_interval = 0;
                _start_time = getTimer();
            }
        }

        /**
         * called just prior to printing the memory report, which ensures
         * _can_report is set to `true`.
         */
        private static function force_gc():void {
            // the first call to System.gc() marks items that are available for collection. the second should sweep them, but the third is for good luck because you can't count on anything being predictably collected.
            _main.addEventListener(Event.ENTER_FRAME, on_gc_timer, false, 0, true);
            _gc_call_count = 0;
        }

        private static function on_gc_timer(e:Event):void {
            System.gc();
            _gc_call_count++;
            // 3 System.gc() statements is enough.
            if (_gc_call_count > 2) {
                _main.removeEventListener(Event.ENTER_FRAME, on_gc_timer, false);
                // here, `_can_report` being true triggers the memory report.
                if (_can_report) {
                    _can_report = false;
                    print_memory_report();
                }
            }
        }

        /**
         * prints a memory report to std out.
         */
        private static function print_memory_report():void {
            trace("** MEMORY REPORT AT:", int(getTimer() / 1000));
            for (var obj:* in _tracker_lookup) {
                trace(obj, "exists", _tracker_lookup[obj]);
            }
        }

        /**
         * initializes the memory tracker on the given main class, and gives updates on fps and memory according to `update_frequency` (seconds). anything <=0 will result in no updates.
         * @param main the main class.
         * @param update_frequency
         */
        public static function init(main:Sprite, update_frequency:int = 0):void {
            _main = main;
            _update_frequency = update_frequency;

            if (_update_frequency > 0) {
                _main.addEventListener(Event.ENTER_FRAME, print_fps_and_memory, false, 0, true);
            }
        }

        // this the function you use to pass objects to be tracked.
        public static function track(obj:*, detail:* = null):void {
            _tracker_lookup[obj] = detail;
        }

        /**
         * generates a memory report to be printed to std out.
         */
        public static function generate_report():void {
            _can_report = true;
            force_gc();
        }
    }
}

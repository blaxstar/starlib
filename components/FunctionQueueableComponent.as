package net.blaxstar.starlib.components {
    import net.blaxstar.starlib.components.interfaces.IFunctionQueueable;
    import flash.events.Event;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Dictionary;

    public class FunctionQueueableComponent extends Component implements IFunctionQueueable {

        static private var _component_function_queue_map:Dictionary;
        private var _function_queue:Vector.<Function>;
        private var _param_queue:Vector.<Array>;

        public function FunctionQueueableComponent(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
            super(parent, xpos, ypos);
        }

        override public function init():void {
            _component_function_queue_map = new Dictionary();
            super.init();
        }

        /**
         * queues a function for later execution.
         * @param func  function to be queued.
         * @param ...rest an array of parameters required by the function.
         */
        public function queue_function(func:Function, ... rest):void {
            // we'll set up a map matrix of sorts to keep track of queued functions. this is ensure functions dont get queued multiple times, and queues are sandboxed to their respective components.
            if (!_component_function_queue_map.hasOwnProperty(this.id)) {
                _component_function_queue_map[this.id] = new Dictionary();
            }

            var component_map:Dictionary = _component_function_queue_map[this.id];
            // if the function is not registered in the map, then register it
            if (!component_map.hasOwnProperty(func)) {
                component_map[func] = 1;
            } else {
              // otherwise return and don't add it again
                return;
            }
            // add the function to the queue
            _function_queue.push(func);
            // if there are no args just push an empty array
            if (!rest || !rest.length) {
                _param_queue.push([]);
            } else {
              // otherwise push the args
                _param_queue.push(rest);
            }
        }

        /**
         * checks if there are any queued functions available, and attempts to execute them.
         * @param event the event parameter, typically an ENTER_FRAME event.
         */
        public function check_queue(event:Event):void {
            if (!_function_queue.length || !_param_queue.length)
                return;
            for (var i:uint = 0; i < _function_queue.length; i++) {
                _function_queue[i].call(this, _param_queue[i]);
                delete _component_function_queue_map[this.id][_function_queue[i]];
                _function_queue.splice(i, 1);
                _param_queue[i].splice(i, 1);
            }
        }
    }
}

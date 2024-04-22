package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;

    import net.blaxstar.starlib.math.Arithmetic;

    import thirdparty.org.osflash.signals.Signal;
    import thirdparty.org.osflash.signals.natives.NativeSignal;

    /**
     * Base Component Class.
     * @author Deron D. (decamp.deron@gmail.com)
     */
    public class Component extends Sprite implements IComponent {

        static protected var _resizeEvent_:Event;

        static public const DRAW:String = "draw";
        static public const PADDING:uint = 10;

        static public var totalComponents:uint;
        static public var lscmp:Vector.<Component>;

        private var _function_queue:Vector.<Function>;
        private var _param_queue:Vector.<Array>;
        private var _dropshadow_filter:DropShadowFilter;
        private var _id_:uint;
        private var _enabled_:Boolean;
        private var _is_showing_bounds_:Boolean;

        protected var _width_:Number;
        protected var _height_:Number;
        public var on_enter_frame_signal:NativeSignal;
        public var on_resize_signal:NativeSignal;
        public var on_draw_signal:Signal;
        public var on_added_signal:NativeSignal;

        /**
         * creates a base Component.
         * @param parent  displayobject container to add the component to.
         * @param xpos  x position of the new component.
         * @param ypos  y position of the new component.
         */
        public function Component(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
            super();
            // component tracking
            if (lscmp == null) {
                lscmp = new Vector.<Component>();
                totalComponents = 0;
            }
            lscmp.push(this);
            _id_ = totalComponents++;
            // components are enabled by default.
            _enabled_ = true;
            // move the component's anchor to the correct position...
            move(xpos, ypos);
            // initialize the component...
            init();
            // then add it to parent if parent isn't null.
            if (parent != null) {
                parent.addChild(this);
            }
        }

        /** INTERFACE net.blaxstar.starlib.components.IComponent ===================== */

        /**
         * initializes the component by adding all the children and committing the visual changes to be written on the next frame. created to be overridden.
         */
        public function init():void {
            _function_queue = new Vector.<Function>();
            _param_queue = new Vector.<Array>();
            _dropshadow_filter = new DropShadowFilter(4, 90, 0, 0.3, 7, 7, .6);

            if (!on_enter_frame_signal) {
                on_enter_frame_signal = new NativeSignal(this, Event.ENTER_FRAME, Event);
            }
            if (!on_added_signal) {
                on_added_signal = new NativeSignal(this, Event.ADDED, Event);
            }
            if (!on_resize_signal) {
                _resizeEvent_ = new Event(Event.RESIZE);
                on_resize_signal = new NativeSignal(this, Event.RESIZE, Event);
            }
            if (!on_draw_signal) {
                on_draw_signal = new Signal();
            }

            add_children();
            on_added_signal.addOnce(on_added);
            //on_enter_frame_signal.add(check_queue);
            // TODO: update theme on all components when theme is changed.
            // Style.ON_THEME_UPDATE.add(draw);
        }

        protected function on_added(e:Event):void {

        }

        /**
         * queues a function for later execution.
         * @param func  function to be queued.
         * @param ...rest an array of parameters required by the function.
         */
        protected function queue_function(func:Function, ... rest):void {
            _function_queue.push(func);
            if (!rest || !rest.length) {
                _param_queue.push([]);
            } else {
                _param_queue.push(rest);
            }
        }

        /**
         * checks if there are any queued functions available, and attempts to execute them.
         * @param e event param, typically an ENTER_FRAME event.
         */
        protected function check_queue(e:Event):void {
            if (!_function_queue.length || !_param_queue.length)
                return;
            for (var i:uint = 0; i < _function_queue.length; i++) {
                _function_queue[i].call(this, _param_queue[i]);
                _function_queue.splice(i, 1);
                _param_queue[i].splice(i, 1);
            }
        }

        /**
         * base method for initializing and adding children of the component. created to be overridden.
         */
        public function add_children():void {
            // trace('on added triggered from ' + this.toString());
            draw();
        }

        /**
         * base method for (re)drawing the component itself. created to be overridden.
         */
        public function draw(e:Event = null):void {
            // dispatches a DRAW event
            on_enter_frame_signal.remove(draw);
            update_skin();
            if (is_showing_bounds) {
                updateBounds();
            }
        /**
         * * some components will need to dispatch resize as the components use custom _width_ and _height_ properties. if used in a container, these components width & height properties will report back erroneously if the custom width & height values are not updated. i can dispatch events, but i'm looking for a way to cut costs on that.
         * TODO: maybe convert all resize dispatches to native signals, and make override dispatch event. gotta test if nativesignal is faster or not...
         */
        }

        /** END INTERFACE ===================== */

        public function update_skin():void {

        }

        /**
         * marks the component for redraw on the next frame.
         * this minimizes the processing load per frame, improving performance.
         */
        public function commit():void {
            on_enter_frame_signal.addOnce(draw);
        }

        /**
         * move the component to the specified x and y position. the positions will be rounded to the nearest integer.
         * @param    xpos    new x position of the component.
         * @param    ypos    new y position of the component.
         */
        public function move(x_position:Number, y_position:Number):void {
            x = Arithmetic.round(x_position);
            y = Arithmetic.round(y_position);
        }

        /**
         * set the width and height of the component, marking it for a redraw on the next frame.
         * @param    w    new width of the component.
         * @param    h    new height of the component.
         */
        public function set_size(width:Number, height:Number):void {
            _width_ = width;
            _height_ = height;

            draw();
            on_resize_signal.dispatch(_resizeEvent_);
        }

        /**
         * apply a pre-created dropshadow filter effect on the component.
         */
        public function apply_shadow():void {
            filters = [_dropshadow_filter];
        }

        /**
         * initialize the stage for proper alignment and scaling of objects.
         * @param    stage the stage of the current window.
         */
        public static function initStage(stage:Stage):void {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
        }

        override public function get width():Number {
            return _width_;
        }

        override public function set width(value:Number):void {
            _width_ = value;
            commit();
            on_resize_signal.dispatch(_resizeEvent_);
        }

        override public function get height():Number {
            return _height_;
        }

        override public function set height(value:Number):void {
            _height_ = value;
            commit();
            on_resize_signal.dispatch(_resizeEvent_);
        }

        override public function set x(value:Number):void {
            super.x = int(value);
        }

        override public function set y(value:Number):void {
            super.y = int(value);
        }

        public function get padding():uint {
            return PADDING;
        }

        public function get id():uint {
            return _id_;
        }

        public function get is_showing_bounds():Boolean {
            return _is_showing_bounds_;
        }

        public function set is_showing_bounds(value:Boolean):void {
            var g:Graphics = this.graphics;

            if (value == true && _width_ > 0 && _height_ > 0) {
                if (_is_showing_bounds_) {
                    return;
                } else {
                    g.lineStyle(1, 0xFF0000, 0.8, true);
                    g.drawRect(0, 0, _width_, _height_);
                    _is_showing_bounds_ = true;
                    on_draw_signal.add(updateBounds);
                    on_resize_signal.add(updateBounds);
                }
            } else if (value == false) {
                if (!_is_showing_bounds_)
                    return;
                else {
                    g.clear();
                    _is_showing_bounds_ = false;
                }
            }
        }

        protected function updateBounds(e:Event = null):void {
            graphics.clear();
            _is_showing_bounds_ = false;
            is_showing_bounds = true;
        }

        public function set enabled(val:Boolean):void {
            _enabled_ = mouseEnabled = mouseChildren = tabEnabled = tabChildren = val;

            alpha = _enabled_ ? 1.0 : 0.5;
        }

        public function get enabled():Boolean {
            return _enabled_;
        }

        public function destroy():void {

        }

    }

}

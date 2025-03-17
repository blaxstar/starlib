package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;

    import net.blaxstar.starlib.components.interfaces.IComponent;
    import net.blaxstar.starlib.math.Arithmetic;
    import net.blaxstar.starlib.style.Style;

    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;
    import net.blaxstar.starlib.structs.LinkedList;
    import net.blaxstar.starlib.structs.LinkedListNode;

    /**
     * Generic Component Class.
     * @author Deron D. (decamp.deron@gmail.com)
     */
    public class Component extends Sprite implements IComponent {
        // static public const
        static public const DRAW:String = "draw";
        static public const PADDING:uint = 10;
        // static public var
        static public var component_list:LinkedList;
        // static protected
        static protected var _resize_event_:Event;
        // protected
        protected var _width_:Number;
        protected var _height_:Number;
        // private
        private var _id_:uint;
        private var _enabled_:Boolean;
        private var _is_showing_bounds_:Boolean;
        private var _dropshadow_filter:DropShadowFilter;
        private var _barebones:Boolean;
        // public
        public var on_enter_frame_signal:NativeSignal;
        public var on_resize_signal:NativeSignal;
        public var on_draw_signal:Signal;
        public var on_added_signal:NativeSignal;

        /**
         * creates a simple, empty Component.
         * @param parent  displayobject container to add the component to.
         * @param xpos  x position of the new component.
         * @param ypos  y position of the new component.
         */
        public function Component(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, barebones:Boolean = false) {
            super();
            // component tracking
            if (component_list == null) {
                component_list = new LinkedList();
            }
            _id_ = component_list.size;
            component_list.append(new LinkedListNode(this));
            // components are enabled by default.
            _enabled_ = true;
            // move the component's anchor to the correct position...
            move(xpos, ypos);
            // initialize the component...
            init();
            // enable barebones mode if true...
            _barebones = barebones;
            // then add it to parent if parent isn't null.
            if (parent != null) {
                parent.addChild(this);
            }
        }

        /**
         * initializes the component by adding all the children and committing the visual changes to be written on the next frame. created to be overridden.
         */
        public function init():void {
            if (!_barebones) {
                _dropshadow_filter = new DropShadowFilter(4, 90, 0, 0.3, 7, 7, .6);

                if (!on_enter_frame_signal) {
                    on_enter_frame_signal = new NativeSignal(this, Event.ENTER_FRAME, Event);
                }
                if (!on_added_signal) {
                    on_added_signal = new NativeSignal(this, Event.ADDED, Event);
                }
                if (!on_resize_signal) {
                    _resize_event_ = new Event(Event.RESIZE);
                    on_resize_signal = new NativeSignal(this, Event.RESIZE, Event);
                }
                if (!on_draw_signal) {
                    on_draw_signal = new Signal();
                }
                on_added_signal.addOnce(on_added);
            }

            add_children();
            // TODO: update theme on all components when global theme is changed.
            Style.ON_THEME_UPDATE.add(on_theme_update);
        }

        protected function on_theme_update():void {
            commit();
        }

        /**
         * base method for initializing and adding children of the component. created to be overridden.
         */
        public function add_children():void {
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
                update_bounds();
            }
            dispatchEvent(_resize_event_);
        }

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
            on_resize_signal.dispatch(_resize_event_);
        }

        /**
         * apply a pre-created dropshadow filter effect on the component.
         */
        public function apply_shadow():void {
            filters = [_dropshadow_filter];
        }

        // ! GETTERS & SETTERS ! //

        override public function get width():Number {
            return _width_;
        }

        override public function set width(value:Number):void {
            _width_ = value;
            commit();
            dispatchEvent(_resize_event_);
        }

        override public function get height():Number {
            return _height_;
        }

        override public function set height(value:Number):void {
            _height_ = value;
            commit();
            dispatchEvent(_resize_event_);
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

            if (_is_showing_bounds_) {
                if (!value) {
                    g.clear();
                    _is_showing_bounds_ = false;
                }
            } else {
                if (value && _width_ > 0 && _height_ > 0) {
                    g.lineStyle(1, 0xFF0000, 0.8, true);
                    g.drawRect(0, 0, _width_, _height_);
                    _is_showing_bounds_ = true;
                    on_draw_signal.add(update_bounds);
                    on_resize_signal.add(update_bounds);
                }
            }
        }

        public function set enabled(val:Boolean):void {
            _enabled_ = mouseEnabled = mouseChildren = tabEnabled = tabChildren = val;

            alpha = _enabled_ ? 1.0 : 0.5;
        }

        public function get enabled():Boolean {
            return _enabled_;
        }

        // ! DELEGATE FUNCTIONS ! //

        protected function update_bounds(e:Event = null):void {
            graphics.clear();
            _is_showing_bounds_ = false;
            is_showing_bounds = true;
        }

        protected function on_added(e:Event):void {

        }

        // ! GARBAGE COLLECTION ! //

        public function destroy():void {

        }

    }

}

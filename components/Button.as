package net.blaxstar.starlib.components {

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.RGBA;
    import net.blaxstar.starlib.style.Style;

    import thirdparty.com.greensock.TweenLite;
    import thirdparty.com.greensock.plugins.TintPlugin;
    import thirdparty.com.greensock.plugins.TweenPlugin;
    import thirdparty.org.osflash.signals.natives.NativeSignal;

    /**
     * a simple button inspired by google material.
     * @author Deron D. (decamp.deron@gmail.com)
     */
    public class Button extends Component {

        // static

        static public const GROUNDED:uint = 0;
        static public const DEPRESSED:uint = 1;
        static public const DEFAULT_WIDTH:uint = 50;
        static public const DEFAULT_HEIGHT:uint = 10;

        // private
        private var _style:uint;
        private var _label:PlainText;
        private var _labelString:String;
        private var _background:Component;
        private var _background_outline:Component;
        private var _glow_color:RGBA;
        private var _icon_color:RGBA;
        private var _using_icon:Boolean;
        private var _display_icon:Icon;
        private var _data:Object;

        private var _onRollOver:NativeSignal;
        private var _onRollOut:NativeSignal;
        private var _onMouseDown:NativeSignal;
        private var _onMouseUp:NativeSignal;
        private var _onMouseClick:NativeSignal;

        public function Button(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "BUTTON") {
            _labelString = label;

            super(parent, xpos, ypos);
        }

        /** INTERFACE net.blaxstar.starlib.components.IComponent ===================== */

        /**
         * initializes the component by adding all the children
         * and committing the visual changes to be written on the next frame.
         * created to be overridden.
         */
        override public function init():void {
            _width_ = DEFAULT_WIDTH;
            _height_ = DEFAULT_HEIGHT;
            _style = 0;
            buttonMode = true;
            useHandCursor = true;

            _onRollOver = new NativeSignal(this, MouseEvent.ROLL_OVER, MouseEvent);
            _onRollOut = new NativeSignal(this, MouseEvent.ROLL_OUT, MouseEvent);
            _onMouseDown = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
            _onMouseUp = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent);
            _onMouseClick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);

            super.init();
        }

        /**
         * initializes and adds all required children of the component.
         * created to be overridden.
         */
        override public function add_children():void {
            _background = new Component(this);
            _background_outline = new Component(this);
            _label = new PlainText(this, 0, 0, _labelString);
            _background.width = _width_;
            _background.height = _height_;
            _label.format(Font.BUTTON);
            _glow_color = Style.GLOW;
            _icon_color = Style.TEXT;
            TweenPlugin.activate([TintPlugin]);
            commit();
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         * created to be overridden.
         */
        override public function draw(e:Event = null):void {
            if (!_using_icon) {
                _width_ = _label.width + (PADDING * 2);
                _height_ = _label.height + (PADDING * 2);
                _background.width = _background_outline.width = _width_;
                _background.height = _background_outline.height = _height_;
                _label.move((_width_ / 2) - (_label.width / 2), (_height_ / 2) - (_label.height / 2));
            } else {
                _background.width = _background_outline.width = _width_;
                _background.height = _background_outline.height = _height_;
            }

            draw_bg();
            dispatchEvent(new Event(Event.RESIZE));

            _onMouseDown.add(on_mouse_down);
            _onRollOver.add(on_roll_over);
            super.draw();
        }

        /** END INTERFACE ===================== */

        // public
        override public function update_skin():void {
            draw_bg();
        }

        public function add_click_listener(delegate:Function):void {
            if (!_onMouseClick)
                _onMouseClick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
            _onMouseClick.add(delegate);
        }

        // private

        private function draw_bg():void {
            _background.graphics.clear();
            _background_outline.graphics.clear();
            filters = [];

            fill_bg();
            if (_style != DEPRESSED) {
                draw_bg_outline();
            }

        }

        private function fill_bg():void {
            _background.graphics.beginFill(_glow_color.value);
            if (!_using_icon) {
                _background.graphics.drawRoundRect(0, 0, _width_, _height_, 7);
            } else {
                _background.graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
            }
            _background.graphics.endFill();
            _background.alpha = 0;

        }

        private function draw_bg_outline():void {
            _background_outline.graphics.lineStyle(1, Style.SECONDARY.value, 1, true);

            if (!_using_icon) {
                _background_outline.graphics.drawRoundRect(0, 0, _width_, _height_, 6);
            } else {
                _background_outline.graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
            }
        }

        // getters/setters

        public function set icon(val:String):void {
            _using_icon = true;
            removeChild(_label);
            _display_icon = new Icon(this);
            _display_icon.setSVGXML(val);
            _display_icon.addEventListener(Icon.ICON_LOADED, on_icon_loaded);
            _width_ = 32;
            _height_ = 32;
            _style = DEPRESSED;
            draw();
        }

        private function on_icon_loaded(event:Event):void {
            _display_icon.removeEventListener(Icon.ICON_LOADED, on_icon_loaded);
            _display_icon.move(((_width_ / 2) - (_display_icon.width / 2)), ((_height_ / 2) - (_display_icon.height / 2)));
            _display_icon.set_color(_icon_color.to_hex_string());
        }

        public function get_icon():Icon {
            return _display_icon;
        }

        public function get style():uint {
            return _style;
        }

        public function set style(val:uint):void {
            _style = val;
            commit();
        }

        public function get label():String {
            return _labelString;
        }

        public function set label(val:String):void {
            _labelString = val;
            commit();
        }

        public function set glow_color(val:RGBA):void {
            _glow_color = val;
            commit();
        }

        public function get on_click():NativeSignal {
            return _onMouseClick;
        }

        public function get data():Object {
            return _data;
        }

        public function set data(val:Object):void {
            _data = val;
        }

        // delegate functions

        private function on_mouse_down(e:MouseEvent = null):void {
            _onMouseDown.remove(on_mouse_down);
            _onMouseUp.add(on_mouse_up);
            _onRollOut.add(on_mouse_up);
            TweenLite.to(_background, 0.3, {tint: _glow_color.shade().value});
        }

        private function on_mouse_up(e:MouseEvent = null):void {
            _onMouseUp.remove(on_mouse_up);
            _onRollOut.remove(on_mouse_up);
            _onMouseDown.add(on_mouse_down);
            TweenLite.to(_background, 0.3, {tint: _glow_color.value});
        }

        private function on_roll_over(e:MouseEvent = null):void {
            _onRollOver.remove(on_roll_over);
            _onRollOut.add(on_roll_out);
            TweenLite.to(_background, 0.3, {alpha: .1});
        }

        private function on_roll_out(e:MouseEvent = null):void {
            _onRollOut.remove(on_roll_out);
            _onRollOver.add(on_roll_over);
            TweenLite.to(_background, 0.3, {alpha: 0});
        }

        override public function destroy():void {
            _onRollOver.removeAll();
            _onRollOut.removeAll();
            _onMouseDown.removeAll();
            _onMouseUp.removeAll();
            _onMouseClick.removeAll();
        }
    }
}

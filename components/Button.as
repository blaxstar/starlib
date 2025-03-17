package net.blaxstar.starlib.components {

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.RGBA;
    import net.blaxstar.starlib.style.Style;

    import com.greensock.TweenLite;
    import com.greensock.plugins.TintPlugin;
    import com.greensock.plugins.TweenPlugin;
    import org.osflash.signals.natives.NativeSignal;
    import flash.display.Graphics;
    import flash.display.Sprite;

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
        private var _label_string:String;
        private var _background:Sprite;
        private var _background_outline:Sprite;
        private var _glow_color:RGBA;
        private var _icon_color:RGBA;
        private var _using_icon:Boolean;
        private var _is_compressed:Boolean;
        private var _display_icon:Icon;
        private var _data:Object;
        // signals
        private var _on_roll_over_signal:NativeSignal;
        private var _on_roll_out_signal:NativeSignal;
        private var _on_mouse_down_signal:NativeSignal;
        private var _on_mouse_up_signal:NativeSignal;
        private var _on_mouse_click_signal:NativeSignal;

        public function Button(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "BUTTON") {
            _label_string = label;

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
            _style = GROUNDED;

            buttonMode = true;
            useHandCursor = true;

            _on_roll_over_signal = new NativeSignal(this, MouseEvent.ROLL_OVER, MouseEvent);
            _on_roll_out_signal = new NativeSignal(this, MouseEvent.ROLL_OUT, MouseEvent);
            _on_mouse_down_signal = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
            _on_mouse_up_signal = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent);
            _on_mouse_click_signal = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);

            super.init();
        }

        /**
         * initializes and adds all required children of the component.
         * created to be overridden.
         */
        override public function add_children():void {
            _background = new Component(this, 0, 0, true);
            _background_outline = new Component(this, 0, 0, true);
            _label = new PlainText(this, 0, 0, _label_string);
            _background.width = _width_;
            _background.height = _height_;
            _label.format(Font.BUTTON);
            _glow_color = Style.GLOW;
            _icon_color = Style.TEXT;
            TweenPlugin.activate([TintPlugin]);
            draw();
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         * created to be overridden.
         */
        override public function draw(e:Event = null):void {
            if (!_using_icon) {
                _width_ = (!_is_compressed) ?_label.width + (PADDING * 2) : _label.width + PADDING;
                _height_ = (!_is_compressed) ? _label.height + (PADDING * 2) : _label.height;
                _background.width = _background_outline.width = _width_;
                _background.height = _background_outline.height = _height_;
                _label.move((_width_ / 2) - (_label.width / 2), (_height_ / 2) - (_label.height / 2));
                
            } else {
                _background.width = _background_outline.width = (!_is_compressed) ?  _width_ : _display_icon.width;
                _background.height = _background_outline.height = (!_is_compressed) ? _height_ : _display_icon.height;
                _display_icon.move(PADDING/2, PADDING/2);
            }
            // TODO: button neds to be redrawn on next frame to size properly, needs fixing
            _on_mouse_down_signal.add(on_mouse_down);
            _on_roll_over_signal.add(on_roll_over);
            super.draw();
        }

        override public function update_skin():void {
            _glow_color = Style.GLOW;
            if (_using_icon) {
                _display_icon.set_color(_icon_color.to_hex_string());
            }
            draw_bg();
        }

        public function add_click_listener(delegate:Function):void {
            if (!_on_mouse_click_signal)
                _on_mouse_click_signal = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
            _on_mouse_click_signal.add(delegate);
        }

        override public function set_size(width:Number, height:Number):void {
          if (_using_icon) {
            _display_icon.set_size(width-PADDING, height-PADDING);
          }
          super.set_size(width, height);
        }

        // ! PRIVATE FUNCTIONS ! //

        private function draw_bg():void {
            _background.graphics.clear();
            _background_outline.graphics.clear();
            filters = [];
            fill_bg();

            if (_style == GROUNDED) {
                draw_bg_outline();
            }

        }

        private function fill_bg():void {
            var graphics:Graphics = _background.graphics;
            graphics.beginFill(_glow_color.value);

            if (!_using_icon) {
                graphics.drawRoundRect(0, 0, _width_, _height_, 7);
            } else {
                graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
            }

            graphics.endFill();
            _background.alpha = 0;

        }

        private function draw_bg_outline():void {
            var graphics:Graphics = _background_outline.graphics;
            graphics.beginFill(0, 0);
            graphics.lineStyle(1, Style.SECONDARY.value, 1, true);

            if (!_using_icon) {
                graphics.drawRoundRect(0, 0, _width_, _height_, 6);
            } else {
                graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
            }
            graphics.endFill();
        }

        // ! GETTERS & SETTERS ! //

        public function set icon(val:String):void {
            _using_icon = true;
            if (_width_ != _height_) {
              _width_ = _height_;
            }

            if (_label && _label.parent) {
                removeChild(_label);
            }
            if (!_display_icon) {
                _display_icon = new Icon(this);
            }

            _display_icon.on_icon_loaded_signal.add(on_icon_loaded);
            _display_icon.set_svg_xml(val);
            _style = DEPRESSED;
        }

        public function get_icon():Icon {
            return _display_icon;
        }

        public function set icon_color(color:RGBA):void {
            _icon_color = color;
            _display_icon.set_color(_icon_color.to_hex_string());
        }

        public function get style():uint {
            return _style;
        }

        public function set style(val:uint):void {
            _style = val;
            commit();
        }

        public function get compressed():Boolean {
            return _is_compressed;
        }

        public function set compressed(val:Boolean):void {
            _is_compressed = val;
            commit();
        }

        public function get label():String {
            return _label_string;
        }

        public function set label(val:String):void {
            _label_string = val;
            commit();
        }

        public function set glow_color(val:RGBA):void {
            _glow_color = val;
            commit();
        }

        public function get on_click():NativeSignal {
            return _on_mouse_click_signal;
        }

        public function get data():Object {
            return _data;
        }

        public function set data(val:Object):void {
            _data = val;
        }

        // ! DELEGATE FUNCTIONS ! //

        private function on_icon_loaded():void {
            _display_icon.on_icon_loaded_signal.remove(on_icon_loaded);
            _display_icon.set_size(width-PADDING, height-PADDING);
            _display_icon.move(PADDING/2, PADDING/2);
            draw();
        }

        private function on_mouse_down(e:MouseEvent = null):void {
            _on_mouse_down_signal.remove(on_mouse_down);
            _on_mouse_up_signal.add(on_mouse_up);
            _on_roll_out_signal.add(on_mouse_up);
            TweenLite.to(_background, 0.3, {tint: _glow_color.shade().value});
        }

        private function on_mouse_up(e:MouseEvent = null):void {
            _on_mouse_up_signal.remove(on_mouse_up);
            _on_roll_out_signal.remove(on_mouse_up);
            _on_mouse_down_signal.add(on_mouse_down);
            TweenLite.to(_background, 0.3, {tint: _glow_color.value});
        }

        private function on_roll_over(e:MouseEvent = null):void {
            _on_roll_over_signal.remove(on_roll_over);
            _on_roll_out_signal.add(on_roll_out);
            TweenLite.to(_background, 0.3, {alpha: .1});
        }

        private function on_roll_out(e:MouseEvent = null):void {
            _on_roll_out_signal.remove(on_roll_out);
            _on_roll_over_signal.add(on_roll_over);
            TweenLite.to(_background, 0.3, {alpha: 0});
        }

        // ! GARBAGE COLLECTION ! //

        override public function destroy():void {
            _on_roll_over_signal.removeAll();
            _on_roll_out_signal.removeAll();
            _on_mouse_down_signal.removeAll();
            _on_mouse_up_signal.removeAll();
            _on_mouse_click_signal.removeAll();
        }
    }
}

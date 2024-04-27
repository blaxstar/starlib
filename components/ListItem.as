package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFormat;

    import net.blaxstar.starlib.style.Font;

    import net.blaxstar.starlib.style.Style;

    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.display.Graphics;
    import net.blaxstar.starlib.style.RGBA;
    import net.blaxstar.starlib.math.Arithmetic;

    /**
     * ...
     * @author ...
     */
    public class ListItem extends Component {
        private const MIN_HEIGHT:uint = 20;
        private const MIN_WIDTH:uint = 100;
        // protected
        protected var _label:PlainText;
        protected var _label_string:String;
        protected var _text_format:TextFormat;
        protected var _glow_color:RGBA;
        protected var _is_glowing:Boolean;
        protected var _is_rounded:Boolean;
        // private
        private var _background:Sprite;
        private var _target_list:List;
        private var _fill_parent:Boolean;
        private var _on_click_signal:NativeSignal;
        private var _on_rollover_signal:NativeSignal;
        private var _on_rollout_signal:NativeSignal;

        public var data:Object;

        public function ListItem(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "New Item") {
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
            _width_ = MIN_WIDTH;
            _height_ = MIN_HEIGHT;
            _is_rounded = true;
            _text_format = Font.SUBTITLE_1;
            mouseChildren = false;
            buttonMode = useHandCursor = true;
            super.init();
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {
            _background = new Sprite();
            _label = new PlainText(this, 0, 0, _label_string);
            _label.mouseChildren = false;
            _label.mouseEnabled = true;
            _label.format(_text_format);
            _glow_color = Style.SURFACE.tint();

            if (!parent is List) {
                on_rollover.add(on_item_rollover);
                on_rollout.add(on_item_rollout);
            }
            
            addChildAt(_background, 0);
            _width_ = Arithmetic.max(_width_, _label.width);
            super.add_children();
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {
            _label.text = _label_string;

            var g:Graphics = _background.graphics;
            g.clear();
            if (_fill_parent && parent) {
                _width_ = parent.width;
            } else if (!_fill_parent) {
                _width_ = Arithmetic.max(_width_, _label.width + PADDING);
            }

            if (_is_glowing) {
                g.beginFill(_glow_color.value, 0.3);
            } else {
                g.beginFill(0, 0);
            }

            if (_is_rounded) {
                g.drawRoundRect(0, 0, _width_, _height_, 7);
            } else {
                g.drawRect(0, 0, _width_, _height_);
            }

            g.endFill();
            _label.move(PADDING/2, PADDING/2);
            super.draw();
        }

        protected function on_item_rollover(e:MouseEvent):void {
            on_rollover.remove(on_item_rollover);
            on_rollout.add(on_item_rollout);
            _is_glowing = true;
            commit();
        }

        protected function on_item_rollout(e:MouseEvent):void {
            on_rollout.remove(on_item_rollout);
            on_rollover.add(on_item_rollover);
            _is_glowing = false;
            commit();
        }

        public function get label_component():PlainText {
            return _label;
        }

        public function get on_click():NativeSignal {
            if (!_on_click_signal)
                _on_click_signal = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
            return _on_click_signal;
        }

        public function get on_rollover():NativeSignal {
            if (!_on_rollover_signal)
                _on_rollover_signal = new NativeSignal(this, MouseEvent.ROLL_OVER, MouseEvent);
            return _on_rollover_signal;
        }

        public function get on_rollout():NativeSignal {
            if (!_on_rollout_signal)
                _on_rollout_signal = new NativeSignal(this, MouseEvent.ROLL_OUT, MouseEvent);
            return _on_rollout_signal;
        }

        private function set associated_list(list:List):void {
            _target_list = list;
        }

        public function set label(val:String):void {
            this.name = _label_string = val;
            commit();
        }

        public function get label():String {
            return _label.text;
        }

        public function get is_glowing():Boolean {
            return _is_glowing;
        }

        public function set is_glowing(value:Boolean):void {
            _is_glowing = value;
            commit();
        }

        public function set fill_parent(value:Boolean):void {
            _fill_parent = value;
            commit();
        }

        override public function set width(value:Number):void {
            _width_ = value;
            _fill_parent = false;
            commit();
        }

        override public function destroy():void {
            _on_click_signal.removeAll();
        }
    }

}

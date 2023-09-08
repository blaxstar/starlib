package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import net.blaxstar.starlib.style.Color;
    import flash.display.Graphics;
    import flash.utils.clearInterval;
    import flash.utils.setInterval;
    import flash.events.Event;

    public class LED extends Component {
        private var _on_color:uint;
        private var _off_color:uint;
        private var _flash_interval:uint;
        private var _is_flashing:Boolean;
        private var _is_on:Boolean;

        /**
         * @param parent
         * @param xpos
         * @param ypos
         * @param onColor
         */
        public function LED(parent:DisplayObjectContainer, xpos:Number = 0, ypos:Number = 0, onColor:uint = 0) {

            if (onColor > 0)
                _on_color = onColor;
            else
                _on_color = Color.PRODUCT_BLUE.value;

            _off_color = 0x1a1a1a;
            _is_flashing = false;

            super(parent, xpos, ypos);
        }

        override public function init():void {
            _width_ = _height_ = 5;
            super.init();
        }

        override public function add_children():void {
            draw();
            _is_on = true;
            super.add_children();
        }

        override public function draw(e:Event = null):void {
            var g:Graphics = this.graphics;
            var current_color:uint = 0;

            if (_is_flashing) {
                if (_is_on) {
                    current_color = _on_color;
                } else {
                    current_color = _off_color;
                }
            } else {
                if (_is_on) {
                    current_color = _on_color;
                } else {
                    current_color = _off_color;
                }
            }
            g.clear();
            g.beginFill(current_color, 1);
            g.drawCircle(_width_, _width_, _width_);
            g.endFill();
        }

        public function flash():void {
            if (_is_on)
                turnOff();
            else
                turn_on();

            draw();
        }

        public function turn_on():void {
            _is_on = true;
        }

        public function turnOff():void {
            _is_on = false;
        }

        public function set offColor(val:uint):void {
            _off_color = val;
            draw();
        }

        public function set on_color(val:uint):void {
            _on_color = val;
            draw();
        }

        public function set isFlashing(val:Boolean):void {
            if (!val) {
                clearInterval(_flash_interval);
            } else {
                _flash_interval = setInterval(flash, 1000);
            }
            _is_flashing = val;
            draw();
        }
    }
}

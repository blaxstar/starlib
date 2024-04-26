package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.display.Graphics;
    import net.blaxstar.starlib.style.Style;

    public class Divider extends Component {
        static public const ORIENTATION_HORIZONTAL:uint = 0;
        static public const ORIENTATION_VERTICAL:uint = 1;

        private var _orientation:uint;
        private var _length:uint;
        private var _graphics:Graphics;

        public function Divider(parent:DisplayObjectContainer = null, xpos:uint = 0, ypos:uint = 0, orientation:uint = 0, length:uint = 200) {

            _orientation = orientation;
            _length = length;
            super(parent, xpos, ypos);
        }

        override public function init():void {
            _graphics = this.graphics;
            super.init();
            cacheAsBitmap = true;
        }

        override public function draw(e:Event = null):void {
            _graphics.clear();
            _graphics.lineStyle(2, Style.SECONDARY.value, 1, true);

            if (_orientation == ORIENTATION_HORIZONTAL) {
                _graphics.moveTo(0, PADDING);
                _graphics.lineTo(_length, PADDING);
                _width_ = _length;
                _height_ = 2 + (PADDING * 2);
            } else if (_orientation == ORIENTATION_VERTICAL) {
                _graphics.moveTo(PADDING, 0);
                _graphics.lineTo(PADDING, _length);
                _width_ = 2 + (PADDING * 2);
                _height_ = _length;
            }
        }

        public function get orientation():uint {
            return _orientation;
        }

        public function set_orientation(value:uint):void {
            _orientation = value;
            commit();
        }

        public function set_length(value:Number):void {
            _length = value;
            commit();
        }

    } // * end class
} // * end package

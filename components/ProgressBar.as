package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;

    import net.blaxstar.starlib.style.Style;

    /**
     * ...
     * @author Deron Decamp
     */
    public class ProgressBar extends Component {

        static private const START_WIDTH:uint = 140;

        private var _track:Sprite;
        private var _track_fill:Sprite;
        private var _thickness:uint;
        private var _track_length:uint;
        private var _percent_loaded:Number;

        public function ProgressBar(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
            super(parent, xpos, ypos);

        }

        override public function init():void {
            _thickness = 3;
            _track_length = 200;
            _width_ = _track_length;
            _height_ = _thickness;
            _percent_loaded = 0;
            _track = new Sprite();
            _track_fill = new Sprite();
            draw_track();
            draw_track_fill();

            super.init();
        }

        override public function add_children():void {
            addChildAt(_track, 0);
            addChildAt(_track_fill, 1);

            super.add_children();
        }

        override public function draw(e:Event = null):void {
            draw_track();
            draw_track_fill();
            super.draw(e);
        }

        public function reset():void {
          _percent_loaded = 0;
          _track_fill.graphics.clear()
          draw();
        }

        override public function set width(value:Number):void {
          _track_length = value;
          super.width = value;
        }

        override public function set height(value:Number):void {
          _thickness = value;
          super.height = value;
        }

        public function set progress(val:uint):void {
            _percent_loaded = val;
            draw();
        }

        public function get progress():uint {
            return _percent_loaded;
        }

        protected function draw_track():void {
            _track.graphics.lineStyle(_thickness, Style.SECONDARY_DARK.value, 1);
            _track.graphics.lineTo(_width_, 0);
        }

        protected function draw_track_fill():void {
            _track_fill.graphics.lineStyle(_thickness, Style.SECONDARY.value, 1);
            _track_fill.graphics.lineTo( _track_length * (_percent_loaded / 100), 0);
        }

        public function get thickness():uint {
          return _thickness;
        }

        public function set thickness(val:uint):void {
          _thickness = val;
        }
    }

}

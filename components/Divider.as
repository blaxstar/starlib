package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.display.Graphics;
  import net.blaxstar.style.Style;

  public class Divider extends Component {
    private const HORIZONTAL:uint = 0;
    private const VERTICAL:uint = 1;

    private var _orientation:uint;
    private var _length:uint;
    private var _graphics:Graphics;

    public function Divider(parent:DisplayObjectContainer = null, xpos:uint = 0, ypos:uint = 0, orientation:uint = 0, length:uint = 700) {

      _orientation = orientation;
      _length = length;
      super(parent, xpos, ypos);
    }

    override public function init():void {
      _graphics = this.graphics;
      super.init();
    }

    override public function draw(e:Event = null):void {
      _graphics.lineStyle(2, Style.SECONDARY.value, 1, true);

      if (_orientation == HORIZONTAL) {
        _graphics.moveTo(0, PADDING);
        _graphics.lineTo(_length, PADDING);
        _width_ = _length;
        _height_ = 2 + (PADDING * 2);
      }
      else if (_orientation == VERTICAL) {
        _graphics.moveTo(PADDING, 0);
        _graphics.lineTo(PADDING, _length);
        _width_ = 2 + (PADDING * 2);
        _height_ = _length;
      }
    }
  }
}
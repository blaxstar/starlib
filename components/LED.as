package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import net.blaxstar.style.Color;
  import flash.display.Graphics;
  import flash.utils.clearInterval;
  import flash.utils.setInterval;
  import flash.events.Event;

  public class LED extends Component {
    private var _onColor:uint;
    private var _offColor:uint;
    private var _flashInterval:uint;
    private var _isFlashing:Boolean;
    private var _isOn:Boolean;

    /**
     * @param parent
     * @param xpos
     * @param ypos
     * @param onColor
     */
    public function LED(parent:DisplayObjectContainer, xpos:Number = 0, ypos:Number = 0, onColor:uint = 0) {

      if (onColor > 0)
        _onColor = onColor;
      else
        _onColor = Color.PRODUCT_BLUE.value;

      _offColor = 0x1a1a1a;
      _isFlashing = false;

      super(parent, xpos, ypos);
    }

    override public function init():void {
      _width_ = _height_ = 5;
      super.init();
    }

    override public function addChildren():void {
      draw();
      _isOn = true;
      super.addChildren();
    }

    override public function draw(e:Event = null):void {
      var g:Graphics = this.graphics;
      var currColor:uint = 0;

      if (_isFlashing) {
        if (_isOn) {
          currColor = _onColor;
        }
        else {
          currColor = _offColor;
        }
      }
      else {
        if (_isOn) {
          currColor = _onColor;
        }
        else {
          currColor = _offColor;
        }
      }
      g.clear();
      g.beginFill(currColor, 1);
      g.drawCircle(_width_, _width_, _width_);
      g.endFill();
    }

    public function flash():void {
      if (_isOn)
        turnOff();
      else
        turnOn();

      draw();
    }

    public function turnOn():void {
      _isOn = true;
    }

    public function turnOff():void {
      _isOn = false;
    }

    public function set offColor(val:uint):void {
      _offColor = val;
      draw();
    }

    public function set onColor(val:uint):void {
      _onColor = val;
      draw();
    }

    public function set isFlashing(val:Boolean):void {
      if (!val) {
        clearInterval(_flashInterval);
      }
      else {
        _flashInterval = setInterval(flash, 1000);
      }
      _isFlashing = val;
      draw();
    }
  }
}
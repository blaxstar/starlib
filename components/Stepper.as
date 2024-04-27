package net.blaxstar.starlib.components {
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.events.MouseEvent;

  public class Stepper extends Component {

    private var _box:HorizontalBox;
    private var _value_display:PlainText;
    private var _value:uint;
    private var _down_button:Button;
    private var _up_button:Button;

    // TODO (dyxribo): stepper breaks verticalbox + scrollrect combo.
    public function Stepper(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
      super(parent, xpos, ypos);
    }

    override public function add_children():void {
      _value = 0;

      _box = new HorizontalBox(this, 0, 0);
      _down_button = new Button(_box, 0, 0);
      _value_display = new PlainText(_box, 0, 0, '0');
      _up_button = new Button(_box, 0, 0);

      _down_button.icon = Icon.MINUS_CIRCLED;
      _up_button.icon = Icon.PLUS_CIRCLED;
      _down_button.style = _up_button.style = Button.DEPRESSED;
      _down_button.set_size(32,32);
      _up_button.set_size(32,32);
      _down_button.on_click.add(step_down);
      _up_button.on_click.add(step_up);
      is_showing_bounds = true;
      super.add_children();
    }

    override public function draw(e:Event = null):void {
      _value_display.text = _value.toString();
      _box.alignment = HorizontalBox.CENTER;
      _width_ = _box.width;
      _height_ = _box.height;
      super.draw();
      dispatchEvent(_resize_event_);
    }

    private function step_up(e:MouseEvent):void {
      if (_value >= uint.MAX_VALUE) {
        return;
      }
      ++_value;
      draw();
    }

    private function step_down(e:MouseEvent):void {
      if (_value == 0) {
        return;
      }
      --_value;
      draw();
    }

    public function get value():uint {
      return _value;
    }

    public function get down_button():Button {
      return _down_button;
    }

    public function get up_button():Button {
      return _up_button;
    }
  }
}

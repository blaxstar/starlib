package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import thirdparty.com.lorentz.processing.ProcessExecutor;
  import net.blaxstar.style.Color;
  import net.blaxstar.style.Style;

  public class Stepper extends Component {

    private var _box:HorizontalBox;
    private var _valueDisplay:PlainText;
    private var _value:uint;
    private var _downButton:Button;
    private var _upButton:Button;

    // TODO (dyxribo): stepper breaks verticalbox + scrollrect combo.
    public function Stepper(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
      super(parent, xpos, ypos);
    }

    override public function addChildren():void {
      _value = 0;

      _box = new HorizontalBox(this, 0, 0);
      _downButton = new Button(_box, 0, 0);
      _valueDisplay = new PlainText(_box, 0, 0, '0');
      _upButton = new Button(_box, 0, 0);

      _downButton.icon = Icon.MINUS_CIRCLED;
      _upButton.icon = Icon.PLUS_CIRCLED;
      _downButton.style = _upButton.style = Button.DEPRESSED;

      updateSkin();
      _downButton.on_click.add(stepDown);
      _upButton.on_click.add(stepUp);
      super.addChildren();
    }

    override public function draw(e:Event = null):void {
      _valueDisplay.text = _value.toString();
      _box.alignment = HorizontalBox.CENTER;
      _width_ = _box.width;
      _height_ = _box.height;
      super.draw();
    }

    override public function updateSkin():void {
      _downButton.getIcon().setColor(Style.SECONDARY.value.toString());
      _upButton.getIcon().setColor(Style.SECONDARY.value.toString());
    }

    private function stepUp(e:MouseEvent):void {
      if (_value >= uint.MAX_VALUE)
        return;
      ++_value;
      draw();
    }

    private function stepDown(e:MouseEvent):void {
      if (_value == 0)
        return;
      --_value;
      draw();
    }

    public function get value():uint {
      return _value;
    }

    public function get downButton():Button {
      return _downButton;
    }

    public function get upButton():Button {
      return _upButton;
    }
  }
}

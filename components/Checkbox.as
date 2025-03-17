package net.blaxstar.starlib.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.osflash.signals.natives.NativeSignal;
  import net.blaxstar.starlib.style.Style;

  /**
   * ...
   * @author ...
   */
  public class Checkbox extends Component {
    static protected var _checkboxes_:Vector.<Checkbox>;
    private const _MIN_SIZE:int = 18;
    private const _MINI_PADDING:int = 4;
    private var _size:uint;
    private var _check_tick:Shape;
    private var _check_outline:Shape;
    private var _label:PlainText;
    private var _label_text:String;
    private var _checked:Boolean;
    private var _on_click:NativeSignal;
    private var _current_group:uint;
    private var _value:Object;

    public function Checkbox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
      if (!_checkboxes_)
        _checkboxes_ = new Vector.<Checkbox>();
      super(parent, xpos, ypos);
      _checkboxes_.push(this);
    }

    override public function init():void {
      _size = _MIN_SIZE;
      super.init();
    }

    override public function add_children():void {
      _check_tick = new Shape();
      _check_outline = new Shape();
      addChild(_check_tick);
      addChild(_check_outline);

      super.add_children();
      _on_click = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
      _on_click.add(on_click);
    }

    override public function draw(e:Event = null):void {
      _width_ = _height_ = _size;
      var graphics:Graphics = _check_outline.graphics;
      graphics.clear();
      graphics.beginFill(0, 0);
      graphics.lineStyle(2, Style.SECONDARY.value, 2, false);
      graphics.drawRoundRect(0, 0, _size, _size, 7);
      graphics.endFill();
      // reuse the graphics var to draw the second shape
      graphics = _check_tick.graphics;
      graphics.clear();
      graphics.beginFill(Style.SECONDARY.value);
      graphics.drawRoundRect(PADDING/2, PADDING/2, _size - PADDING, _size - PADDING, 7);
      graphics.endFill();

      if (_checked) {
        _check_tick.alpha = 1;
      } else {
        _check_tick.alpha = 0;
      }

      _width_ = (_label) ? _size + _MINI_PADDING + _label.width : _size;
      _height_ = (_label) ? Math.max(_size, _label.height) : _size;

      dispatchEvent(_resize_event_);
      super.draw();
    }

    override protected function on_theme_update():void {
      draw();
    }

    public function get_checked_box_in_group():Checkbox {

      for (var i:uint = 0; i < _checkboxes_.length; i++) {

        var current_checkbox:Checkbox = _checkboxes_[i];
        if (current_checkbox.checked == true && current_checkbox.group == this.group) {
          return current_checkbox;
        }
      }
      return null;
    }

    private function uncheck_other_group_boxes():void {
      for (var i:uint = 0; i < _checkboxes_.length; i++) {

        var current_checkbox:Checkbox = _checkboxes_[i];
        if (current_checkbox != this && current_checkbox.group == this.group && current_checkbox.checked) {
          current_checkbox.checked = false;
        }
      }
    }

    public function uncheck_all_boxes_in_group():void {
      for (var i:uint = 0; i < _checkboxes_.length; i++) {
        _checkboxes_[i].checked = false;
      }
    }

    private function on_click(e:MouseEvent):void {
      checked = (checked) ? false : true;
    }

    public function get value():Object {
      return _value;
    }

    public function set value(val:Object):void {
      _value = val;
    }

    public function get size():uint {
      return _size;
    }

    public function set size(value:uint):void {
      if (value < _MIN_SIZE) {
        _size = _MIN_SIZE;
      } else {
        _size = value;
      }
      commit();
    }

    public function get group():uint {
      return _current_group;
    }

    public function set group(val:uint):void {
      _current_group = val;
    }

    public function get checked():Boolean {
      return _checked;
    }

    public function set checked(val:Boolean):void {
      if (_current_group || _current_group == 0) {
        if (val) {
          uncheck_other_group_boxes();
        }
      }
      _checked = val;
      commit();
    }

    public function get label():String {
      return _label_text;
    }

    public function set label(val:String):void {
      if (!_label) {
        _label = new PlainText(this, _size + _MINI_PADDING, 0, val);
      }
      _label_text = val;
      commit();
    }

    override public function destroy():void {
      super.destroy();
      _on_click.remove(on_click);
    }
  }
}

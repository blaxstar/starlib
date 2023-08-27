package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import thirdparty.org.osflash.signals.natives.NativeSignal;
  import net.blaxstar.style.Style;

  /**
   * ...
   * @author ...
   */
  public class Checkbox extends Component {
    static protected var checkboxes:Vector.<Checkbox>;
    private var _size:uint;
    private var _checkSquare:Shape;
    private var _checkOutline:Shape;
    private var _label:PlainText;
    private var _labelText:String;
    private var _checked:Boolean;
    private var _onClick:NativeSignal;
    private var _currentGroup:uint;
    private var _value:Object;

    public function Checkbox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
      if (!checkboxes)
        checkboxes = new Vector.<Checkbox>();
      super(parent, xpos, ypos);
      checkboxes.push(this);
    }

    override public function init():void {
      _size = 18;
      super.init();
    }

    override public function addChildren():void {
      _checkSquare = new Shape();
      _checkOutline = new Shape();
      addChild(_checkSquare);
      addChild(_checkOutline);

      super.addChildren();
      _onClick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
      _onClick.add(onClick);
    }

    override public function draw(e:Event = null):void {
      _width_ = _height_ = _size;

      _checkOutline.graphics.beginFill(0, 0);
      _checkOutline.graphics.lineStyle(1, Style.SECONDARY.value, 2, false);
      _checkOutline.graphics.drawRect(0, 0, _size, _size);
      _checkOutline.graphics.endFill();

      var g:Graphics = _checkSquare.graphics;
      g.beginFill(Style.SECONDARY.value);
      g.drawRect(4, 4, _width_ - 8, _height_ - 8);
      g.endFill();

      if (_checked)
        _checkSquare.alpha = 1;
      else
        _checkSquare.alpha = 0;

      _width_ = (_label) ? _size + 4 + _label.width : _size;
      _height_ = (_label) ? Math.max(_size, _label.height) : _size;

      dispatchEvent(_resizeEvent_);
      super.draw();
    }

    public function getCheckedInGroup():Checkbox {
      for (var i:uint = 0; i < checkboxes.length; i++) {
        var cb:Checkbox = checkboxes[i];
        if (cb.checked == true && cb.group == this.group) {
          return cb;
        }
      }
      return null;
    }

    private function uncheckOthers():void {
      for (var i:uint = 0; i < checkboxes.length; i++) {
        var cb:Checkbox = checkboxes[i];
        if (cb != this && cb.group == this.group && cb.checked) {
          cb.checked = false;
        }
      }
    }

    public function uncheckAll():void {
      for (var i:uint = 0; i < checkboxes.length; i++) {
        checkboxes[i].checked = false;
      }
    }

    private function onClick(e:MouseEvent):void {
      checked = (checked) ? false : true;
    }

    public function get value():Object {
      return _value;
    }

    public function set value(val:Object):void {
      _value = val;
    }

    public function get group():uint {
      return _currentGroup;
    }

    public function set group(val:uint):void {
      _currentGroup = val;
    }

    public function get checked():Boolean {
      return _checked;
    }

    public function set checked(val:Boolean):void {
      if (_currentGroup || _currentGroup == 0) {
        if (val)
          uncheckOthers();
      }
      _checked = val;
      draw();
    }

    public function get label():String {
      return _labelText;
    }

    public function set label(val:String):void {
      if (!_label)
        _label = new PlainText(this, _size + 4, 0, val);
      _labelText = val;
      commit();
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);
      _onClick.remove(onClick);
    }
  }
}
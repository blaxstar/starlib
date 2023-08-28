package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextFormat;

  import net.blaxstar.style.Font;

  import net.blaxstar.style.Style;

  import thirdparty.org.osflash.signals.natives.NativeSignal;
  import flash.display.Graphics;

  /**
   * ...
   * @author ...
   */
  public class ListItem extends Component {
    private const MIN_HEIGHT:uint = 50;
    private const MIN_WIDTH:uint = 100;

    private const PADDING:uint = 7;
    static private var _procid:uint = 0;

    // public
    public var linkageid:uint;
    // private
    private var _label:PlainText;
    private var _labelString:String;
    private var _textFormat:TextFormat;
    private var _background:Sprite;
    private var _fillColor:uint;
    private var _targetList:List;
    private var _onClick:NativeSignal;
    private var _onRollOver:NativeSignal;
    private var _onRollOut:NativeSignal;

    public var data:Object;

    public function ListItem(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "New Item") {
      linkageid = _procid++;
      _labelString = label;
      super(parent, xpos, ypos);
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children
     * and committing the visual changes to be written on the next frame.
     * created to be overridden.
     */
    override public function init():void {
      _width_ = MIN_WIDTH;
      _height_ = MIN_HEIGHT;
      _textFormat = Font.BUTTON;
      mouseChildren = false;
      buttonMode = useHandCursor = true;
      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {
      _background = new Sprite();
      _label = new PlainText(this, 0, 0, _labelString);
      _label.mouseChildren = false;
      _label.mouseEnabled = _label.doubleClickEnabled = true;
      _label.format(_textFormat);

      addChildAt(_background, 0);

      super.addChildren();
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      var g:Graphics = _background.graphics;
      g.beginFill(_fillColor,1);
      g.drawRect(0,0,_width_,_height_);
      g.endFill();

      _label.text = _labelString;
      _label.move((_width_ / 2) - (_label.width / 2), (_height_ / 2) - (_label.height / 2));
    }

    /** END INTERFACE ===================== */

    public function get labelComponent():PlainText {
      return _label;
    }

    public function get fillColor():uint {
      return _fillColor;
    }

    public function set fillColor(val:uint):void {
      _fillColor = val;
      commit();
    }

    public function get onClick():NativeSignal {
      if (!_onClick)
        _onClick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
      return _onClick;
    }

    public function get onRollOver():NativeSignal {
      if (!_onRollOver)
        _onRollOver = new NativeSignal(this, MouseEvent.ROLL_OVER, MouseEvent);
      return _onRollOver;
    }

    public function get onRollOut():NativeSignal {
      if (!_onRollOut)
        _onRollOut = new NativeSignal(this, MouseEvent.ROLL_OUT, MouseEvent);
      return _onRollOut;
    }

    private function set associatedList(list:List):void {
      _targetList = list;
    }

    public function set label(val:String):void {
      this.name = _labelString = val;
      commit();
    }

    public function get label():String {
      return _label.text;
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);
      _onClick.removeAll();
    }
  }

}
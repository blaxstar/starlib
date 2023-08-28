package net.blaxstar.components {

  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.text.AntiAliasType;
  import flash.text.GridFitType;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;

  import net.blaxstar.style.Font;
  import net.blaxstar.style.Style;

  /**
   * A simple component for displaying text information.
   * @author Deron D. (decamp.deron@gmail.com)
   */
  public class PlainText extends Component {
    private const DEFAULT_WIDTH:uint = 300;
    private const DEFAULT_HEIGHT:uint = 30;

    private var _textField:TextField;
    private var _textFieldString:String;
    private var _textFormat:TextFormat;
    private var _colorOverwritten:Boolean;

    public function PlainText(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, text:String = "") {
      _textFieldString = text;
      super(parent, xpos, ypos);
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children
     * and committing the visual changes to be written on the next frame.
     * created to be overridden.
     */
    override public function init():void {
      _width_ = DEFAULT_WIDTH;
      _height_ = DEFAULT_HEIGHT;
      _textFormat = Font.BODY_2;
      mouseEnabled = mouseChildren = false;
      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {
      _textField = new TextField();
      _textField.embedFonts = Font.embedFonts;
      _textField.type = TextFieldType.DYNAMIC;
      _textField.antiAliasType = AntiAliasType.ADVANCED;
      _textField.gridFitType = GridFitType.PIXEL;
      _textField.thickness = 0;
      _textField.sharpness = 400;
      _textField.selectable = _textField.border = _textField.multiline = _textField.wordWrap = _textField.mouseEnabled = _textField.selectable = false;
      _textField.defaultTextFormat = _textFormat;
      _textField.autoSize = TextFieldAutoSize.LEFT;
      _textField.text = _textFieldString;
      _textField.textColor = Style.TEXT.value;
      addChild(_textField);

      super.addChildren();
    }

    override protected function on_added(e:Event):void {
      draw();
    }
    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      _textField.text = _textFieldString;

      if (!_textField.multiline) {
        _width_ = _textField.width;
        _height_ = _textField.height;
      }
      else {
        _textField.width = _width_;
        _height_ = _textField.height;
      }

      onResize.dispatch(_resizeEvent_);
      super.draw();
    }

    /** END INTERFACE ===================== */

    override public function updateSkin():void {
        if (!_colorOverwritten) color = Style.TEXT.value;
    }

    public function format(fmt:TextFormat = null):void {
      if (fmt == null) {
        _textField.setTextFormat(Font.BODY_2);
        _textFormat = Font.BODY_2;
      }
      else {
        _textField.defaultTextFormat = fmt;
        _textFormat = fmt;
      }
      commit();
    }

    public function get text():String {
      return _textFieldString;
    }

    public function set text(val:String):void {
      _textFieldString = val;
      commit();
    }

    public function get htmlText():String {
      return _textField.htmlText;
    }

    public function set htmlText(val:String):void {
      _textField.htmlText = val;
      commit();
    }

    public function get color():uint {
      return _textField.textColor;
    }

    public function set color(val:uint):void {
      _colorOverwritten = true;
      _textField.text = (_textFieldString.length) ? _textFieldString : '...';
      _textField.textColor = val;
      commit();
    }

    public function get textWidth():Number {
      return _textField.textWidth;
    }

    public function get textHeight():Number {
      return _textField.textHeight;
    }

    public function set multiline(val:Boolean):void {
      _textField.multiline = _textField.wordWrap = val;
    }

    public function set border(border:Boolean):void {
      _textField.border = border;
      _textField.borderColor = Style.SECONDARY.value;
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);
    }

  }

}

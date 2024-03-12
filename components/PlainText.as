package net.blaxstar.starlib.components {

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.Style;

    /**
     * A simple component for displaying text information.
     * @author Deron D. (decamp.deron@gmail.com)
     */
    public class PlainText extends Component {
        private const DEFAULT_WIDTH:uint = 300;
        private const DEFAULT_HEIGHT:uint = 30;

        private var _textfield:TextField;
        private var _textfield_string:String;
        private var _text_format:TextFormat;
        private var _colorOverwritten:Boolean;

        public function PlainText(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, text:String = "") {
            _textfield_string = text;
            super(parent, xpos, ypos);
        }

        override public function init():void {
            mouseEnabled = mouseChildren = false;
            super.init();
        }

        override public function add_children():void {
            _width_ = DEFAULT_WIDTH;
            _height_ = DEFAULT_HEIGHT;

            _textfield = new TextField();
            _text_format = Font.BODY_2;
            _textfield.embedFonts = Font.embedFonts;
            _textfield.type = TextFieldType.DYNAMIC;
            _textfield.antiAliasType = AntiAliasType.ADVANCED;
            _textfield.gridFitType = GridFitType.PIXEL;
            _textfield.thickness = 0;
            _textfield.sharpness = 400;
            _textfield.selectable = _textfield.border = _textfield.multiline = _textfield.wordWrap = _textfield.mouseEnabled = _textfield.selectable = false;
            _textfield.defaultTextFormat = _text_format;
            _textfield.autoSize = TextFieldAutoSize.LEFT;
            _textfield.text = _textfield_string;
            _textfield.textColor = Style.TEXT.value;
            cacheAsBitmap = _textfield.cacheAsBitmap = true;

            addChild(_textfield);
            super.add_children();
        }

        override public function draw(e:Event = null):void {
            super.draw(e);
            _textfield.text = _textfield_string;

            if (!_textfield.multiline) {
                _width_ = _textfield.width;
                dispatchEvent(new Event(Event.RESIZE));
                _height_ = _textfield.height = 18;
            } else {
                _textfield.width = _width_;
                _height_ = _textfield.height;
            }

        }

        override public function update_skin():void {
            if (!_colorOverwritten) {
                color = Style.TEXT.value;
            }
        }

        public function format(fmt:TextFormat = null):void {
            if (fmt == null) {
                _textfield.setTextFormat(Font.BODY_2);
                _text_format = Font.BODY_2;
            } else {
                _textfield.defaultTextFormat = fmt;
                _text_format = fmt;
            }
            commit();
        }

        public function get text():String {
            return _textfield_string;
        }

        public function set text(val:String):void {
            _textfield_string = val;
            commit();
        }

        public function get htmlText():String {
            return _textfield.htmlText;
        }

        public function set htmlText(val:String):void {
            _textfield.htmlText = val;
            commit();
        }

        public function get color():uint {
            return _textfield.textColor;
        }

        public function set color(val:uint):void {
            _colorOverwritten = true;
            _textfield.text = (_textfield_string.length) ? _textfield_string : '...';
            _textfield.textColor = val;
            commit();
        }

        public function get text_width():Number {
            return _textfield.textWidth;
        }

        public function get text_height():Number {
            return _textfield.textHeight;
        }

        public function set multiline(val:Boolean):void {
            _textfield.multiline = _textfield.wordWrap = val;
        }

        public function set border(border:Boolean):void {
            _textfield.border = border;
            _textfield.borderColor = Style.SECONDARY.value;
        }

        override public function destroy():void {
        }

    }

}

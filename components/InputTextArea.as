package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.text.TextFormat;
    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
    import net.blaxstar.starlib.style.Style;
    import net.blaxstar.starlib.style.Font;
    import flash.events.FocusEvent;
    import flash.events.Event;
    import net.blaxstar.starlib.utils.Strings;

    public class InputTextArea extends Component {
        private var _text_field:TextField;
        private var _textfield_string:String;
        private var _text_format:TextFormat;
        private var _hint_text:String;
        private var _is_hinting:Boolean;
        private var _showing_underline:Boolean;
        private var _textfield_background:Shape;
        private var _textfield_underline:Shape;
        private var _textfield_underline_strength:uint;
        // signals
        private var _on_focus:NativeSignal;
        private var _on_defocus:NativeSignal;

        public function InputTextArea(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, hint_text:String = "type something...") {
            _hint_text = _textfield_string = hint_text;
            _is_hinting = true;

            super(parent, xpos, ypos);
        }

        // ! PUBLIC FUNCTIONS ! //

        override public function init():void {
            _text_format = Font.BODY_2;
            _text_format.color = Style.TEXT.value;
            _showing_underline = true;
            super.init();
        }

        override public function add_children():void {
            _text_field = new TextField();
            _text_field.type = TextFieldType.INPUT;
            _text_field.autoSize = TextFieldAutoSize.NONE;
            _text_field.multiline = true;
            _text_field.wordWrap = true;
            _text_field.defaultTextFormat = _text_format;
            _text_field.embedFonts = true;
            _text_field.selectable = true;
            _text_field.border = false;
            _text_field.background = false;
            _text_field.height = 30;
            _text_field.width = 200;
            _text_field.text = _textfield_string;
            _text_field.setTextFormat(_text_format);
            addChild(_text_field);

            _textfield_background = new Shape();
            _textfield_underline = new Shape();
            _textfield_underline_strength = 1;
            addChild(_textfield_background);
            addChild(_textfield_underline);
            setChildIndex(_textfield_background, 0);
            update_underline();
            update_background();

            _on_focus = new NativeSignal(_text_field, FocusEvent.FOCUS_IN, FocusEvent);
            _on_defocus = new NativeSignal(_text_field, FocusEvent.FOCUS_OUT, FocusEvent);

            _on_focus.add(on_focus);

            super.add_children();

        }

        override public function draw(e:Event = null):void {
            // determine text color based on current field status
            if (_is_hinting) {
                if (Style.CURRENT_THEME == Style.DARK) {
                    _text_field.textColor = Style.TEXT.shade().value;
                } else {
                    _text_field.textColor = Style.TEXT.tint().value;
                }
                _text_field.text = _hint_text;
            } else {
                _text_field.textColor = Style.TEXT.value;
                // set the text
                _text_field.text = _textfield_string;
            }

            // update the underline if applicable, just in case width changes
       
            _text_field.width = _width_;
            _text_field.height = _height_;
            update_underline();
            update_background();
            dispatchEvent(_resize_event_);
        }

        public function format(fmt:TextFormat = null):void {
            if (fmt == null) {
                _text_field.setTextFormat(Font.BODY_2);
                _text_format = Font.BODY_2;
            } else {
                _text_field.defaultTextFormat = fmt;
                _text_format = fmt;
            }
            commit();
        }

        private function update_background():void {
            _textfield_background.graphics.clear();
            _textfield_background.graphics.beginFill(Style.BACKGROUND.shade(0.8).value);
            _textfield_background.graphics.drawRoundRect(0,0,_width_,_height_,7,7);
            _textfield_background.graphics.endFill();
        }

        private function update_underline():void {
            _textfield_underline.graphics.clear();
            _textfield_underline.graphics.lineStyle(_textfield_underline_strength, Style.SECONDARY.value);
            _textfield_underline.graphics.lineTo(_text_field.width, 0);
            _textfield_underline.y = _text_field.height;
            _width_ = _textfield_underline.width;
            _height_ = _textfield_underline.y + _textfield_underline.height;
        }

        private function on_focus(e:FocusEvent):void {
            _on_focus.remove(on_focus);

            if (_is_hinting) {
                _is_hinting = false;
                _textfield_string = "";
                _text_field.text = "";
            } else {
                _text_field.setSelection(0, _text_field.text.length);
            }

            if (_showing_underline) {
                _textfield_underline_strength = 2;
                update_underline();
            }
            update_background();

            _on_defocus.add(on_defocus);
        }

        private function on_defocus(e:FocusEvent):void {
            _on_defocus.remove(on_defocus);

            if (_text_field.text == "") {
                show_hint_text();
            } else {
                _textfield_string = _text_field.text;
            }

            if (_showing_underline) {
                _textfield_underline_strength = 1;
                update_underline();
            }
            update_background();

            _on_focus.add(on_focus);
        }

        private function show_hint_text():void {
            _text_field.text = _hint_text;
            _is_hinting = true;
            commit();
        }

        public function set restrict(value:String):void {
            _text_field.restrict = value;
        }

        public function get showing_underline():Boolean {
            return _showing_underline;
        }

        public function set showing_underline(val:Boolean):void {
            if (!val) {
                _textfield_underline.graphics.clear();
                if (_textfield_underline.parent) {
                    removeChild(_textfield_underline);
                }
            }
            _showing_underline = val;
            draw();
        }

        public function get input_target():TextField {
            return _text_field;
        }

        public function get text():String {
            _textfield_string = _text_field.text;
            return _textfield_string;
        }

        public function set text(val:String):void {
            if (val != "") {
                _is_hinting = false;
            }
            _textfield_string = val;
            draw();
        }

        public function get hint_text():String {
            return _hint_text;
        }

        public function set hint_text(val:String):void {
            if (Strings.is_empty_or_null(val)) {
                _hint_text = "enter text...";
            } else {
                _hint_text = val;
            }

            show_hint_text();
        }

        public function get color():uint {
            return _text_field.textColor;
        }

        public function set color(val:uint):void {
            _text_field.textColor = val;
        }

        // ! GARBAGE COLLECTION ! //
        override public function destroy():void {
            _on_focus.removeAll();
            _on_defocus.removeAll();
        }
    }
}

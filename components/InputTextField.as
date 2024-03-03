package net.blaxstar.starlib.components {

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    import net.blaxstar.starlib.input.InputEngine;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.Style;

    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.utils.StringUtil;

    /**
     * ...
     * @author Deron D. (decamp.deron@gmail.com)
     */
    public class InputTextField extends Component {

        private var _text_field:TextField;
        private var _textfield_underline:Shape;
        private var _textfield_underline_strength:uint;
        private var _textfield_string:String;
        private var _text_format:TextFormat;
        private var _hint_text:String;
        private var _leading_icon:Icon;
        private var _suggestion_cache:Vector.<Suggestion>;
        private var _suggestion_list:List;
        private var _suggestion_limit:uint;
        private var _suggestion_generator:Suggestitron;
        private var _suggestion_iterator_index:uint;
        private var _input_cache:String;
        private var _showing_underline:Boolean;
        private var _showing_suggestions:Boolean;
        private var _has_leading_icon:Boolean;
        private var _selected_suggestion:Suggestion;
        private var _suggestions_available:Boolean;
        private var _is_password_field:Boolean;
        private var _is_hinting:Boolean;

        private var _input_engine:InputEngine;
        private var _on_focus:NativeSignal;
        private var _on_defocus:NativeSignal;
        private var _on_text_update:NativeSignal;
        private var _typed_chars:uint;

        // TODO (dyxribo, STARCOMPS-3): add icon support to InputTextField
        public function InputTextField(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, hintText:String = "") {
            _hint_text = _textfield_string = hintText;
            super(parent, xpos, ypos);
        }

        // * public methods

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
            _text_field.defaultTextFormat = _text_format;
            _text_field.embedFonts = true;
            _text_field.antiAliasType = AntiAliasType.ADVANCED;
            _text_field.gridFitType = GridFitType.SUBPIXEL;
            _text_field.selectable = true;
            _text_field.sharpness = 300;
            _text_field.border = false;
            _text_field.background = false;
            _text_field.height = 30;
            _text_field.width = 200;
            _text_field.text = _textfield_string;
            _text_field.setTextFormat(_text_format);
            addChild(_text_field);

            if (_showing_underline) {
                _textfield_underline = new Shape();
                _textfield_underline_strength = 1;
                addChild(_textfield_underline);
                update_underline();
            }

            _on_focus = new NativeSignal(_text_field, FocusEvent.FOCUS_IN, FocusEvent);
            _on_defocus = new NativeSignal(_text_field, FocusEvent.FOCUS_OUT, FocusEvent);

            // TODO (dyxribo, STARCOMPS-11): use keydown listeners in favor of change event in InputTextField
            _on_text_update = new NativeSignal(_text_field, Event.CHANGE, Event);
            _on_focus.add(onFocus);
            _on_text_update.add(onTextChange);

            super.add_children();

        }

        override public function draw(e:Event = null):void {
            if (_text_field.text == _hint_text || _text_field.text.length < 1) {
                if (_is_hinting) {
                    if (Style.CURRENT_THEME == Style.DARK) {
                        _text_field.textColor = Style.TEXT.shade().value;
                    } else {
                        _text_field.textColor = Style.TEXT.tint().value;
                    }
                    _text_field.text = _hint_text;
                } else {
                    if (Style.CURRENT_THEME == Style.DARK) {
                        _text_field.textColor = Style.TEXT.shade().value;
                    } else {
                        _text_field.textColor = Style.TEXT.tint().value;
                    }
                }
            } else {
                _text_field.textColor = Style.TEXT.value;
            }

            _text_field.text = _textfield_string;
            _text_field.height = _text_field.textHeight + 4;

            if (_showing_underline) {
                update_underline();
            } else {
                _text_field.width = _width_;
                _text_field.height = _height_;
            }

            on_draw_signal.dispatch();
        }

        override public function addChild(child:DisplayObject):DisplayObject {
            if (child is Icon) {
                DebugDaemon.write_error("please use leadingIcon property for adding an " + "icon to InputTextField!");
            }
            return super.addChild(child);
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

        public function add_suggestion():void {
        }

        // * private methods

        private function update_underline():void {
            _textfield_underline.graphics.clear();
            _textfield_underline.graphics.lineStyle(_textfield_underline_strength, Style.SECONDARY.value);

            if (!prefixed_icon) {
                _textfield_underline.graphics.lineTo(_text_field.width, 0);
            } else {
                _textfield_underline.graphics.lineTo(_text_field.width + _leading_icon.width, 0);
            }
            _textfield_underline.y = _text_field.height + 4;
            _width_ = _textfield_underline.width;
            _height_ = _textfield_underline.y + _textfield_underline.height;
        }

        private function show_suggestions():void {
            if (_input_cache == _text_field.text) {
                if (!_suggestion_list.parent) {
                    addChild(_suggestion_list);
                }
            } else {
                _suggestion_list.clear();
                _suggestion_cache = _suggestion_generator.generateSuggestions(_text_field.text, _suggestion_limit);

                if (!_suggestion_cache.length) {
                    if (_suggestion_list.parent) {
                        removeChild(_suggestion_list);
                    }
                    return;
                } else {
                    for (var i:uint = 0; i < _suggestion_cache.length; i++) {
                        var currentSuggestion:Suggestion = _suggestion_cache[i];
                        var item:ListItem = _suggestion_list.get_cached_item(currentSuggestion.linkageid);
                        if (item) {
                            _suggestion_list.add_item(item);
                        } else {
                            item = new ListItem(_suggestion_list, 0, 0, currentSuggestion.label);
                            item.linkage_id = currentSuggestion.linkageid;
                            item.label = currentSuggestion.label;
                            item.on_click.add(on_suggestion_select);
                        }
                    }
                }
            }
            _suggestion_list.y = _textfield_underline.y + 1;
            _suggestion_list.width = _width_;

        }

        // * getters & setters //

        public function get input_target():TextField {
            return _text_field;
        }

        public function get text():String {
            return _textfield_string;
        }

        public function set text(val:String):void {
            _is_hinting = false;
            _textfield_string = val;
            draw();
        }

        public function get hint_text():String {
            return _hint_text;
        }

        public function set hint_text(val:String):void {
            if (StringUtil.is_empty_or_null(val)) {
                _hint_text = "enter text";
                return;
            }
            _hint_text = val;
            show_hint_text();
        }

        public function get color():uint {
            return _text_field.textColor;
        }

        public function set color(val:uint):void {
            _text_field.textColor = val;
        }

        public function get prefixed_icon():Icon {
            return _leading_icon;
        }

        public function set prefixed_icon(icon:Icon):void {
            if (icon == null) {
                if (_leading_icon && _leading_icon.parent) {
                    super.removeChild(_leading_icon);
                    _leading_icon = null;
                    _text_field.x = 0;
                    update_underline();
                    return;
                }
            }
            _leading_icon = icon;
            _width_ = _width_ + _leading_icon.width;
            _leading_icon.y = _leading_icon.y + (PADDING / 2);
            _text_field.x = _leading_icon.width + PADDING;
            super.addChild(_leading_icon);
            update_underline();
        }

        public function get showing_suggestions():Boolean {
            return _showing_suggestions;
        }

        public function set showing_suggestions(val:Boolean):void {
            _showing_suggestions = _suggestions_available = val;

            if (val) {
                _suggestion_list ||= new List(this);
                _suggestion_list.width = _width_;
                _suggestion_limit = 5;
                _suggestion_iterator_index = 0;
                _input_engine.add_keyboard_delegate(on_key_press);
            } else {
                if (_suggestion_list != null) {
                    _suggestion_list.clear();
                    _suggestion_list.width = _width_;
                }
                _suggestion_limit = 0;
                _suggestion_iterator_index = 0;
                _input_engine.remove_keyboard_delegates(on_key_press);
            }
        }

        public function set suggestion_store(json:String):void {
            _suggestion_generator.loadFromJsonString(json);
        }

        public function get suggestion_limit():uint {
            return _suggestion_limit;
        }

        public function set suggestion_limit(val:uint):void {
            if (val < 1)
                _suggestion_limit = 1;
            else
                _suggestion_limit = val;
        }

        public function get showing_underline():Boolean {
            return _showing_underline;
        }

        public function set showing_underline(val:Boolean):void {
            if (!val) {
                _textfield_underline.graphics.clear();
                if (_textfield_underline.parent)
                    removeChild(_textfield_underline);
            }
            _showing_underline = val;
            draw();
        }

        public function set display_as_password(val:Boolean):void {
            _is_password_field = val;
        }

        public function set restrict(value:String):void {
            _text_field.restrict = value;
        }

        // * delegate functions

        private function on_suggestion_select(e:MouseEvent = null):void {
            var item:ListItem = (e.currentTarget as ListItem);
            _selected_suggestion = new Suggestion();
            _selected_suggestion.label = item.label;
            _selected_suggestion.data = (item.data as Suggestion).data;
            _text_field.text = _selected_suggestion.label;
            _text_field.setTextFormat(_text_field.defaultTextFormat);
            _input_cache = item.label;
            _typed_chars = item.label.length;

        }

        /*
           private function on_added(e:Event):void {
           _input_engine = new InputEngine(stage, true);
           draw();
           }
         */

        public function get on_text_update():NativeSignal {
            return _on_text_update;
        }

        private function on_key_press(e:KeyboardEvent):void {
            var pressedKey:uint = e.keyCode;
            var keyName:String = _input_engine.getKeyName(e.keyCode).toLowerCase();

            if (_input_engine.mod_is_down())
                return;

            // TODO (dyxribo, STARLIB-7): implement arrow navigation for suggestions
            if (pressedKey == _input_engine.keys.TAB) {
                e.preventDefault();
                return;
            } else if (pressedKey == _input_engine.keys.UP) {
                return;
            } else if (pressedKey == _input_engine.keys.DOWN) {
                return; // letter pressed                         number pressed                        numpad number
                    // pressed
            } else if ((pressedKey > 64 && pressedKey < 91) || (pressedKey > 47 && pressedKey < 58) || (pressedKey > 95 && pressedKey < 106)) {
                if (!_suggestion_list.parent)
                    show_suggestions();
            } else if (pressedKey == _input_engine.keys.BACKSPACE) {
                if (_text_field.text == '') {
                    _suggestion_list.hide_items();
                }
            }
        }

        private function onFocus(e:FocusEvent):void {
            _on_focus.remove(onFocus);
            _is_hinting = false;
            if (_text_field.text == _hint_text) {
                _text_field.text = "";
                if (_is_password_field) {
                    _text_field.displayAsPassword = true;
                }
            }

            if (_showing_underline) {
                _textfield_underline_strength = 2;
                update_underline();
            }

            if (_suggestions_available && _suggestion_cache && _suggestion_cache.length > 0) {
                if (!_suggestion_list.parent)
                    addChild(_suggestion_list);
                show_suggestions();
            }
            commit();
            _on_defocus.add(onDeFocus);
        }

        private function onDeFocus(e:FocusEvent):void {
            // TODO(dyxribo, STARLIB-9): Allow suggestion list to hide on InputTextField defocus
            _on_defocus.remove(onDeFocus);

            if (_text_field.text == "") {
                show_hint_text();
            }

            if (_showing_underline) {
                _textfield_underline_strength = 1;
                update_underline();
            }

            _on_focus.add(onFocus);
        }

        private function show_hint_text():void {
            if (_is_password_field) {
                _text_field.displayAsPassword = false;
            }
            _is_hinting = true;
            commit();
        }

        private function onTextChange(e:Event):void {
            if (_suggestions_available) {
                if (_text_field.text.length > 0) {
                    if (!_suggestion_list.parent)
                        addChild(_suggestion_list);
                    show_suggestions();
                } else if (_suggestion_list.parent) {
                    removeChild(_suggestion_list);
                }
            }
            _textfield_string = _text_field.text;
            commit();
            on_resize_signal.dispatch(_resizeEvent_);
        }

        override public function destroy():void {
            _on_focus.removeAll();
            _on_defocus.removeAll();
            _on_text_update.removeAll();
        }
    }

}

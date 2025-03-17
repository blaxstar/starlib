package net.blaxstar.starlib.components {

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.input.InputEngine;
    import net.blaxstar.starlib.math.Arithmetic;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.Style;
    import net.blaxstar.starlib.utils.Strings;

    import org.osflash.signals.natives.NativeSignal;

    /**
     * ...
     * @author Deron D. (decamp.deron@gmail.com)
     */
    public class InputTextField extends Component {
        // textfield
        private var _text_field:TextField;
        private var _textfield_underline:Shape;
        private var _textfield_background:Shape;
        private var _textfield_underline_strength:uint;
        private var _textfield_string:String;
        private var _text_format:TextFormat;
        private var _hint_text:String;
        private var _leading_icon:Icon;
        private var _is_hinting:Boolean;
        private var _showing_underline:Boolean;
        private var _has_leading_icon:Boolean;
        private var _is_password_field:Boolean;
        private var _is_focused:Boolean;
        // suggestions
        private var _input_engine:InputEngine;
        private var _suggestion_cache:Vector.<Suggestion>;
        private var _selected_suggestion:Suggestion;
        private var _suggestion_list:List;
        private var _suggestion_limit:uint;
        private var _suggestion_generator:Suggestitron;
        private var _suggestion_iterator_index:uint;
        private var _input_cache:Array;
        private var _showing_suggestions:Boolean;
        private var _initial_selection_made:Boolean;
        // signals
        private var _on_focus:NativeSignal;
        private var _on_defocus:NativeSignal;

        public function InputTextField(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, hint_text:String = "type something") {
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
            update_underline();
            update_background();
            setChildIndex(_textfield_background, 0);

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
                if (_is_password_field) {
                    _text_field.displayAsPassword = true;
                } else {
                    _text_field.displayAsPassword = _is_password_field;
                }
                // set the text
                _text_field.text = _textfield_string;
            }

            // set height, width is adjustable manually only
            _text_field.height = _text_field.textHeight + 4;
            // update the underline if applicable, just in case width changes
            if (_showing_underline) {
                update_underline();
            } else {
                _text_field.width = _width_;
                _text_field.height = _height_;
            }
            update_background();

            dispatchEvent(_resize_event_);
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

        public function add_suggestion(label:String, data:Object):void {
            if (_showing_suggestions && _suggestion_generator) {
                _suggestion_generator.add_suggestion_data(label, data);
            }
        }

        // ! PRIVATE FUNCTIONS ! //

        private function navigate_suggestions(key_code:int):void {
            // TODO: the initial downward navigation skips the first element when the counter is supposed to be reset. flipping the order of increment seems to give some weird results. 
            if (_suggestion_list.is_showing_items && _suggestion_cache.length > 0) {
                if (!_initial_selection_made) {
                    _suggestion_iterator_index = 0;
                    _initial_selection_made = true;
                } else {
                    if (key_code == _input_engine.keys.UP) {
                        // Decrement regardless of index, but handle potential underflow
                        _suggestion_iterator_index = Math.max(0, _suggestion_iterator_index - 1);
                    } else if (key_code == _input_engine.keys.DOWN) {
                        // Increment regardless of index, but handle potential overflow
                        _suggestion_iterator_index = Math.min(_suggestion_cache.length - 1, _suggestion_iterator_index + 1);
                    }
                }
                _suggestion_list.set_selection(_suggestion_iterator_index);
            }
        }

        private function update_background():void {
            _textfield_background.graphics.clear();
            _textfield_background.graphics.beginFill(Style.BACKGROUND.shade(0.8).value);
            _textfield_background.graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
            _textfield_background.graphics.endFill();
        }

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
            var input_prefix:String = _input_cache.join("");
            _suggestion_cache = _suggestion_generator.generate_suggestions_from_input(input_prefix, _suggestion_limit);

            var num_suggestions:int = _suggestion_cache.length;
            _suggestion_list.clear();
            if (_suggestion_list.has_cached_group(input_prefix)) {
                _suggestion_list.apply_cached_list(input_prefix);
            } else {
                for (var i:int = 0; i < num_suggestions; i++) {
                    var list_item:ListItem = new ListItem(null, 0, 0, _suggestion_cache[i].label);
                    list_item.data = _suggestion_cache[i].data;
                    list_item.on_click.add(on_suggestion_select);
                    _suggestion_list.add_item(list_item);
                }
            }

            _suggestion_list.move(_textfield_underline.x, _textfield_underline.y + 2);
            _suggestion_list.show_items();
            _height_ = Arithmetic.max(_height_, _suggestion_list.y + _suggestion_list.height);
        }

        private function apply_suggestion(list_item:ListItem):void {
            var suggestion:Suggestion = list_item.data as Suggestion;
            _selected_suggestion = new Suggestion();
            _selected_suggestion.label = list_item.label;
            _selected_suggestion.data = (suggestion && suggestion.data) ? suggestion.data : null;
            _text_field.setTextFormat(_text_field.defaultTextFormat);
            text = _selected_suggestion.label;
            _text_field.setSelection(_text_field.text.length, _text_field.text.length);
            _suggestion_list.hide_items();
            _initial_selection_made = false;
        }

        // ! DELEGATE FUNCTIONS !//

        private function on_suggestion_select(e:MouseEvent):void {
            var list_item:ListItem = (e.currentTarget as ListItem);
            apply_suggestion(list_item);
        }

        private function on_text_input(e:TextEvent):void {
            if (_suggestion_list.num_items > 0) {
                _suggestion_list.cache_current_list(_input_cache.join(""));
            }
            if (Strings.is_empty_or_null(e.text)) {
                return;
            }
            _input_cache.push(e.text);
            show_suggestions();
        }

        private function on_key_down(e:KeyboardEvent):void {
            if (!_suggestion_list.is_showing_items && _is_focused || !_is_focused) {
                return;
            }
            var pressed_key:uint = e.keyCode;
            if (pressed_key == _input_engine.keys.ENTER) {
                if (_suggestion_list.selected_item.is_glowing) {
                    apply_suggestion(_suggestion_list.selected_item);
                    _input_cache.length = 0;
                }
            } else if (pressed_key == _input_engine.keys.TAB) {
                e.preventDefault();
            } else if (pressed_key == _input_engine.keys.UP || pressed_key == _input_engine.keys.DOWN) {
                navigate_suggestions(pressed_key);
            } else if (pressed_key == _input_engine.keys.BACKSPACE) {
                // if backspace key is pressed and the textfield is empty...
                _input_cache.pop();
                _suggestion_list.hide_items();
                _initial_selection_made = false;


                if (_input_cache.length != 0) {
                    show_suggestions();
                } else {
                    draw();
                }
            }
        }

        private function on_focus(e:FocusEvent):void {
            _on_focus.remove(on_focus);
            _is_focused = true;
            if (_is_hinting) {
                _is_hinting = false;
                _text_field.textColor = Style.TEXT.value;
                _textfield_string = "";
                _text_field.text = "";
            } else {
                _text_field.setSelection(0, _text_field.text.length);
            }

            if (_showing_suggestions) {
                _text_field.addEventListener(TextEvent.TEXT_INPUT, on_text_input);
                _input_engine.add_keyboard_listener(on_key_down, InputEngine.KEYDOWN);
            }

            if (_showing_underline) {
                _textfield_underline_strength = 2;
                update_underline();
            }
            update_background();

            if (_input_cache && _input_cache.length > 0 && _suggestion_cache && _suggestion_cache.length > 0) {
                show_suggestions();
            }

            _on_defocus.add(on_defocus);
        }

        private function on_defocus(e:FocusEvent):void {
            _on_defocus.remove(on_defocus);
            _is_focused = false;

            if (_showing_suggestions) {
                if (_text_field.hasEventListener(TextEvent.TEXT_INPUT)) {
                    _text_field.removeEventListener(TextEvent.TEXT_INPUT, on_text_input);
                    _input_engine.remove_keyboard_listeners(on_key_down);
                }
                _suggestion_list.hide_items();
                _initial_selection_made = false;
            }

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
            if (_is_password_field) {
                _text_field.displayAsPassword = false;
            }
            _text_field.text = _hint_text;
            _is_hinting = true;
            commit();
        }

        // ! GETTERS & SETTERS ! //

        public function get input_target():TextField {
            return _text_field;
        }

        public function get text():String {
            if (_is_hinting) {
                _textfield_string = "";
                return _textfield_string;
            }

            _textfield_string = _text_field.text;
            return _textfield_string;
        }

        public function set text(val:String):void {
            if (val != "") {
                _is_hinting = false;
            } else {
                _is_hinting = true;
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
                    update_background();
                    return;
                }
            }
            _leading_icon = icon;
            _width_ = _width_ + _leading_icon.width;
            _leading_icon.y = _leading_icon.y + (PADDING / 2);
            _text_field.x = _leading_icon.width + PADDING;
            super.addChild(_leading_icon);
            update_underline();
            update_background();
        }

        public function get showing_suggestions():Boolean {
            return _showing_suggestions;
        }

        /**
         *
         * @param val
         */
        public function set showing_suggestions(val:Boolean):void {
            _showing_suggestions = val;
            _suggestion_iterator_index = 0;


            if (val) {
                _suggestion_list ||= new List(this);
                _suggestion_list.width = _width_;
                _suggestion_limit = 5;
                _input_cache = [];

                if (!_input_engine) {
                    _input_engine = InputEngine.instance();
                }
                _text_field.addEventListener(TextEvent.TEXT_INPUT, on_text_input);
                _input_engine.add_keyboard_listener(on_key_down, InputEngine.KEYDOWN);
            } else {
                if (_suggestion_list != null) {
                    _suggestion_list.clear();
                    _suggestion_list.width = _width_;
                }
                    //_input_engine.remove_keyboard_delegates(on_text_input);
            }
        }

        public function set suggestion_store(json:String):void {
            if (!_suggestion_generator) {
                _suggestion_generator = new Suggestitron();
            }
            _suggestion_generator.parse_json_string(json);
        }

        public function get suggestion_limit():uint {
            return _suggestion_limit;
        }

        public function set suggestion_limit(val:uint):void {
            if (val < 1) {
                _suggestion_limit = 1;
            } else {
                _suggestion_limit = val;
            }
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

        public function get display_as_password():Boolean {
            return _is_password_field;
        }

        public function set display_as_password(val:Boolean):void {
            _is_password_field = val;
            commit();
        }

        public function set restrict(value:String):void {
            _text_field.restrict = value;
        }

        // ! GARBAGE COLLECTION ! //
        override public function destroy():void {
            _on_focus.removeAll();
            _on_defocus.removeAll();
        }
    }

}

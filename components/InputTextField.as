package net.blaxstar.components {

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

  import net.blaxstar.input.InputEngine;
  import net.blaxstar.style.Font;
  import net.blaxstar.style.Style;


import thirdparty.org.osflash.signals.natives.NativeSignal;
import debug.DebugDaemon;

  /**
   * ...
   * @author Deron D. (decamp.deron@gmail.com)
   */
  public class InputTextField extends Component {

    private var _textField:TextField;
    private var _textFieldUnderline:Shape;
    private var _textFieldUnderlineStrength:uint;
    private var _textFieldString:String;
    private var _textFormat:TextFormat;
    private var _hintText:String;
    private var _showingUnderline:Boolean;
    private var _showingSuggestions:Boolean;
    private var _hasLeadingIcon:Boolean;
    private var _leadingIcon:Icon;
    private var _suggestionList:List;
    private var _suggestionLimit:uint;
    private var _suggestionGenerator:Suggestitron;
    private var _suggestionIteratorIndex:uint;
    private var _inputCache:String;
    private var _suggestionCache:Vector.<Suggestion>;
    private var _selectedSuggestion:Suggestion;
    private var _suggestionsAvailable:Boolean;
    private var _is_password_field:Boolean;

    private var _input_engine:InputEngine;
    private var _onFocus:NativeSignal;
    private var _onDeFocus:NativeSignal;
    private var _onTextChange:NativeSignal;
    private var _typedChars:uint;

    // TODO (dyxribo, STARCOMPS-3): add icon support to InputTextField
    public function InputTextField(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, hintText:String = "") {
      _hintText = _textFieldString = hintText;
      super(parent, xpos, ypos);
    }

    // public

    override public function init():void {
      _textFormat = Font.BODY_2;
      _textFormat.color = Style.TEXT.value;
      _showingUnderline = true;
      super.init();
    }

    override public function addChildren():void {
      _textField = new TextField();
      _textField.type = TextFieldType.INPUT;
      _textField.autoSize = TextFieldAutoSize.NONE;
      _textField.defaultTextFormat = _textFormat;
      _textField.embedFonts = true;
      _textField.antiAliasType = AntiAliasType.ADVANCED;
      _textField.gridFitType = GridFitType.SUBPIXEL;
      _textField.selectable = true;
      _textField.sharpness = 300;
      _textField.border = false;
      _textField.background = false;
      _textField.width = 200;
      _textField.text = _textFieldString;
      _textField.setTextFormat(_textFormat);
      addChild(_textField);

      if (_showingUnderline) {
        _textFieldUnderline = new Shape();
        _textFieldUnderlineStrength = 1;
        addChild(_textFieldUnderline);
        updateUnderline();
      }

      _onFocus = new NativeSignal(_textField, FocusEvent.FOCUS_IN, FocusEvent);
      _onDeFocus = new NativeSignal(_textField, FocusEvent.FOCUS_OUT, FocusEvent);

      // TODO (dyxribo, STARCOMPS-11): use keydown listeners in favor of change event in InputTextField
      _onTextChange = new NativeSignal(_textField, Event.CHANGE, Event);
      _onFocus.add(onFocus);
      _onTextChange.add(onTextChange);

      super.addChildren();

    }

    override protected function on_added(e:Event):void {
      _input_engine = new InputEngine(stage, true);
      draw();
    }

    override public function draw(e:Event = null):void {
      if (_textField.text == _hintText || _textField.text.length < 1) {
        if (Style.CURRENT_THEME == Style.DARK) {
          _textField.textColor = Style.TEXT.shade().value;
        } else {
          _textField.textColor = Style.TEXT.tint().value;
        }
      } else {
        _textField.textColor = Style.TEXT.value;
      }
      _textField.text = _textFieldString;
      _textField.height = _textField.textHeight + 4;
      if (_showingUnderline) {
        updateUnderline();
      } else {
        _width_ = _textField.width;
        _height_ = _textField.height;
      }
      onDraw.dispatch();
    }

    override public function addChild(child:DisplayObject):DisplayObject {
      if (child is Icon) {
        DebugDaemon.write_log("please use leadingIcon property for adding an " +
        "icon to InputTextField!", DebugDaemon.ERROR_MISUSE);
      }
      return super.addChild(child);
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

    // private

    private function updateUnderline():void {
      _textFieldUnderline.graphics.clear();
      _textFieldUnderline.graphics.lineStyle(_textFieldUnderlineStrength, Style.SECONDARY.value);

      if (!leadingIcon) {
        _textFieldUnderline.graphics.lineTo(_textField.width, 0);
      }
      else {
        _textFieldUnderline.graphics.lineTo(_textField.width + _leadingIcon.width, 0);
      }
      _textFieldUnderline.y = _textField.height + 4;
      _width_ = _textFieldUnderline.width;
      _height_ = _textFieldUnderline.y + _textFieldUnderline.height;
    }

    private function showSuggestions():void {
      if (_inputCache == _textField.text) {
        if (!_suggestionList.parent)
          addChild(_suggestionList);
      }
      else {
        _suggestionList.clear();
        _suggestionCache = _suggestionGenerator.generateSuggestions(_textField.text, _suggestionLimit);

        if (!_suggestionCache.length) {
          if (_suggestionList.parent)
            removeChild(_suggestionList);
          return;
        }
        else {
          for (var i:uint = 0; i < _suggestionCache.length; i++) {
            var currentSuggestion:Suggestion = _suggestionCache[i];
            var item:ListItem = _suggestionList.getCachedItemByID(currentSuggestion.linkageid);
            if (item) {
              _suggestionList.addItem(item);
            }
            else {
              item = new ListItem(_suggestionList, 0, 0, currentSuggestion.label);
              item.linkageid = currentSuggestion.linkageid;
              item.label = currentSuggestion.label;
              item.onClick.add(onSuggestionSelect);
            }
          }
        }
      }
      _suggestionList.y = _textFieldUnderline.y + 1;
      _suggestionList.width = _width_;

    }

    private function onSuggestionSelect(e:MouseEvent = null):void {
      var item:ListItem = (e.currentTarget as ListItem);
      _selectedSuggestion = new Suggestion();
      _selectedSuggestion.label = item.label;
      _selectedSuggestion.data = (item.data as Suggestion).data;
      _textField.text = _selectedSuggestion.label;
      _textField.setTextFormat(_textField.defaultTextFormat);
      _inputCache = item.label;
      _typedChars = item.label.length;

    }

    // getters/setters

    public function get text():String {
      return _textFieldString;
    }

    public function set text(val:String):void {
      _textFieldString = val;
      draw();
    }

    public function get color():uint {
      return _textField.textColor;
    }

    public function set color(val:uint):void {
      _textField.textColor = val;
    }

    public function get leadingIcon():Icon {
      return _leadingIcon;
    }

    public function set leadingIcon(icon:Icon):void {
      if (icon == null) {
        if (_leadingIcon && _leadingIcon.parent) {
          super.removeChild(_leadingIcon);
          _leadingIcon = null;
          _textField.x = 0;
          updateUnderline();
          return;
        }
      }
      _leadingIcon = icon;
      _width_ = _width_ + _leadingIcon.width;
      _leadingIcon.y = _leadingIcon.y + (PADDING / 2);
      _textField.x = _leadingIcon.width + PADDING;
      super.addChild(_leadingIcon);
      updateUnderline();
    }

    public function get showingSuggestions():Boolean {
      return _showingSuggestions;
    }

    public function set showingSuggestions(val:Boolean):void {
      _showingSuggestions = _suggestionsAvailable = val;

      if (val) {
        _suggestionList ||= new List(this);
        _suggestionList.width = _width_;
        _suggestionLimit = 5;
        _suggestionIteratorIndex = 0;
        _input_engine.addKeyboardDelegate(onKeyPress);
      }
      else {
        if (_suggestionList != null) {
          _suggestionList.clear();
          _suggestionList.width = _width_;
        }
        _suggestionLimit = 0;
        _suggestionIteratorIndex = 0;
        _input_engine.removeKeyboardDelegates(onKeyPress);
      }

    }

    public function set suggestionStore(json:String):void {
      _suggestionGenerator.loadFromJsonString(json);
    }

    public function get suggestionLimit():uint {
      return _suggestionLimit;
    }

    public function set suggestionLimit(val:uint):void {
      if (val < 1)
        _suggestionLimit = 1;
      else
        _suggestionLimit = val;
    }

    public function get showingUnderline():Boolean {
      return _showingUnderline;
    }

    public function set showingUnderline(val:Boolean):void {
      if (!val) {
        _textFieldUnderline.graphics.clear();
        if (_textFieldUnderline.parent)
          removeChild(_textFieldUnderline);
      }
      _showingUnderline = val;
      draw();
    }

    public function set display_as_password(val:Boolean):void {
      _is_password_field = val;
    }
    // delegate functions

    private function onKeyPress(e:KeyboardEvent):void {
      var pressedKey:uint = e.keyCode;
      var keyName:String = _input_engine.getKeyName(e.keyCode).toLowerCase();

      if (_input_engine.modIsDown())
        return;

      // TODO (dyxribo, STARLIB-7): implement arrow navigation for suggestions
      if (pressedKey == _input_engine.keys.TAB) {
        e.preventDefault();
        return;
      }
      else if (pressedKey == _input_engine.keys.UP) {
        return;
      }
      else if (pressedKey == _input_engine.keys.DOWN) {
        return; // letter pressed                         number pressed                        numpad number
        // pressed
      }
      else if ((pressedKey > 64 && pressedKey < 91) || (pressedKey > 47 && pressedKey < 58) || (pressedKey > 95 && pressedKey < 106)) {
        if (!_suggestionList.parent)
          showSuggestions();
      }
      else if (pressedKey == _input_engine.keys.BACKSPACE) {
        if (_textField.text == '') {
          _suggestionList.hideList();
        }
      }
    }

    private function onFocus(e:FocusEvent):void {
      _onFocus.remove(onFocus);
      _textField.textColor = Style.TEXT.value;
      if (_textField.text == _hintText) {
        _textField.text = "";
        if (_is_password_field) {
          _textField.displayAsPassword = true;
        }
      }

      if (_showingUnderline) {
        _textFieldUnderlineStrength = 2;
        updateUnderline();
      }

      if (_suggestionsAvailable && _suggestionCache && _suggestionCache.length > 0) {
        if (!_suggestionList.parent)
          addChild(_suggestionList);
        showSuggestions();
      }

      _onDeFocus.add(onDeFocus);
    }

    private function onDeFocus(e:FocusEvent):void {
      // TODO(dyxribo, STARLIB-9): Allow suggestion list to hide on InputTextField defocus
      _onDeFocus.remove(onDeFocus);

      if (_textField.text == "") {
        showHintText();
      }

      if (_showingUnderline) {
        _textFieldUnderlineStrength = 1;
        updateUnderline();
      }

      _onFocus.add(onFocus);
    }

    private function showHintText():void {
      if (Style.CURRENT_THEME == Style.DARK)
        _textField.textColor = Style.TEXT.shade().value;

      else
        _textField.textColor = Style.TEXT.tint().value;
      _textField.text = _hintText;

      if (_is_password_field) {
        _textField.displayAsPassword = false;
      }
    }

    private function onTextChange(e:Event):void {
      if (_suggestionsAvailable) {
        if (_textField.text.length > 0) {
          if (!_suggestionList.parent)
            addChild(_suggestionList);
          showSuggestions();
        }
        else if (_suggestionList.parent) {
          removeChild(_suggestionList);
        }
      }
      _textFieldString = _textField.text;
      commit();
      onResize.dispatch(_resizeEvent_);
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);
      _onFocus.removeAll();
      _onDeFocus.removeAll();
      _onTextChange.removeAll();
    }
  }

}

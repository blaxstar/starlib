package net.blaxstar.starlib.debug.terminal {
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.debug.terminal.commands.ArithmeticAddCommand;
    import net.blaxstar.starlib.debug.terminal.commands.ArithmeticSubCommand;
    import net.blaxstar.starlib.debug.terminal.commands.EvalObjectCommand;
    import net.blaxstar.starlib.debug.terminal.commands.GrepCommand;
    import net.blaxstar.starlib.debug.terminal.commands.ManualCommand;
    import net.blaxstar.starlib.debug.terminal.commands.Manuals;
    import net.blaxstar.starlib.debug.terminal.commands.PrintCommand;
    import net.blaxstar.starlib.debug.terminal.commands.TerminalCommand;
    import net.blaxstar.starlib.input.InputEngine;
    import net.blaxstar.starlib.style.Color;
    import net.blaxstar.starlib.utils.Strings;

    import thirdparty.org.osflash.signals.Signal;

    public class Termini extends Sprite {
        static private const _ON_DICTIONARY_INIT:Signal = new Signal();

        static private var _data:Dictionary;
        private const _save_file:File = File.applicationStorageDirectory.resolvePath("debugconsole.dat");
        private var _filestream:FileStream;
        private var _input_engine:InputEngine;
        private var _input_field:InputTextField;
        private var _output_field:PlainText;
        private var _prefix_text:PlainText;
        private var _command_history_length:Number;
        private var _current_history_index:int;
        private var _temp_history_save:String;
        private var _is_showing:Boolean;
        private var _manpage_scaled:Boolean;
        private var _navigating_history:Boolean;
        private var _pipeline:Pipe;
        private var _background_color:uint;
        private var _border_color:uint;

        /**
         * 
         * @param open_key the key used to show the console. the default is tilde (~).
         */
        public function Termini() {
            _input_engine = InputEngine.instance();
            init();
            addEventListener(Event.ADDED_TO_STAGE, on_added_to_stage);
        }

        // ! PUBLIC ! //

        public function add_command(com:TerminalCommand):void {

            if (!command_dictionary) {
                _data.command_dictionary = new Dictionary();
            }

            command_dictionary[com.name] = com;
        }

        public function add_input_to_history(command:String):void {
            var trimmedCommand:String = Strings.trim(command);
            var commandIndex:int = command_history.indexOf(trimmedCommand);

            if (_navigating_history && _command_history_length) {
                command_history.removeAt(_current_history_index);
            }

            if (command_history.length > history_max) {
                command_history.shift();
            }

            _data.command_history.push(trimmedCommand);
            _command_history_length = command_history.length;

            write_save();
        }

        public function toggle_console():void {

            if (visible) {
                hide_console();
            } else {
                show_console();
            }
        }

        public function show_console():void {

            if (!visible) {
                visible = true;
                stage.stageFocusRect = false;
                stage.focus = _input_field.input_target;
                parent.setChildIndex(this, parent.numChildren-1);
                _output_field.text = "";
                _manpage_scaled = false;
                draw_background();
                _input_engine.add_keyboard_listener(on_key_press_in_console, InputEngine.KEYDOWN);
            }
        }

        public function hide_console():void {

            if (visible) {
                visible = false;
                _input_engine.remove_keyboard_listeners(on_key_press_in_console);
                reset_history_navigation();
            }
        }

        public function clear_console():void {
            _input_field.text = "";
        }

        public function load_save():void {
            _filestream.open(_save_file, FileMode.READ);
            _data = _filestream.readObject();
            _filestream.close();

            _command_history_length = command_history.length;
            _ON_DICTIONARY_INIT.dispatch();
        }

        public function write_save(update:Boolean = false):void {

            _filestream.open(_save_file, FileMode.WRITE);
            _filestream.writeObject(_data);
            _filestream.close();

            load_save();
        }

        public function clear_save():void {

            for (var key:String in _data) {
                delete _data[key];
            }

            create_save();
        }

        // ! PRIVATE ! //
        private function init():void {
            _background_color = Color.DARK_GREY.value;
            _border_color = Color.DARK_GREY.shade().value;
            _filestream = new FileStream();
            _data = new Dictionary();
            init_default_commands();
            _pipeline = new Pipe(command_dictionary);

            _temp_history_save = "";
            _current_history_index = -1;
            _command_history_length = 0;
            _navigating_history = false;
            _is_showing = false;
            open_key = _input_engine.keys.TILDE;

            init_text_fields();
            check_save();
            hide_console();
        }

        private function check_save():void {

            if (save_exists) {
                load_save();
            } else {
                create_save();
            }
        }

        private function init_text_fields():void {
            _prefix_text = new PlainText(this, 0, 0, 'debug | ');
            _prefix_text.color = Color.PRODUCT_RED.value;
            _output_field = new PlainText(this, 0, 0);
            _output_field.color = Color.PRODUCT_GREEN.value;
            _output_field.multiline = true;
            _input_field = new InputTextField(this, _prefix_text.x + _prefix_text.text_width, 0, '');
            _input_field.color = Color.EGGSHELL.value;
            _input_field.showing_underline = false;
            _input_field.addEventListener(Event.CHANGE, on_text_field_change);
        }

        private function init_default_commands():void {
            var printcom:TerminalCommand = new PrintCommand();
            var addcom:TerminalCommand = new ArithmeticAddCommand();
            var subcom:TerminalCommand = new ArithmeticSubCommand();
            var grepcom:TerminalCommand = new GrepCommand();
            var evalcom:TerminalCommand = new EvalObjectCommand();
            var clhscom:TerminalCommand = new TerminalCommand('clearhs', clear_history);
            var mancom:TerminalCommand = new ManualCommand();

            add_command(printcom);
            add_command(addcom);
            add_command(subcom);
            add_command(grepcom);
            add_command(evalcom);
            add_command(clhscom);
            add_command(mancom);

            EvalObjectCommand.register_object("terminal", this);
            ManualCommand.register_manual("print", Manuals.print);
            ManualCommand.register_manual("add", Manuals.add);
            ManualCommand.register_manual("sub", Manuals.sub);
            ManualCommand.register_manual("grep", Manuals.grep);
            ManualCommand.register_manual("eval", Manuals.eval);
            ManualCommand.register_manual("clearhs", Manuals.clhs);
            ManualCommand.on_access.add(on_manpage);
        }

        private function create_save():void {
            _data = new Dictionary();
            command_history = [];
            history_max = 126;
            auto_hide = true;
            execute_key = _input_engine.keys.ENTER;
            prev_history_key = _input_engine.keys.UP;
            next_history_key = _input_engine.keys.DOWN;

            write_save();
        }

        private function clear_history():String {
            _current_history_index = -1;
            _command_history_length = 0;
            command_history = [];
            write_save();
            return "history cleared.";
        }

        private function print_to_console(... rest):void {
            var outString:String = "";

            if (rest[0] is Array) {
                rest = rest[0];
            }

            for (var i:uint = 0; i < rest.length; i++) {
                outString += rest[i];
            }

            _output_field.text = outString;
        }

        private function reset_history_navigation():void {
            _current_history_index = -1;
            _navigating_history = false;
            clear_console();
            _temp_history_save = "";
        }

        private function draw_background():void {
          var g:Graphics = this.graphics;
          g.clear();
          g.beginFill(_background_color, 0.8);
          g.lineStyle(2, _border_color);
          g.drawRect(0, 0, stage.stageWidth, (_manpage_scaled) ? (stage.stageHeight) : 60);
          g.endFill();
          _manpage_scaled = false;
        }

        // ! GETTERS & SETTERS ! //

        public function get previous_command():String {

            if (_current_history_index < 0) {
                _current_history_index = _command_history_length - 1;
                return current_command;
            }

            _current_history_index--;
            return current_command;
        }

        public function get next_command():String {

            if (_current_history_index >= _command_history_length - 1) {
                _current_history_index = -1;
                _navigating_history = false;
                return current_command;
            }

            _current_history_index++;
            return current_command;
        }

        public function get current_command():String {

            if (_current_history_index >= 0 && _current_history_index < _command_history_length) {
                return command_history[_current_history_index];
            }

            return _temp_history_save;
        }

        public function get command_dictionary():Dictionary {
            return _data.command_dictionary as Dictionary;
        }

        public function get command_history():Array {
            return _data.command_history;
        }

        public function set command_history(val:Array):void {
            _data.command_history = val;
        }

        public function get history_max():uint {
            return _data.history_max;
        }

        public function set history_max(val:uint):void {
            _data.history_max = val;
        }

        public function get auto_hide():Boolean {
          return _data.auto_hide;
        }

        public function set auto_hide(value:Boolean):void {
          _data.auto_hide = value;

          if (value) {
            _input_field.addEventListener(FocusEvent.FOCUS_OUT, on_console_focus_out);
          } else {
            _input_field.removeEventListener(FocusEvent.FOCUS_OUT, on_console_focus_out);
          }
        }

        public function get open_key():uint {
            if (!_data.hasOwnProperty("open_key") || _data.open_key == null) {
              return InputEngine.instance().keys.TILDE;
            }
            return _data.open_key;
        }

        public function set open_key(val:uint):void {
            _data.open_key = val;
        }

        public function get execute_key():uint {
            return _data.execute_key;
        }

        public function set execute_key(val:uint):void {
            _data.execute_key = val;
        }

        public function get prev_history_key():uint {
            return _data.prev_history_key;
        }

        public function set prev_history_key(val:uint):void {
            _data.prev_history_key = val;
        }

        public function get next_history_key():uint {
            return _data.next_history_key;
        }

        public function set next_history_key(val:uint):void {
            _data.next_history_key = val;
        }

        public function get save_exists():Boolean {
            return _save_file.exists;
        }

        // ! DELEGATE FUNCTIONS ! //

        private function on_key_press_in_console(e:KeyboardEvent):void {
            if (e.keyCode == execute_key) {

                if (_input_field.text.replace(" ", "") == "") {
                    return;
                }

                add_input_to_history(_input_field.text);
                _pipeline.parse_commands_from_string(_input_field.text);
                print_to_console(_pipeline.run());
                reset_history_navigation();
                draw_background();

            } else if (e.keyCode == prev_history_key) {

                if (_current_history_index == 0) {
                    return;
                }
                var text_length:uint = _input_field.text.length;
                _navigating_history = true;
                _input_field.text = previous_command;
                _input_field.input_target.setSelection(text_length, text_length);

            } else if (e.keyCode == next_history_key) {

                if (_current_history_index == -1) {
                    _navigating_history = false;
                    return;

                }
                text_length = _input_field.text.length;
                _navigating_history = true;
                _input_field.text = next_command;
                _input_field.input_target.setSelection(text_length, text_length);
            }
        }

        private function on_added_to_stage(event:Event):void {
            draw_background();

            _input_field.width = _output_field.width = (stage.stageWidth - (Component.PADDING * 2));
            _output_field.move(10, _input_field.height);
            _input_engine.add_keyboard_listener(on_toggle_key_press, InputEngine.KEYDOWN);
        }

        private function on_console_focus_out(event:FocusEvent):void {
            hide_console();
        }

        private function on_toggle_key_press(e:KeyboardEvent):void {
            if (open_key == e.keyCode) {

                if (!visible) {
                    e.preventDefault();
                }

                toggle_console();
            }
        }

        private function on_text_field_change(e:Event):void {
            if (!_navigating_history) {
                _temp_history_save = _input_field.text;
            }
            
        }

        private function on_manpage():void {
          _manpage_scaled = true;
        }
    }
}

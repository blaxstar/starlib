package net.blaxstar.starlib.debug.console {
    import flash.utils.Dictionary;
    import net.blaxstar.starlib.debug.console.commands.ConsoleCommand;

    /**
     * TODO: class documentation
     * @author Deron Decamp (decamp.deron@gmail.com)
     */
    public class Pipe extends Object {
        static private const COMMAND:RegExp = /(^[ ]*[a-zA-Z.0-9]+)/;
        static private const SWITCHES:RegExp = /([-0-9+.]+[0-9+])|([+0-9+])|(-[a-zA-Z]+)|(\|[a-zA-Z]+)|(?<!\|)(?<=\s)[^\s|]+/g;
        static private const PIPES:RegExp = /\|/g;

        private var _commands:Array;
        private var _command_objects:Vector.<ConsoleCommand>;
        private var _result:*;
        private var _command_dictionary:Dictionary;

        public function Pipe(dictionary:Dictionary) {
            _command_dictionary = dictionary;
        }

        public function parse_commands_from_string(pipelineString:String):void {
            _commands = pipelineString.split(PIPES);
            _command_objects = new Vector.<ConsoleCommand>();

            for (var i:int = 0; i < _commands.length; i++) {
                var current_pipeline:String = _commands[i];
                var cmd:String = current_pipeline.match(COMMAND)[0].replace(" ", "");
                var args:Array = current_pipeline.match(SWITCHES);

                var current_command:ConsoleCommand = _command_dictionary[cmd];

                if (current_command != null) {
                    _command_objects.push(current_command);

                    if (current_command.argument_array.length) {
                        if (args.length) {
                            current_command.push_args(args);
                        }
                    } else {
                        if (args.length) {
                            current_command.set_args(args);
                        }
                    }
                } else {
                    trace("Invalid command: " + cmd);
                }
            }

        }

        public function run():* {
            if (!_command_objects)
                return;
            if (_command_objects.length > 1) {
                for (var i:uint = 1; i < _command_objects.length; i++) {
                    _result = connect(_command_objects[i - 1], _command_objects[i]);
                }
                return _result;
            } else if (_command_objects.length > 0) {
                return _command_objects[0].execute();
            }
        }

        static private function connect(prev_command:ConsoleCommand, next_command:ConsoleCommand):* {
            var com1_out:* = prev_command.execute();
            var all_args:Array = [];

            all_args = next_command.argument_array;
            all_args.push(com1_out);

            return next_command.execute();
        }

        public function get result():* {
            return (result == undefined || result == null) ? run() : _result;
        }
    }

}

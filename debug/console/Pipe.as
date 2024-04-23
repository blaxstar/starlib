package net.blaxstar.starlib.debug.console {
    import flash.utils.Dictionary;
    import net.blaxstar.starlib.debug.console.commands.ConsoleCommand;
    import flash.utils.getDefinitionByName;

    /**
     * TODO: class documentation
     * @author Deron Decamp (decamp.deron@gmail.com)
     */
    public class Pipe extends Object {
        static private const COMMAND:RegExp = /(^[ ]*[a-zA-Z.0-9]+)/;
        static private const SWITCHES:RegExp = /([-0-9+.]+[0-9+])|([+0-9+])|(-[a-zA-Z]+)|(\|[a-zA-Z]+)|(?<!\|)(?<!^)\s(?<=\s)[^\s|]+/g;
        static private const PIPES:RegExp = /\|/g;

        private var _commands:Array;
        private var _command_objects:Vector.<ConsoleCommand>;
        private var _result:*;
        private var _command_dictionary:Dictionary;

        public function Pipe(dictionary:Dictionary) {
            _command_dictionary = dictionary;
        }

        /**
         * Parses console commands from a string and pipes the results together if possible.
         * @param pipeline_string string containing one or more console commands (piped together with the pipe character (`|`)).
         */
        public function parse_commands_from_string(command_string:String):void {
            // first, we attempt to split the command string by pipe characters that may be present, and init a vector for holding any matching commands we parse from the string
            _commands = command_string.split(PIPES);
            _command_objects = new Vector.<ConsoleCommand>();
            // next we loop through the array of pipe-seperated commands
            for (var i:int = 0; i < _commands.length; i++) {
                var current_pipe_section:String = _commands[i];
                var command_format_matches:Array = current_pipe_section.match(COMMAND);
                // if the current pipe command doesnt match the expected format, then skip it
                if (!command_format_matches) {
                    continue;
                }
                // if it does then we can parse the command string and arg strings seperately
                var current_command_name:String = current_pipe_section.match(COMMAND)[0];
                var current_command_arguments:Array = current_pipe_section.match(SWITCHES);
                // and then find the command within the command dictionary
                var current_command:ConsoleCommand = _command_dictionary[current_command_name] || _command_dictionary[current_command_name.toLowerCase()];
                // if we can find it, then we can simply set or push the arguments depending if args were already set manually
                if (current_command != null) {
                    _command_objects.push(current_command);

                    if (current_command_arguments && current_command_arguments.length) {
                        if (current_command.argument_array.length) {
                            current_command.push_args(current_command_arguments);
                        } else {
                            current_command.set_args(current_command_arguments);
                        }
                    }
                } else {
                  // otherwise, the command is not valid, we can skip it
                    trace("Invalid command: " + current_command_name);
                }
            }

        }
        /**
         * Executes the parsed command(s) along with any arguments, and returns the final result after piping them together.
         */
        public function run():* {
            if (!_command_objects) {
                return;
            }

            if (_command_objects.length > 1) {
                for (var i:uint = 1; i < _command_objects.length; i++) {
                    _result = connect(_command_objects[i - 1], _command_objects[i]);
                }
                return _result;
            } else if (_command_objects.length > 0) {
                return _command_objects[0].execute();
            }
        }

        static private function connect(command_0:ConsoleCommand, command_1:ConsoleCommand):* {
            var command_0_output:* = command_0.execute();
            var piped_arguments:Array = [];

            piped_arguments = command_1.argument_array;
            piped_arguments.push(command_0_output);

            return command_1.execute();
        }

        public function get result():* {
            return (result == undefined || result == null) ? run() : _result;
        }
    }

}

package net.blaxstar.starlib.debug.terminal {
    import flash.utils.Dictionary;
    import net.blaxstar.starlib.debug.terminal.commands.TerminalCommand;
    import flash.utils.getDefinitionByName;
    import net.blaxstar.starlib.utils.Strings;

    /**
     * TODO: class documentation
     * @author Deron Decamp (decamp.deron@gmail.com)
     */
    public class Pipe extends Object {
        static private const COMMAND:RegExp = /(^[ ]*[a-zA-Z.0-9]+)/;
        static private const SWITCHES:RegExp = /([-0-9+.]+[0-9+])|([+0-9+])|(-[a-zA-Z]+)|(\|[a-zA-Z]+)|(?<!\|)(?<!^)\s(?<=\s)[^\s|]+/g;
        static private const PIPES:RegExp = /\|/g;

        private var _commands:Array;
        private var _command_objects:Vector.<TerminalCommand>;
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
            _command_objects = new Vector.<TerminalCommand>();
            // next we loop through the array of pipe-seperated commands
            for (var i:int = 0; i < _commands.length; i++) {
                var current_pipe_section:String = Strings.trim(_commands[i]);
                var command_format_matches:Array = current_pipe_section.match(COMMAND);
                // if the current pipe command doesnt match the expected format, then skip it
                if (!command_format_matches) {
                    continue;
                }
                // if it does then we can parse the command string and arg strings seperately
                var current_command_name:String = Strings.trim(current_pipe_section.match(COMMAND)[0]);
                var current_command_arguments:Array = current_pipe_section.match(SWITCHES);
                current_command_arguments.forEach(function(item:String, index:int, array:Array):void {
                  current_command_arguments[index] = Strings.trim(item);
                });
                // and then find the command within the command dictionary
                var current_command:TerminalCommand = _command_dictionary[current_command_name] || _command_dictionary[current_command_name.toLowerCase()];
                // if we can find it, then we can simply set or push the arguments depending if args were already set manually
                if (current_command != null) {
                    _command_objects.push(current_command);

                    if (current_command_arguments && current_command_arguments.length) {
                        if (current_command.argument_array.length) {
                            //TODO: currently, there is only a single instance of each command class, which causes problems when piping multiple commands of the same type if they're not in a specific order. need to figure out a way to have multiple instances without breaking or refactoring much
                            current_command.push_args(current_command_arguments);
                        } else {
                            current_command.set_args(current_command_arguments);
                        }
                    }
                } else {
                  // otherwise, the command is not valid, we can skip it
                    trace("invalid command: " + current_command_name);
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
                  if (_result) {
                    _command_objects[i - 1].push_args(_result);
                  }
                    _result = connect(_command_objects[i - 1], _command_objects[i]);
                }
                var cached_result:* = _result;
                _result = undefined;
                return cached_result;
            } else if (_command_objects.length == 1) {
                return _command_objects[0].execute();
            }
        }

        static private function connect(command_0:TerminalCommand, command_1:TerminalCommand):* {
            var command_0_output:* = command_0.execute();
            var piped_arguments:Array = [];

            piped_arguments = (command_1.argument_array.length) ? command_1.argument_array : piped_arguments.concat(command_0_output);
            command_1.set_args(piped_arguments);

            return command_1.execute();
        }

        public function get result():* {
            return (result == undefined || result == null) ? run() : _result;
        }
    }

}

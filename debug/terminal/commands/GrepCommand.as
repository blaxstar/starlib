package net.blaxstar.starlib.debug.terminal.commands {

    import net.blaxstar.starlib.utils.Strings;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import flash.filesystem.File;

    public class GrepCommand extends TerminalCommand {
        private const _filestream:FileStream = new FileStream();

        public function GrepCommand() {
            super("grep", grep);
        }

        /**
         * A console command for greping text. supports file paths for string input, as well as nested filepaths.
         * @param ...args
         * @return a single line string with all matches, seperated by `|`.
         */
        private function grep(... args):String {
            // all arguments except the first one should be the text we want to search
            var search_string:String = Strings.trim(args.splice(0, 1));
            var result:Array = [];
            var searchable_data:String;
            var regex:RegExp = new RegExp(Strings.trim(search_string), "gim");

            for each (var search_source:String in args) {
                result = result.concat(match_lines_in_text(search_source, regex));
            }

            if (!result || result.length == 0) {
                // if we got no results, send back a "no matches" result, for a nicer ux
                result = ["no matches"];
            }
            // we join the multilined text by comma, then replace any stubborn characters to prevent newlines in the output. this is necessary for windows formatted text, but should work fine on mac and linux.
            return result.join("$@").replace(/[\r\n ]+/gim, " ").replace(/[$@]+/gim, " | ");
        }

        private function match_lines_in_text(searchable_data:String, regex:RegExp):Array {
            var lines:Array = [];
            // read the file in...
            _filestream.open(new File(Strings.trim(searchable_data)), FileMode.READ);
            var file_text_string:String = _filestream.readUTFBytes(_filestream.bytesAvailable);
            _filestream.close();
            // and make sure to accomodate for multiline text by splitting by the newline character
            var file_lines:Array = file_text_string.split("\n");
            // then we filter the lines that match the pattern specified by the regex argument. we want this to support nested filepaths for reasons, so lets add a bit of recursion:
            var recursed_file_matches:Array = [];
            var final_matches:Array = file_lines.filter(function(line:String, index:int, array:Array):Boolean {
                // first we check if the current line is a filepath. we'll want to trim the text input so we dont have issues parsing it as a filepath.
                line = Strings.trim(line);
                if (Strings.is_valid_filepath(line)) {
                    // if it is, then verify the file exists and call this function again for the file on this line
                    var input_file:File = new File(line);
                    if (input_file.exists && !input_file.isDirectory) {
                        recursed_file_matches = recursed_file_matches.concat(match_lines_in_text(line, regex));
                        // we'll return false to remove the filepath from the results
                        return false;
                    }
                }
                // otherwise, treat this line like any other and search for matches
                return line.match(regex).length ? true : false;
            });
            // now we just combine all the results and return
            return final_matches.concat(recursed_file_matches);
        }
    }
}

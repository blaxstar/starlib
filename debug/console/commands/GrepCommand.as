package net.blaxstar.starlib.debug.console.commands {

    import net.blaxstar.starlib.utils.Strings;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import flash.filesystem.File;

    public class GrepCommand extends ConsoleCommand {
        private const _filestream:FileStream = new FileStream();

        public function GrepCommand() {
            super("grep", grep);
        }

        /**
         * A console command for greping text. supports file paths for string input.
         * @param ...args 
         * @return a single line string with all matches, seperated by `|`.
         */
        private function grep(... args):String {
            // the last argument should be the text we want to search
            var text_input:String = String(args.pop());
            // we'll want to trim the text input so we dont have issues parsing it, whether its a file path or normal plaintext.
            text_input = Strings.trim(text_input);
            var is_filepath:Boolean = Strings.is_valid_filepath(text_input);
            var regex:RegExp = new RegExp(Strings.trim(args[0]), "gim");
            var result:Array;

            if (is_filepath) {
                // if the text input argument is a filepath, ensure its a valid text file
                var input_file:File = new File(text_input);

                if (input_file.exists && !input_file.isDirectory) {
                    // read the file in...
                    _filestream.open(input_file, FileMode.READ);
                    var file_text_string:String = _filestream.readUTFBytes(_filestream.bytesAvailable);
                    _filestream.close();
                    // and make sure to accomodate for multiline text by splitting by the newline character
                    var file_lines:Array = file_text_string.split("\n");
                    // then we filter the lines that match the pattern specified by the first argument
                    var final_matches:Array = file_lines.filter(function(line:String, index:int, array:Array):Boolean {
                      return line.match(regex).length ? true : false;
                    });
                    
                    result = final_matches;
                }
            } else {
                // if its not a filepath, we can just match the text directly
                result = text_input.match(regex);
            }

            if (!result) {
                // if we got no results, send back a "no matches" result, for a nicer ux
                result = ["no matches"];
            }
            // we join the multilined text by comma, then replace any stubborn characters to prevent newlines in the output. this is necessary for windows formatted text, but should work fine on mac and linux.
            return result.join(",").replace(/[\r\n ]+/gim, " ").replace(/[,]+/gim, "| ");
        }
    }
}

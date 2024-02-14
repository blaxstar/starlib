package net.blaxstar.starlib.debug.console.commands {

    import net.blaxstar.starlib.utils.StringUtil;

    public class GrepCommand extends ConsoleCommand {

        public function GrepCommand() {
            super("grep", grep);
        }

        private function grep(... args):String {
            var textInput:String = String(args.pop());
            var is_filepath:Boolean = StringUtil.is_valid_filepath(textInput);
            var regex:RegExp = new RegExp(args.pop());
            var result:Array;

            if (is_filepath) {
              //TODO: load file and grep det shii
              result = ["this is a file!"];
            } else {
              result = regex.exec(textInput);
            }

            if (!result) {
              result = ["no matches"];
            }

            return result[0];
        }
    }
}

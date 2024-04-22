package net.blaxstar.starlib.utils {

    /**
     * 
     * @param json_string 
     * @param use_tabs 
     * @return 
     */
    public function jsonf(json_string:String, use_tabs:Boolean = false):String {
        var _strings:Object = {};

        var format_json_save_string:Function = function(... args):String {
            var string:String = args[0];
            var index:uint = uint(args[2]);
            _strings[index] = string;
            return "\\" + args[2] + "\\";
        };

        var format_json_restore_string:Function = function(... args):String {
            var index:uint = uint(args[1]);
            return _strings[index];
        }

        var format_json_strip_whitespace:Function = function(... args):String {
            var value:String = args[0];
            return value.replace(/\s/g, '');
        }

        var format_json_make_tabs:Function = function(count:int, useTabs:Boolean):String {
            return new Array(count + 1).join(useTabs ? "\t" : "     ");
        }
        // Save backslashes in strings and strings, so that they were not modified during the formatting.
        json_string = json_string.replace(/(\\.)/g, format_json_save_string);
        json_string = json_string.replace(/(".*?"|'.*?')/g, format_json_save_string);
        // Remove white spaces
        json_string = json_string.replace(/\s+/, "");

        var indent:int = 0;
        var result:String = "";

        for (var i:uint = 0; i < json_string.length; i++) {
            var char:String = json_string.charAt(i);
            switch (char) {
                case "{":
                case "[":
                    result += char + "\n" + format_json_make_tabs(++indent, use_tabs);
                    break;
                case "}":
                case "]":
                    result += "\n" + format_json_make_tabs(--indent, use_tabs) + char;
                    break;
                case ",":
                    result += ",\n" + format_json_make_tabs(indent, use_tabs);
                    break;
                case ":":
                    result += ": ";
                    break;
                default:
                    result += char;
                    break;
            }
        }

        result = result.replace(/\{\s+\}/g, format_json_strip_whitespace);
        result = result.replace(/\[\s+\]/g, format_json_strip_whitespace);
        result = result.replace(/\[[\d,\s]+?\]/g, format_json_strip_whitespace);

        // restore strings
        result = result.replace(/\\(\d+)\\/g, format_json_restore_string);
        // restore backslashes in strings
        result = result.replace(/\\(\d+)\\/g, format_json_restore_string);

        return result;
    }
}

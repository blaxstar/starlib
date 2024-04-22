package net.blaxstar.starlib.debug {
    /**
     * Writes the string pointed by format to the standard output (as3 debugger). If format includes format specifiers (subsequences beginning with %), the additional arguments following format are formatted and inserted in the resulting string replacing their respective specifiers.
     *
     * @author Deron Decamp (decamp.deron@gmail.com)
     */

    /**
     * @param	format string that contains the text to be written to the as3 debugger. It can optionally contain embedded format specifiers that are replaced by the values specified in subsequent additional arguments and formatted as requested.
     * @param	rest additional args
     */
    public function printf(format:String, ... rest):String {
        if (rest.length === 1 && rest[0] is Array) {
            rest = rest[0];
        }

        var specifiers:Array = format.match(/%[i|d|u|U|o|O|x|X|c|C|s|S|f|F|n|N|l|L|b|B|%]/g);

        var to_float:Function = function toFloat(n:Number):Number {
            return parseFloat(String(Math.round(n * 100) / 100));
        };

        var to_octal:Function = function(n:Number):String {
            var retString:String = "";
            retString = n.toString(8);
            retString = retString + "0";
            return retString;
        }

        var to_hex:Function = function(n:Number):String {
            var retString:String = "";
            retString = n.toString(16).toUpperCase();
            while (retString.length < 6) {
                retString = "0" + retString;
            }
            return retString;
        };

        var to_char:Function = function toCharacter(s:String):String {
            return s.substr(0, 1);
        };

        var evaluate:Function = function(specifier:String, val:*):* {
            switch (specifier) {
                case "%i":
                case "%d":
                    return int(val);
                case "%u":
                case "%U":
                    return uint(val);
                case "%o":
                    return to_octal(val);
                case "%O":
                    return to_octal(val).toUpperCase();
                case "%x":
                    return to_hex(val);
                case "%X":
                    return to_hex(val).toUpperCase();
                case "%c":
                    return to_char(val);
                case "%C":
                    return to_char(val).toUpperCase();
                case "%s":
                    return String(val);
                case "%S":
                    return String(val).toUpperCase();
                case "%n":
                case "%N":
                    return (val as Number);
                case "%l":
                case "%L":
                    return to_float(val);
                case "%b":
                    return val;
                case "%B":
                    return (val) ? "TRUE" : "FALSE";
                case "%%":
                    return "%";
                default:
                    return "<invalid specifier>";
            }
        };

        for (var i:int = 0; i < specifiers.length; i++) {
            format = format.replace(specifiers[i], evaluate(specifiers[i], rest[i]));
            if (specifiers[i] == "%%")
                rest.unshift("");
        }
        trace(format);
        return format;
    }


}

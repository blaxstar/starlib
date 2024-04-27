package net.blaxstar.starlib.style {
    import net.blaxstar.starlib.math.Arithmetic;

    /**
     * ...
     * @author Deron D.
     * decamp.deron@gmail.com
     */
    public class RGBA {

        private var _red:uint;
        private var _green:uint;
        private var _blue:uint;
        private var _alpha:uint;
        private var _combined_value:uint;
        private var _black_text_compatible:Boolean;

        public function RGBA(red:uint = 0, green:uint = 0, blue:uint = 0, alpha:uint = 255) {
            _red = red;
            _green = green;
            _blue = blue;
            _alpha = alpha;
            _combined_value = Arithmetic.combine_rgba(red, green, blue, alpha);
            _black_text_compatible = Arithmetic.color_is_bright(_combined_value);
        }

        /**
         * lightens the current RGBA color by 50% and returns the result.
         * @return RGBA result of the lightened RGBA color.
         */
        public function tint(percent:Number=0.5):RGBA {
            var tinted:RGBA = new RGBA(_red + (255 - _red) * percent, _green + (255 - _green) * percent, _blue + (255 - _blue) * percent);

            return tinted;
        }

        /**
         * darkens the current RGBA color by 50% and returns the result.
         * @return RGBA result of the darkened RGBA color.
         */
        public function shade(percent:Number=0.5):RGBA {
            var shaded:RGBA = new RGBA(_red * percent, _green * percent, _blue * percent);

            return shaded;
        }

        static public function from_hex(hex_color:uint):RGBA {
            var r:uint = Arithmetic.extract_red(hex_color);
            var g:uint = Arithmetic.extract_green(hex_color);
            var b:uint = Arithmetic.extract_blue(hex_color);
            var a:uint = Arithmetic.extract_alpha(hex_color);
            var rgba:RGBA = new RGBA(r, g, b, a);

            return rgba;
        }

        public function to_hex_string(use_alpha:Boolean=false):String {
          var r:uint = Arithmetic.extract_red(_combined_value);
            var g:uint = Arithmetic.extract_green(_combined_value);
            var b:uint = Arithmetic.extract_blue(_combined_value);
            var a:uint = Arithmetic.extract_alpha(_combined_value);

            r = r > 255 ? 255 : r;
            g = g > 255 ? 255 : g;
            b = b > 255 ? 255 : b;
            a = a > 255 ? 255 : a;

            var hex_string:String = (use_alpha ? get_channel_hex('a') : "") + get_channel_hex('r') + get_channel_hex('g') + get_channel_hex('b');

            return hex_string.toUpperCase();
        }

        /**
         *
         * @param color_channel channel id which can be either `r`, `g`, `b`, or `a`.
         */
        private function get_channel_hex(color_channel:String):String {
            var channel_string:String = "";

            if (color_channel == 'r') {
                var r:uint = _red > 255 ? 255 : _red;
                channel_string = r.toString(16);
            } else if (color_channel == 'g') {
                var g:uint = _green > 255 ? 255 : _green;
                channel_string = g.toString(16);
            } else if (color_channel == 'b') {
                var b:uint = _blue > 255 ? 255 : _blue;
                channel_string = b.toString(16);
            } else if (color_channel == 'a') {
                var a:uint = _alpha > 255 ? 255 : _alpha;
                channel_string = a.toString(16);
            }

            channel_string = pad_channel_hex_zeroes(channel_string);
            return channel_string;
        }

        private function pad_channel_hex_zeroes(hex_string:String):String {
            while (hex_string.length < 2) {
              hex_string = "0" + hex_string;
            }

            return hex_string;
        }

        public function get red():uint {
            return _red;
        }

        public function get green():uint {
            return _green;
        }

        public function get blue():uint {
            return _blue;
        }

        public function get alpha():uint {
            return _alpha;
        }

        public function set alpha(val:uint):void {
            _alpha = val;
            _combined_value = Arithmetic.combine_rgba(_red, _green, _blue, _alpha);
            _black_text_compatible = Arithmetic.color_is_bright(value);
        }

        public function get is_black_text_compatible():Boolean {
            return _black_text_compatible;
        }

        public function is_white_text_compatible():Boolean {
            return !is_black_text_compatible;
        }

        public function get value():uint {
            return _combined_value;
        }
    }

}

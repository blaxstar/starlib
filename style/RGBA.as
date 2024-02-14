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

        public function RGBA(red:uint = 0, green:uint = 0, blue:uint = 0, alpha:uint = 1) {
            _red = red;
            _green = green;
            _blue = blue;
            _combined_value = Arithmetic.combine_rgba(red, green, blue, alpha);
            _black_text_compatible = Arithmetic.color_is_bright(_combined_value);
        }

        public function tint():RGBA {
            var tinted:RGBA = new RGBA(_red + (255 - _red) * 0.5, _green + (255 - _green) * 0.5, _blue + (255 - _blue) * 0.5);

            return tinted;
        }

        public function shade():RGBA {
            var shaded:RGBA = new RGBA(_red * 0.5, _green * 0.5, _blue * 0.5);

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

        public function get isBlackTextCompatible():Boolean {
            return _black_text_compatible;
        }

        public function isWhiteTextCompatible():Boolean {
            return !isBlackTextCompatible;
        }

        public function get value():uint {
            return _combined_value;
        }
    }

}

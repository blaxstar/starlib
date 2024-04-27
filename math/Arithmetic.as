package net.blaxstar.starlib.math {

    /**
     * ...
     * @author Deron D. (SnaiLegacy)
     */
    public class Arithmetic {
        /**
         * A mathematical constant for the base of natural logarithms, expressed as e.
         * The approximate value of eis 2.71828182845905.
         */
        public static const E:Number = 2.71828182845905;

        /**
         * A mathematical constant for the natural logarithm of 10, expressed as loge10,
         * with an approximate value of 2.302585092994046.
         */
        public static const LN10:Number = 2.302585092994046;

        /**
         * A mathematical constant for the natural logarithm of 2, expressed as loge2,
         * with an approximate value of 0.6931471805599453.
         */
        public static const LN2:Number = 0.6931471805599453;

        /**
         * A mathematical constant for the base-10 logarithm of the constant e (Math.E),
         * expressed as log10e, with an approximate value of 0.4342944819032518.
         */
        public static const LOG10E:Number = 0.4342944819032518;

        /**
         * A mathematical constant for the base-2 logarithm of the constant e, expressed
         * as log2e, with an approximate value of 1.442695040888963387.
         */
        public static const LOG2E:Number = 1.442695040888963387;

        /**
         * A mathematical constant for the ratio of the circumference of a circle to its diameter,
         * expressed as pi, with a value of 3.141592653589793.
         */
        public static const PI:Number = 3.141592653589793;

        /**
         * A mathematical constant for the square root of one-half, with an approximate
         * value of 0.7071067811865476.
         */
        public static const SQRT1_2:Number = 0.7071067811865476;

        /**
         * A mathematical constant for the square root of 2, with an approximate
         * value of 1.4142135623730951.
         */
        public static const SQRT2:Number = 1.4142135623730951;

        /**
         * A mathematical constant for converting degrees (measurement of angle from the inside) to radians (measurement of the distance traveled from the outside of a circle).
         */
        static private const D2R:Number = (PI / 180);

        /**
         * A mathematical constant for converting radians (measurement of the distance traveled from the outside of a circle) to degrees (measurement of angle from the inside).
         */
        static private const R2D:Number = (180 / PI);
        /**
         *
         */
        static private var _sqrt_cache:Array;

        static public function float_to_int(val:Number):int {
            return val >> 0;
        }

        static public function flip_sign(val:int):int {
            return ~val + 1;
        }

        static public function round(val:Number):int {
            return float_to_int(val + 0.5);
        }

        static public function ceil(val:Number):int {
            return float_to_int(val + 1);
        }

        static public function floor(val:Number):int {
            return float_to_int(val);
        }

        static public function min(number0:Number, number1:Number):Number {
            return (number0 < number1 ? number0 : number1);
        }

        static public function max(number0:Number, number1:Number):Number {
            return (number0 > number1 ? number0 : number1);
        }

        static public function mod(numerator:int, divisor:int):int {
            return numerator & (divisor - 1);
        }

        static public function abs(val:int):int {
            return (val ^ (val >> 31)) - (val >> 31);
        }

        static public function pow(base:Number, power:Number):Number {
            var result:int = 1;

            for (var i:int = 0; i < power; i++) {
                result = result * base;
            }

            return result;
        }

        static public function sqrt(val:Number):Number {
            if (!_sqrt_cache) {
                _sqrt_cache = [];
            }
            if (!_sqrt_cache.hasOwnProperty(val)) {
                _sqrt_cache[val] = Math.sqrt(val);
            }

            return _sqrt_cache[val];
        }

        static public function random(min:Number, max:Number, pseed:Number = 0):Number {
            var date:Date = new Date();
            var fseed:uint = (fseed < 1) ? (date.getMilliseconds() / date.getSeconds() + date.getUTCHours()) : fseed;

            var maxRatio:Number = 1 / max;
            var minMaxRatio:Number = (1 / min) / maxRatio;

            fseed ^= (fseed << 21);
            fseed ^= (fseed >>> 35);
            fseed ^= (fseed << 4);

            if (fseed > 0)
                return fseed * maxRatio;
            return fseed * minMaxRatio;
        }

        /**
         * returns the percentage of a number such as 12% of 800.
         * @param	percent Percentage of the number in [of]. can be a decimal or a whole number.
         * @param	of
         * @return
         */
        static public function percent_of(percent:Number, of:Number):Number {
            percent = (percent > 1) ? (percent / 100) : percent;
            return (percent * of);
        }

        static public function color_is_bright(color:uint):Boolean {
            // Counting the perceptive luminance - human eye favors green color
            var a:Number = 1 - (0.299 * extract_red(color) + 0.587 * extract_green(color) + 0.114 * extract_blue(color)) / 255;

            return (a < 0.5);
        }

        static public function darken_color(color:uint, percent:Number = 0.10):uint {
            var r:uint = extract_red(color);
            var g:uint = extract_green(color);
            var b:uint = extract_blue(color);

            r = r - (r * percent);
            g = g - (g * percent);
            b = b - (b * percent);

            return combine_rgba(r, g, b, 1);
        }

        static public function lighten_color(color:uint, percent:Number = 0.10):uint {
            var r:uint = extract_red(color);
            var g:uint = extract_green(color);
            var b:uint = extract_blue(color);

            r = r + (r * percent);
            g = g + (g * percent);
            b = b + (b * percent);

            return combine_rgba(r, g, b, 1);
        }

        static public function combine_rgba(r:uint, g:uint, b:uint, a:uint):uint {
            return (a << 24) | (r << 16) | (g << 8) | b;
        }

        static public function extract_red(color:uint):uint {
            return color >>> 16 & 0xFF;
        }

        static public function extract_green(color:uint):uint {
            return color >>> 8 & 0xFF;
        }

        static public function extract_blue(color:uint):uint {
            return color & 0xFF;
        }

        static public function extract_alpha(color:uint):uint {
            return color >>> 24;
        }

        /**
         * adds an alpha channel to an rgb color.
         * @param	rgb the rgb color to add to.
         * @param	alpha the alpha value to be applied. must be between 0 and 255.
         * @return
         */
        static public function add_alpha_channel(rgb:uint, alpha:uint):uint {
            return rgb + (alpha << 24);
        }

        public static function to_radians(degrees:Number):Number {
            return degrees * D2R;
        }

        public static function to_degrees(radians:Number):Number {
            return radians * R2D;
        }

        static public function get_next_power_of_two(val:uint):uint {
            val--;
            val |= val >> 1;
            val |= val >> 2;
            val |= val >> 4;
            val |= val >> 8;
            val |= val >> 16;
            val++;

            return val;
        }

        static public function is_power_of_two(val:uint):Boolean {
            return ((val != 0) && !(val & (val - 1)));
        }

        static public function is_even(val:int):Boolean {
            return (val & 1) == 0;
        }
    }

}

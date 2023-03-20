package net.blaxstar.style
{
import net.blaxstar.math.Arithmetic;

/**
	 * ...
	 * @author Deron D.
	 * decamp.deron@gmail.com
	 */
	public class RGBA
	{
		
		private var _red:uint;
		private var _green:uint;
		private var _blue:uint;
		private var _alpha:uint;
		private var _combinedValue:uint;
		private var _blackTextCompatible:Boolean;

		public function RGBA(red:uint=0, green:uint=0, blue:uint=0, alpha:uint=1) {
			_red = red;
			_green = green;
			_blue = blue;
			_combinedValue = Arithmetic.combineRGBA(red, green, blue, alpha);
			_blackTextCompatible = Arithmetic.colorIsBright(_combinedValue);
		}

		public function tint():RGBA {
			var tinted:RGBA = new RGBA(_red + (255 - _red) * 0.5, _green + (255 - _green) * 0.5, _blue + (255 - _blue) * 0.5);
			
			return tinted;
		}
		
		public function shade():RGBA {
			var shaded:RGBA = new RGBA(_red * 0.5, _green * 0.5, _blue * 0.5);
			
			return shaded;
		}
		
		public function get red():uint
		{
			return _red;
		}
		
		public function get green():uint
		{
			return _green;
		}
		
		public function get blue():uint
		{
			return _blue;
		}
		
		public function get alpha():uint
		{
			return _alpha;
		}
		
		public function set alpha(val:uint):void {
			_alpha = val;
			_combinedValue = Arithmetic.combineRGBA(_red, _green, _blue, _alpha);
			_blackTextCompatible = Arithmetic.colorIsBright(value);
		}

		public function get isBlackTextCompatible():Boolean
		{
			return _blackTextCompatible;
		}
		
		public function isWhiteTextCompatible():Boolean
		{
			return !isBlackTextCompatible;
		}
		
		public function get value():uint
		{
			return _combinedValue;
		}
	}

}
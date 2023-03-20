package net.blaxstar.io
{
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
	 * ...
	 * @author Deron D. (SnaiLegacy)
	 */
	public class URL extends URLLoader
	{
		public static const BINARY : String = "binary";
		static public const GRAPHICS:String = 'graphics';
		public static const TEXT : String = "text";
		public static const VARIABLES : String = "variables";
		
		private var _id:uint;
		private var _name:String;
		private var _url:String;
		private var _type:String;
		private var _request:URLRequest;
		
		public function URL(id:uint, name:String, type:String=BINARY, url:String=null)
		{
			_id = id;
			_name = name;
			_url = url;
			_type = type;
			_request = new URLRequest(url);
			
			super();
		}
		
		public function start():void 
		{
			load(_request);
		}
		
		public function get id():uint {
			return _id;
		}
		
		public function set id(value:uint):void {
			_id = value;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function set url(val:String):void
		{
			_url = val;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function set type(value:String):void {
			_type = value;
		}
	}
	
}
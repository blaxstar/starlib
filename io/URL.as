package net.blaxstar.starlib.io {
    import net.blaxstar.starlib.debug.DebugDaemon;
    import flash.net.URLLoader;

    import net.blaxstar.starlib.networking.Connection;

    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.filesystem.File;

    /**
     * TODO: documentation
     * @author Deron D. (SnaiLegacy)
     */
    public class URL extends URLLoader {
        // * URL DATA FORMATS * //
        public static const DATA_FORMAT_BINARY:String = "binary";
        static public const DATA_FORMAT_GRAPHICS:String = 'graphics';
        public static const DATA_FORMAT_TEXT:String = "text";
        public static const DATA_FORMAT_VARIABLES:String = "variables";

        // * HTTP REQUEST METHODS * //
        /**
         * Specifies that the URLRequest object is a POST.
         *
         * Note: For content running in Adobe AIR, when  using the
         * navigateToURL() function, the runtime treats a URLRequest that uses
         * the POST method (one that has its method property set to
         * URLRequestMethod.POST) as using the GET method.
         */

        public static const REQUEST_METHOD_POST:String = "POST";

        /**
         * Specifies that the URLRequest object is a GET.
         */
        public static const REQUEST_METHOD_GET:String = "GET";

        /**
         * Specifies that the URLRequest object is a PUT.
         */
        public static const REQUEST_METHOD_PUT:String = "PUT";

        /**
         * Specifies that the URLRequest object is a DELETE.
         */
        public static const REQUEST_METHOD_DELETE:String = "DELETE";

        /**
         * Specifies that the URLRequest object is a HEAD.
         */
        public static const REQUEST_METHOD_HEAD:String = "HEAD";

        /**
         * Specifies that the URLRequest object is OPTIONS.
         */
        public static const REQUEST_METHOD_OPTIONS:String = "OPTIONS";

        // * HTTP AUTH TYPES * //
        public static const AUTH_NONE:String = "none";
        public static const AUTH_BASIC:String = "basic";
        public static const AUTH_TOKEN:String = "token";

        // * CLASS PROPERTIES * //
        private var _name:String;
        private var _endpoint:String;
        private var _expected_data_type:String;
        private var _port:uint;
        private var _is_using_port:Boolean;
        private var _connection:Connection;
        private var _http_request_data:Array;
        private var _http_request_method:String;
        private var _auth_type:String;
        private var _auth_value:String;
        private var _is_async:Boolean;
        private var dataFormat:String;

        // TODO: class documentation
        // * CONSTRUCTOR * /////////////////////////////////////////////////////////
        public function URL(endpoint:String = null, port:uint = undefined) {

            if (endpoint) {
                this._endpoint = endpoint;
            }

            if (port) {
                this._port = port;
            }

            _connection = new Connection(this);

            super();
        }

        // * PUBLIC * //
        public function connect():void {
            _connection.connect();
        }

        public function add_request_variable(key:Object, val:Object):void {
            if (dataFormat !== DATA_FORMAT_VARIABLES) {
                DebugDaemon.write_warning("request vars added to request without expected_data_type being set!");
            }
            _connection.add_http_request_variable(key,val);
        }

        public function add_http_request_data(data:*):void {
            if (!_http_request_data) {
                _http_request_data = [];
            }
            _http_request_data.push(data);
        }

        // * GETTERS & SETTERS * //

        public function get test_path_local():Boolean {
            return new File().resolvePath(endpoint).exists;
        }

        public function get on_request_complete():NativeSignal {
            return _connection.on_connect_signal;
        }

        public function get connection():Connection {
            return _connection;
        }

        public function get name():String {
            return _name;
        }

        public function set name(value:String):void {
            _name = value;
        }

        public function get endpoint():String {
            return _endpoint;
        }

        public function set endpoint(value:String):void {
            _connection.endpoint = _endpoint = value;
        }

        public function get http_request_data():Array {
            return _http_request_data;
        }

        public function set http_request_data(... rest):void {

            if (!_http_request_data) {
                _http_request_data = [];
            }

            for (var i:int = 0; i < rest.length; i++) {
                _http_request_data.push(rest[i]);
            }
        }

        public function set auth_type(value:String):void {
            _auth_type = value;
        }

        public function get auth_type():String {
            return _auth_type;
        }

        /**
         *
         * @param value
         */
        public function set auth_value(value:String):void {
            _auth_value = value;
        }

        public function get auth_value():String {
            return _auth_value;
        }

        public function get port():uint {
            return _port;
        }

        public function set port(value:uint):void {
            _port = _connection.port = value;
        }

        public function get use_port():Boolean {
            return _is_using_port;
        }

        public function set use_port(value:Boolean):void {
            _is_using_port = value;
        }

        public function get http_method():String {
            return _http_request_method;
        }

        public function set http_method(value:String):void {
            _http_request_method = value;
        }

        public function get data_format():String {
            return _expected_data_type;
        }

        public function set data_format(value:String):void {
            _expected_data_type = value;
            if (_expected_data_type !== DATA_FORMAT_GRAPHICS) {
                dataFormat = _expected_data_type;
            } else {
                dataFormat = DATA_FORMAT_BINARY;
            }
        }

        public function get connection_is_async():Boolean {
            return _is_async;
        }

        public function set connection_is_async(value:Boolean):void {
          _is_async = value;
        }
    }

}

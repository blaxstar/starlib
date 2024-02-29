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
        / * URL DATA FORMATS */;
        public static const BINARY:String = "binary";
        static public const GRAPHICS:String = 'graphics';
        public static const TEXT:String = "text";
        public static const VARIABLES:String = "variables";

        / * HTTP REQUEST METHODS * /;

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

        private var _name:String;
        private var _host:String;
        private var _endpoint_path:String;
        private var _expected_data_type:String;
        private var _port:uint;
        private var _using_port:Boolean;
        private var _connection:Connection;
        private var _http_request_data:Array;
        private var dataFormat:String;

        // TODO: class documentation
        // * CONSTRUCTOR * /////////////////////////////////////////////////////////
        public function URL(host:String = null, endpoint_path:String = null, port:uint = null) {

            if (host) {
                this._host = host;
            }

            if (endpoint_path) {
                this._endpoint_path = endpoint_path;
            }

            if (port) {
                this._port = port;
            }

            _connection = new Connection(this);

            super();
        }

        // * PUBLIC * //
        public function connect(async:Boolean = true):void {
            if (async) {
                _connection.connect_async();
            } else {
                _connection.connect();
            }
        }

        public function add_request_variable(key:Object, val:Object):void {
            if (dataFormat !== VARIABLES) {
                DebugDaemon.write_warning("request vars added to request without expected_data_type being set!");
            }
            _connection.async_request_vars[key] = val;
        }

        public function add_http_request_data(data:*):void {
            if (!_http_request_data) {
                _http_request_data = [];
            }
            _http_request_data.push(data);
        }

        // * GETTERS & SETTERS * //

        public function get exists():Boolean {
            return new File().resolvePath(_endpoint_path).exists;
        }

        public function get on_request_complete():NativeSignal {
            return _connection.async_response_signal;
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

        public function get host():String {
            return _host;
        }

        public function set host(value:String):void {
            _connection.host = _host = value;
        }

        public function get endpoint_path():String {
            return _endpoint_path;
        }

        public function set endpoint_path(value:String):void {
            _connection.endpoint_path = _endpoint_path = value;

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

        public function get port():uint {
            return _port;
        }

        public function set port(value:uint):void {
            _port = value;
        }

        public function get use_port():Boolean {
            return _using_port;
        }

        public function set use_port(value:Boolean):void {
            _using_port = value;
        }

        public function get http_method():String {
            return _connection.async_request.method;
        }

        public function set http_method(value:String):void {
            _connection.async_request.method = value;
        }

        public function get expected_data_type():String {
            return _expected_data_type;
        }

        public function set expected_data_type(value:String):void {
            _expected_data_type = value;
            if (_expected_data_type !== GRAPHICS) {
                dataFormat = _expected_data_type;
            } else {
                dataFormat = BINARY;
            }
        }
    }

}

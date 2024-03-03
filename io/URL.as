package net.blaxstar.starlib.io {
    import net.blaxstar.starlib.debug.DebugDaemon;
    import flash.net.URLLoader;

    import net.blaxstar.starlib.networking.Connection;

    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.filesystem.File;
    import thirdparty.org.osflash.signals.Signal;

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
         * A POST request is used to send data to the server, for example, customer information, file upload, etc. using HTML forms.
         *
         * Note: For content running in Adobe AIR, when  using the
         * navigateToURL() function, the runtime treats a URLRequest that uses
         * the POST method (one that has its method property set to
         * URLRequestMethod.POST) as using the GET method.
         */

        public static const REQUEST_METHOD_POST:String = "POST";

        /**
         * Requests using GET should only retrieve data and should have no other effect on the data.
         */
        public static const REQUEST_METHOD_GET:String = "GET";

        /**
         * Replaces all current representations of the target resource with the uploaded content.
         */
        public static const REQUEST_METHOD_PUT:String = "PUT";

        /**
         * Removes all current representations of the target resource given by a URI.
         */
        public static const REQUEST_METHOD_DELETE:String = "DELETE";

        /**
         * Same as GET, but transfers the status line and header section only.
         */
        public static const REQUEST_METHOD_HEAD:String = "HEAD";

        /**
         * Describes the communication options for the target resource.
         */
        public static const REQUEST_METHOD_OPTIONS:String = "OPTIONS";

        // * HTTP AUTH TYPES * //
        public static const AUTH_NONE:String = "none";
        public static const AUTH_BASIC:String = "basic";
        public static const AUTH_TOKEN:String = "token";

        // * CLASS PROPERTIES * //
        private var _name:String;
        private var _endpoint:String;
        private var _query_path:String;
        private var _data_format:String;
        private var _port:uint;
        private var _is_using_port:Boolean;
        private var _connection:Connection;
        private var _http_request_data:Array;
        private var _http_request_method:String;
        private var _auth_type:String;
        private var _auth_value:String;
        private var _is_async:Boolean;
        private var _is_http_request:Boolean;
        private var dataFormat:String;

        // TODO: class documentation, EXPOSE LISTENERS PUBLICLY
        // * CONSTRUCTOR * /////////////////////////////////////////////////////////
        public function URL(endpoint:String = null, port:uint = undefined) {

            if (endpoint) {
                this._endpoint = endpoint;
            }

            if (port) {
                this._port = port;
            }
            _query_path = "";
            _connection = new Connection(this);

            super();
        }

        // * PUBLIC * //
        public function connect():void {
            _connection.connect();
        }

        public function close_connection():void {
            _connection.close();
        }

        public function add_query_variable(key:Object, val:Object):void {
            if (_data_format !== DATA_FORMAT_VARIABLES) {
                DebugDaemon.write_warning("request vars added to request without expected_data_type being set!");
            }
            _connection.add_http_request_variable(key, val);
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
            _endpoint = value;
        }

        public function get query_path():String {
            return _query_path;
        }

        public function set query_path(value:String):void {
            _query_path = value;
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
            _port = value;
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
            return _data_format;
        }

        public function set data_format(value:String):void {
            _data_format = value;
            if (_data_format !== DATA_FORMAT_GRAPHICS) {
                super.dataFormat = _data_format;
            } else {
                super.dataFormat = DATA_FORMAT_BINARY;
            }
        }

        public function get is_http_request():Boolean {
            return _is_http_request;
        }

        public function set is_http_request(value:Boolean):void {
            _is_http_request = value;
        }

        public function get is_async():Boolean {
            return _is_async;
        }

        public function set is_async(value:Boolean):void {
            _is_async = value;
        }
    }

}

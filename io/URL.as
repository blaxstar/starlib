package net.blaxstar.starlib.io {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.URLLoader;
    import flash.utils.ByteArray;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.networking.APIRequest;
    import net.blaxstar.starlib.networking.Connection;
    import net.blaxstar.starlib.utils.StringUtil;
    import flash.events.EventDispatcher;

    /**
     * TODO: documentation
     * @author Deron D. (SnaiLegacy)
     */
    public class URL extends EventDispatcher {
        // * URL DATA FORMATS * //
        public static const DATA_FORMAT_BINARY:String = "application/octet-stream";
        static public const DATA_FORMAT_GRAPHICS:String = 'graphics';
        public static const DATA_FORMAT_TEXT:String = "text";
        public static const DATA_FORMAT_VARIABLES:String = "variables";
        public static const DATA_FORMAT_JSON:String = "json";

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
        private var _local_endpoint:String;
        private var _data_format:String;
        private var _port:uint;
        private var _is_using_port:Boolean;
        private var _connection:Connection;
        private var _local_file:File;
        private var _filestream:FileStream;
        private var _is_local:Boolean;
        private var _is_async:Boolean;
        private var _pending_delegates:Array;
        private var _request_data:APIRequest;
        private var _local_file_data:ByteArray;

        // TODO: class documentation, EXPOSE LISTENERS PUBLICLY
        // * CONSTRUCTOR * /////////////////////////////////////////////////////////
        public function URL(local:Boolean = false) {

            if (local) {
                _is_local = local;
                _local_file_data = new ByteArray();
            }

            _pending_delegates = [];
            _connection = new Connection(this);

            super();
        }

        // * PUBLIC * //
        public function connect():void {
            _connection.set_request_variables(_request_data.request_variables_compiled);
            _connection.connect();
        }

        /**
         *
         * @param filepath the full local filepath for the file to load.
         * @param on_complete a callback function that expects a bytearray.
         */
        public function load_local_file(on_complete:Function):void {
            if (!test_path_local) {
                DebugDaemon.write_error("could not load file: local file path does not exist! path: %s", _local_endpoint);
                return;
            }

            var data:ByteArray = new ByteArray();

            _filestream ||= new FileStream();
            //_filestream.addEventListener(ProgressEvent.PROGRESS, on_local_file_progress);
            _filestream.open(_local_file, FileMode.READ);
            _filestream.readBytes(data);
            _filestream.close();

            on_complete(data);
        }

        public function close_connection():void {
            _connection.close();
        }

        public function set_request_data(request:APIRequest):URL {
            _request_data = request;
            return this;
        }

        public function add_query_variable(key:Object, val:Object):void {
            _request_data.add_request_variable(key, val);

        }

        public function add_http_request_data(data:*):void {
            _request_data.add_body_data(data);
        }

        public function add_connect_listener(delegate:Function):void {
            _connection.on_connect_signal.add(delegate);
        }

        public function add_progress_listener(delegate:Function):void {
            _connection.on_progress_signal.add(delegate);
        }

        public function add_close_listener(delegate:Function):void {
            _connection.on_close_signal.add(delegate);
        }

        public function add_io_error_listener(delegate:Function):void {
            _connection.on_io_error_signal.add(delegate);
        }

        public function add_complete_listener(delegate:Function):void {
            _connection.on_complete_signal.add(delegate);
        }

        // * GETTERS & SETTERS * //

        public function get test_path_local():Boolean {
            return _local_file.exists;
        }

        public function get bytes_loaded():uint {
            if (_is_local) {
                return _local_file.data.bytesAvailable;
            }
            return _connection.bytes_loaded;
        }

        public function get bytes_total():int {
            if (_is_local) {
                return filesize;
            }
            return _connection.bytes_total;
        }

        public function get filesize():int {
            if (!_is_local || !StringUtil.is_valid_filepath(endpoint) || !_local_file) {
                return -1;
            } else {
                return _local_file.size;
            }
        }

        public function get connection():Connection {
            return _connection;
        }

        public function get name():String {
            if (_is_local) {
                return _name;
            }

            return _request_data.name;
        }

        public function set name(value:String):void {
            if (_is_local) {
                _name = value;
                return;
            }

            _request_data.name = value;
        }

        public function get endpoint():String {
            if (_is_local) {
                return _local_endpoint;
            }

            return _request_data.endpoint;
        }

        public function set endpoint(value:String):void {
            if (_is_local) {
                _local_endpoint = value;
                _local_file = new File(_local_endpoint);
                return;
            }

            _request_data.endpoint = value;
        }

        public function get query_path():String {
            return _request_data.query_path;
        }

        public function set query_path(value:String):void {
            _request_data.endpoint = value;
        }

        public function get http_request_data():Array {
            return _request_data.body_data;
        }

        public function set auth_type(value:String):void {
            _request_data.auth_type = value;
        }

        public function get auth_type():String {
            return _request_data.auth_type;
        }

        /**
         *
         * @param value
         */
        public function set auth_value(value:String):void {
            _request_data.auth_value = value;
        }

        public function get auth_value():String {
            return _request_data.auth_value;
        }

        public function get port():uint {
            if (_is_local)
                return _port;
            return _request_data.port;
        }

        public function set port(value:uint):void {
            if (_is_local)
                _port = value;
            _request_data.port = value;
        }

        public function get use_port():Boolean {
            return _is_using_port;
        }

        public function set use_port(value:Boolean):void {
            _is_using_port = value;
        }

        public function get http_method():String {
            return _request_data.http_method;
        }

        public function set http_method(value:String):void {
            _request_data.http_method = value;
        }

        public function get content_type():String {
            if (_is_local)
                return _data_format;
            return _request_data.content_type_header;
        }

        public function set content_type(value:String):void {
            if (_is_local) {
                _data_format = value;
            } else {
                _request_data.content_type_header = value;
            }
        }

        public function get is_async():Boolean {
            return _is_async;
        }

        public function set is_async(value:Boolean):void {
            _is_async = value;
        }
    }

}

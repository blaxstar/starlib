package net.blaxstar.starlib.networking {

    import net.blaxstar.starlib.debug.DebugDaemon;
    import flash.utils.Dictionary;

    public class APIRequest {
        private var _name:String;
        private var _endpoint:String;
        private var _port:uint;
        private var _query_path:String;
        private var _http_request_data:Array;
        private var _http_request_method:String;
        private var _auth_type:String;
        private var _auth_value:String;
        private var _content_type_header:String;
        private var _http_request_vars:Dictionary;
        private var _num_request_vars:uint;

        public function APIRequest(name:String="server") {
          _name = name;
        }

        /**
         * add a key value pair to be added as url request variables.
         * @param key
         * @param val
         */
        public function add_request_variable(key:Object, val:Object):void {

            if (_content_type_header !== "variables") {
                DebugDaemon.write_warning("request vars added to request without content_type_header being set to `variables`!");
            }

            if (!_http_request_vars) {
                _http_request_vars = new Dictionary(true);
                _num_request_vars = 0;
            }

            _http_request_vars[key] = val;
            _num_request_vars++;

        }

        /**
         * adds some data to the body of this request.
         * @param data the data to add.
         */
        public function add_body_data(data:*):void {
            if (!_http_request_data) {
                _http_request_data = [];
            }
            _http_request_data.push(data);
        }

        public function clear_body_data():void {
          _http_request_data.length = 0;
        }

        // * GETTERS & SETTERS * //

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


        public function get port():uint {
            return _port;
        }

        public function set port(value:uint):void {
            _port = value;
        }


        public function get http_method():String {
            return _http_request_method;
        }

        public function set http_method(value:String):void {
            _http_request_method = value;
        }


        public function get content_type_header():String {
            return _content_type_header;
        }

        public function set content_type_header(value:String):void {
            _content_type_header = value;
        }

        public function get request_variables_compiled():String {
          var compiled:String = "";
          var num_appended:uint = 0;
          for (var s:String in _http_request_vars) {
            compiled = compiled.concat(s).concat("=").concat(_http_request_vars[s]);
            if (num_appended < (_num_request_vars-1)) {
              compiled = compiled.concat("&");
            }
          }
          return compiled;
        }

        public function get body_data():Array {
          return _http_request_data;
        }

        public function get query_path():String {
            return _query_path;
        }

        public function set query_path(value:String):void {
            _query_path = value;
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


    }
}

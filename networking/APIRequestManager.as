package net.blaxstar.starlib.networking {

    import thirdparty.org.osflash.signals.Signal;
    import net.blaxstar.starlib.io.URL;
    import flash.events.Event;
    import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import net.blaxstar.starlib.io.XLoader;
    import flash.utils.ByteArray;
    import flash.html.script.Package;
    import net.blaxstar.starlib.utils.StringUtil;

    /**
     * ...
     * @author Deron Decamp
     */

    public class APIRequestManager {

        // const
        // -public
        public const ON_ERROR:Signal = new Signal(String);
        public const ON_CONNECT:Signal = new Signal();
        public const ON_DISCONNECT:Signal = new Signal();
        public const on_result_signal:Signal = new Signal(String);

        // vars
        // -private
        private var _backlog:Vector.<Object>;
        private var _api_endpoint:URL;
        private var _connection:Connection;

        // constructor
        public function APIRequestManager(endpoint_path:String = "http://localhost", port:uint = 3000) {

            _api_endpoint = new URL(endpoint_path, port);
            _api_endpoint.name = "server";
            _backlog = new Vector.<Object>();
        }

        /**
         *
         * @param host
         * @param request_method any http request method (use URL class for values).
         * @param endpoint_path
         * @param data
         */
        public function send_https_request(endpoint:String, request_method:String = "GET", data:Object = null, auth_type:String = "NONE", auth_value:String = null):void {

            if (_backlog.length > 0 || _api_endpoint.connection.busy) {
                _backlog.push({"endpoint": endpoint, "request_method": request_method, "data": data, "auth_type": auth_type, "auth_value": auth_value});
            }

            _api_endpoint.endpoint = endpoint;
            _api_endpoint.use_port = true;
            _api_endpoint.port = 443;
            _api_endpoint.http_method = request_method;

            if (data) {
                _api_endpoint.add_http_request_data(data);
            }
            _api_endpoint.connect();
        }

        private function send_next():void {

            if (!_connection || _backlog.length == 0) {
                return;
            }
            var next_request:Object = _backlog.splice(0, 1)[0];
            send_https_request(next_request.endpoint, next_request.request_method, next_request.data, next_request.auth_type, next_request.auth_value);
        }

        public function get endpoint_name():String {
            return _api_endpoint.name;
        }

        public function set endpoint_name(value:String):void {
            _api_endpoint.name = value;
        }

        public function get use_port():Boolean {
            return _api_endpoint.use_port;
        }

        public function set use_port(value:Boolean):void {
            _api_endpoint.use_port = value;
        }

        public function get data_format():String {
            return _api_endpoint.data_format;
        }

        public function set data_format(value:String):void {
            _api_endpoint.data_format = value;
        }

        private function on_response(e:Event):void {
            on_result_signal.dispatch(e.target.data);
            send_next();
        }
    }
}

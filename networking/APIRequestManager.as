package net.blaxstar.starlib.networking {

    import flash.events.Event;
    import flash.utils.ByteArray;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.io.URL;

    import thirdparty.org.osflash.signals.Signal;

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

        // * testing
        public var fake_signal:Signal;

        // constructor
        public function APIRequestManager(endpoint_path:String = "http://localhost", port:uint = 3000) {

            _api_endpoint = new URL();
            _backlog = new Vector.<Object>();
            fake_signal ||= new Signal();
        }

        public function build_https_request(endpoint:String, name:String = "server", request_method:String = "GET", content_type_header:String = "variables", query_path:String = "", query_variables:Object = null, body_data:Object = null, auth_type:String = "basic", auth_value:String = ""):APIRequest {

            var api_request:APIRequest = new APIRequest();

            api_request.endpoint = endpoint;
            api_request.http_method = request_method;
            api_request.content_type_header = content_type_header;
            api_request.query_path = query_path;

            if (body_data) {

                for (var item:Object in body_data) {
                    api_request.add_body_data(body_data[item]);
                }
            }

            if (query_variables) {

                for (var v:String in query_variables) {
                    api_request.add_request_variable(v, body_data[v]);
                }
            }

            api_request.auth_type = auth_type;
            api_request.auth_value = auth_value;
            api_request.port = 443;
            _api_endpoint.is_async = true;
            return api_request;
        }

        /**
         *
         * @param host
         * @param request_method any http request method (use URL class for values).
         * @param endpoint_path
         * @param data
         */
        public function send(request:APIRequest):void {

            if (_backlog.length > 0 || _api_endpoint.connection.busy) {
                _backlog.push(request);
                return;
            } else {
                _api_endpoint.set_request_data(request);
            }

            //_api_endpoint.add_complete_listener(test_on_complete);

            _api_endpoint.connect();
        }

        public function establish_secure_connection(endpoint:String, data:Object = null, on_complete:Function = null, on_error:Function = null):Boolean {
            if (_api_endpoint.connection.busy) {
                DebugDaemon.write_debug("cannot connect, there is a connection that has not been closed.");
                return false;
            } else {
                _api_endpoint.endpoint = endpoint;
                _api_endpoint.use_port = true;
                _api_endpoint.is_async = false;
                _api_endpoint.content_type = URL.DATA_FORMAT_BINARY;


                if (data) {
                    _api_endpoint.add_http_request_data(data);
                }
                _api_endpoint.connect();
                return true;

            }
        }

        private function test_on_complete(incoming_bytes:ByteArray):void {
            DebugDaemon.write_debug("bytes loaded from response: %s", incoming_bytes)
        }

        private function send_next():void {

            if (!_connection || _backlog.length == 0) {
                return;
            }
            var next_request:APIRequest = _backlog.splice(0, 1)[0] as APIRequest;
            send(next_request);
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
            return _api_endpoint.content_type;
        }

        public function set data_format(value:String):void {
            _api_endpoint.content_type = value;
        }

        private function on_response(e:Event):void {
            on_result_signal.dispatch(e.target.data);
            send_next();
        }
    }
}

package net.blaxstar.starlib.networking {
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.net.SecureSocket;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import net.blaxstar.starlib.io.URL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import thirdparty.org.osflash.signals.Signal;
    import net.blaxstar.starlib.utils.StringUtil;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import flash.utils.ByteArray;
    import flash.utils.getDefinitionByName;
    import avmplus.getQualifiedClassName;
    import net.blaxstar.starlib.thirdparty.org.msgpack.MsgPack;
    import net.blaxstar.starlib.thirdparty.org.msgpack.MsgPackFlags;

    /**
     * TODO: documentation
     */
    public class Connection {

        // const
        static private const _POST:String = "POST";
        static private const _GET:String = "GET";
        static private const _PUT:String = "PUT";
        static private const _DELETE:String = "DELETE";
        static private const _REQUEST_TIMEOUT:uint = 7000;
        static private const _RESPONSE_TIMEOUT:uint = 7000;
        static private const _TIMEOUT_REPS:uint = 2;

        // vars
        // * sync
        private var _host:String;
        private var _endpoint_path:String;
        private var _port:uint;
        private var _http_method:String;
        private var _http_request_data:Array;
        private var _socket:SecureSocket;
        private var _msgpack:MsgPack;

        // * async
        private var _async_request:URLRequest;
        private var _async_request_vars:URLVariables;
        private var _timeout_timer:Timer;

        // * general
        private var _url_request_data:URL;
        private var _async_response_signal:NativeSignal;
        private var _async_on_io_error_signal:NativeSignal;
        private var _active:Boolean
        private var _is_busy:Boolean;

        public function Connection(url:URL) {
            _url_request_data = url;
            _host = _url_request_data.host;
            _endpoint_path = _url_request_data.endpoint_path;
            _port = _url_request_data.port;
            _http_method = _url_request_data.http_method;
            _http_request_data = _url_request_data.http_request_data;
        }

        public function connect():void {

            if (!SecureSocket.isSupported) {
                DebugDaemon.write_error("SecureSocket is not supported on this system! Secure connections cannot be made, so NO persistent connections will be made. Cancelling connection request.");
                return;
            }

            if (!_host || _host.replace(" ", "") == "" || _port > 65535) {
                DebugDaemon.write_error("Invalid host address, cancelling connection " + "request. got: '%s:%i'", _host, _port);
                return;
            }

            if (!_socket) {
                _socket = new SecureSocket();
                _msgpack = new MsgPack(MsgPackFlags.READ_RAW_AS_BYTE_ARRAY);
            }

            _socket.timeout = _REQUEST_TIMEOUT * _TIMEOUT_REPS;
            _socket.addEventListener(Event.CONNECT, on_connect);
            _socket.addEventListener(Event.CLOSE, on_close);
            _socket.addEventListener(IOErrorEvent.IO_ERROR, on_io_error);
            busy = true;
            _socket.connect(_host, _port);

        }

        public function connect_async():void {
            // first off, we need to confirm that we are actually expecting something
            if (!_url_request_data.expected_data_type || StringUtil.trim(_url_request_data.expected_data_type) == "") {
                DebugDaemon.write_error("cannot make async request: the connection does not expect a data type!");
                return;
            }

            // make sure some request-related properties are not null when trying to connect
            if (!_async_request) {
                config_async();
            }

            // set the timeout for either kind of connection
            var current_timeout:uint = (_async_request.method == _POST ? _REQUEST_TIMEOUT : _RESPONSE_TIMEOUT);

            // only send variables if that's the expected data type
            if (_url_request_data.dataFormat == URL.VARIABLES) {
                _async_request.data = _async_request_vars;
            }

            // setup the timeout timer and wait for a response to the request
            _timeout_timer = new Timer(current_timeout, _TIMEOUT_REPS);
            _timeout_timer.addEventListener(TimerEvent.TIMER, on_timer_tick);
            _timeout_timer.addEventListener(TimerEvent.TIMER_COMPLETE, on_timer_complete);
            _async_response_signal.add(on_async_request_complete);
            _timeout_timer.start();

            // set the connection to busy, in case we need other objects to know
            busy = true;

            // comply with security...
            NetUtil.load_policy_file(_host, _port);

            // then load the data!
            _async_on_io_error_signal.add(on_io_error);
            _url_request_data.load(_async_request);
        }

        public function close():void {
            _timeout_timer.stop();
            if (_socket.connected)
                _socket.close();
            active = false;
            busy = false;
        }

        public function config_async():void {
            _async_request = new URLRequest(_host + (_url_request_data.use_port ? ":" + _port : ""));

            _async_request_vars = new URLVariables();
            _async_response_signal = new NativeSignal(_url_request_data, Event.COMPLETE, Event);
            _async_on_io_error_signal = new NativeSignal(_url_request_data, IOErrorEvent.IO_ERROR, IOErrorEvent);
        }

        public function get async_request():URLRequest {
            if (!_async_request) {
                config_async();
            }
            return _async_request;
        }

        public function get async_request_vars():URLVariables {
            return _async_request_vars;
        }

        public function get async_response_signal():NativeSignal {
            if (!_async_response_signal) {
                _async_response_signal = new NativeSignal(_url_request_data, Event.COMPLETE, Event);
            }
            return _async_response_signal;
        }

        public function get host():String {
            return _host;
        }

        public function set host(value:String):void {
            _host = value;
        }

        public function get endpoint_path():String {
            return _endpoint_path;
        }

        public function set endpoint_path(value:String):void {
            _endpoint_path = value;
        }

        public function get active():Boolean {
            return _active;
        }

        public function set active(value:Boolean):void {
            _active = value;
        }

        public function get busy():Boolean {
            return _is_busy;
        }

        public function set busy(value:Boolean):void {
            _is_busy = value;
        }

        private function on_timer_tick(e:TimerEvent):void {
        }

        private function on_timer_complete(e:TimerEvent):void {
            DebugDaemon.write_log("connection timeout: %s @ %s", DebugDaemon.WARN, _url_request_data.name, _host + ":" + _port)
        }

        public function on_async_request_complete(e:Event):void {
            _timeout_timer.stop();
            DebugDaemon.write_log("async request complete! got: %s", DebugDaemon.OK, e.target.data);

            if (_socket && !_socket.connected) {
                busy = false;
                active = false;
            }

        }

        private function on_connect(e:Event):void {
            _timeout_timer.stop();
            DebugDaemon.write_success("Connection successful to host %s:%i!", _host, _port);

            var request_data_bytes:ByteArray;
            // write any data from the http_request_data array, as long as the data isnt null or empty, including the header
            if (_endpoint_path && !StringUtil.string_is_empty_or_null(_endpoint_path) && http_method_is_valid) {
                request_data_bytes = new ByteArray();
                request_data_bytes.writeUTFBytes(build_header());

                if (_http_request_data.length > 0) {
                    request_data_bytes.writeBytes(build_data_stream());
                }
                _msgpack.write(request_data_bytes, _socket);
                _socket.flush();
            }

            busy = false;
            active = true;
        }

        private function build_header():String {
            var header:String = "GET " + _endpoint_path + " HTTP/1.1\r\n";
            header.concat("Host: " + _host + "\r\n");
            header.concat("Connection: close\r\n");
            header.concat("\r\n");

            var request_data_bytes:ByteArray = new ByteArray();
            request_data_bytes.writeUTFBytes(header);

            return header;
        }

        private function build_data_stream():ByteArray {
            var data_bytes:ByteArray = new ByteArray();

            for (var i:int = 0; i < _http_request_data.length; i++) {
                _msgpack.write(_http_request_data[i], data_bytes);
            }

            return data_bytes;
        }

        private function on_close(e:Event):void {
            // TODO: handle close
        }

        private function on_io_error(e:IOErrorEvent):void {
            _timeout_timer.stop();
            DebugDaemon.write_log(e.text, DebugDaemon.DEBUG);
        }

        private function get http_method_is_valid():Boolean {
            return _http_method == 'GET' || _http_method == 'POST' || _http_method == 'PUT' || _http_method == 'DELETE' || _http_method == 'OPTIONS' || _http_method == 'HEAD';
        }

    }
}

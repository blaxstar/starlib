package net.blaxstar.starlib.networking {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.SecureSocket;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.io.URL;
    import net.blaxstar.starlib.thirdparty.org.msgpack.MsgPack;
    import net.blaxstar.starlib.thirdparty.org.msgpack.MsgPackFlags;
    import net.blaxstar.starlib.utils.StringUtil;

    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.events.ProgressEvent;
    import thirdparty.org.osflash.signals.Signal;

    /**
     * TODO: documentation
     */
    public class Connection {

        // const
        static private const _REQUEST_TIMEOUT:uint = 7000;
        static private const _TIMEOUT_REPS:uint = 2;

        // vars
        private var _socket:SecureSocket;
        private var _msgpack:MsgPack;
        private var _http_request_config:URL;
        private var _endpoint:String;
        private var _port:uint;
        private var _http_request_method:String;
        private var _http_request_vars:Dictionary;
        private var _num_request_vars:int;
        private var _http_request_payload:Array;
        private var _http_request_data_format:String;
        private var _timeout_timer:Timer;
        private var _active:Boolean
        private var _is_busy:Boolean;
        private var _is_async:Boolean;

        private var _on_connect_signal:NativeSignal;
        private var _on_progress_signal:NativeSignal;
        private var _on_close_signal:NativeSignal;
        private var _on_io_error_signal:NativeSignal;
        public var on_async_request_complete_signal:Signal;

        public function Connection(url:URL) {
            _http_request_config = url;
            _endpoint = _http_request_config.endpoint;
            _port = _http_request_config.port;
            _http_request_method = _http_request_config.http_method;
            _http_request_payload = _http_request_config.http_request_data;
            _http_request_data_format = _http_request_config.data_format;
            _is_async = _http_request_config.connection_is_async;

        }

        public function connect():void {

            if (!SecureSocket.isSupported) {
                DebugDaemon.write_error("SecureSocket is not supported on this system! Secure connections cannot be made, so NO persistent connections will be made. Cancelling connection request.");
                return;
            }

            if (!_endpoint || _endpoint.replace(" ", "") == "" || _port > 65535) {
                DebugDaemon.write_error("Invalid host address, cancelling connection " + "request. got: '%s:%i'", _endpoint, _port);
                return;
            }

            if (!_socket) {
                _socket = new SecureSocket();
                _msgpack = new MsgPack(MsgPackFlags.READ_RAW_AS_BYTE_ARRAY);
            }

            if (!_is_async) {
                config_async();
            }

            _socket.timeout = _REQUEST_TIMEOUT * _TIMEOUT_REPS;
            _on_connect_signal ||= new NativeSignal(_socket, Event.CONNECT, Event);
            _on_progress_signal ||= new NativeSignal(_socket, ProgressEvent.SOCKET_DATA, ProgressEvent);
            _on_close_signal ||= new NativeSignal(_socket, Event.CLOSE, Event);
            _on_io_error_signal ||= new NativeSignal(_socket, IOErrorEvent.IO_ERROR, Event);

            _on_connect_signal.add(on_connect);
            _on_progress_signal.add(on_progress);
            _on_close_signal.add(on_close);
            _on_io_error_signal.add(on_io_error);

            _is_busy = true;
            // comply with security...
            NetUtil.load_policy_file(_endpoint, _port);
            // then connect to the endpoint.
            // TODO: socket error. need to config crosspolicy xml
            _socket.connect(_endpoint, _port);

        }

        public function add_http_request_variable(key:Object, val:Object):void {
            if (!_http_request_vars) {
                _http_request_vars = new Dictionary(true);
                _num_request_vars = 0;
            }

            _http_request_vars[key] = val;
            _num_request_vars++;

        }

        private function close():void {
            _timeout_timer.stop();
            if (_socket.connected) {
                _socket.close();
            }
            active = false;
            busy = false;
        }

        private function config_async():void {
            if (!_http_request_config.data_format || StringUtil.string_is_empty_or_null(_http_request_config.data_format)) {
                DebugDaemon.write_error("cannot make async request: the connection does not expect a data type!");
                return;
            }
        }

        private function build_header():String {
            if (_num_request_vars) {
                _endpoint.concat("?");

                for (var rvkey:Object in _http_request_vars) {
                    _endpoint.concat(String(rvkey) + "=" + String(_http_request_vars[rvkey]) + "&");
                }

                _endpoint = _endpoint.substr(0, _endpoint.length - 2);
            }

            var header:String = "GET " + _endpoint + " HTTP/1.1\r\n";
            header.concat("Host: " + _endpoint + "\r\n");

            if (_http_request_config.auth_type == URL.AUTH_BASIC) {
                header.concat("Authorization: Basic " + _http_request_config.auth_value + "\r\n");
            } else if (_http_request_config.auth_type == URL.AUTH_TOKEN) {
                header.concat("Authorization: Bearer " + _http_request_config.auth_value + "\r\n");
            }

            if (_is_async) {
                header.concat("Connection: close\r\n");
            } else {
                header.concat("Connection: Keep-alive\n\n");
            }

            header.concat("\r\n");

            var request_data_bytes:ByteArray = new ByteArray();
            request_data_bytes.writeUTFBytes(header);

            return header;
        }

        private function build_data_stream():ByteArray {
            var data_bytes:ByteArray = new ByteArray();

            for (var i:int = 0; i < _http_request_payload.length; i++) {
                _msgpack.write(_http_request_payload[i], data_bytes);
            }

            return data_bytes;
        }

        private function process_response_subframes(subframes:ByteArray):void {
          var string_data:Object = subframes.readUTFBytes(subframes.length);
          DebugDaemon.write_debug("incoming subframe: %s", string_data);
        }

        // * DELEGATES * //

        private function on_close(e:Event):void {
            // TODO: handle connection close

        }

        private function on_progress(e:ProgressEvent):void {
            var response_data:ByteArray = new ByteArray();

            if (_is_async) {
              while (_socket.bytesAvailable > 0) {

              }
            } else {
              // TODO: continuous byte stream for online gameplay and other synchronous transmissions
              /**
               * * what we can do here is structure the data transmissions in a specific order with a leading identifier so that we know what the data is for and what we can expect. for example, we can start by writing an integer denoting the reason for the data i.e. player movement. so right away, we know the next few bytes or so will be related to a specific player's movement. we can terminate the data with a special character or integer, maybe a hex code. in case the data comes out of order, we might need to lead each byte sent with an integer or something to denote its order. so the full frame and packing order would come out to:
               * * [INFO_TYPE > INFO [ORDER_ID > INFO_BYTES] * X > TERMINATOR]
               *
               * * where `X` is the number of info sub-frames. sub-frames can be sent as parts of a bigger subframe, or a single subframe. this function (or maybe a helper function) can be tasked with organizing the data and putting it together to be loaded into memory for the application.
               */
              _socket.readBytes(response_data, response_data.length, _socket.bytesAvailable);
              process_response_subframes(response_data);
            }

            trace("Received data:", response_data.toString());
        }

        private function on_io_error(e:IOErrorEvent):void {
            DebugDaemon.write_debug(e.text);
        }

        private function on_timer_tick(e:TimerEvent):void {
        }

        private function on_timer_complete(e:TimerEvent):void {
            DebugDaemon.write_warning("connection timeout: %s @ %s", _http_request_config.name, _endpoint + ":" + _port)
        }

        public function on_async_request_complete(e:Event):void {
            _timeout_timer.stop();
            DebugDaemon.write_success("async request complete! got: %s", e.target.data);

            if (_socket && !_socket.connected) {
                busy = false;
                active = false;
            }

        }

        private function on_connect(e:Event):void {
            _timeout_timer.stop();
            DebugDaemon.write_success("Connection successful to host %s:%i!", _endpoint, _port);

            var request_data_bytes:ByteArray;
            // write any data from the http_request_data array, as long as the data isnt null or empty, including the header
            if (http_method_is_valid) {
                request_data_bytes = new ByteArray();
                request_data_bytes.writeUTFBytes(build_header());

                if (_http_request_payload.length > 0) {
                    request_data_bytes.writeBytes(build_data_stream());
                }
                _msgpack.write(request_data_bytes, _socket);
                _socket.flush();
            }

            busy = false;
            active = true;
        }

        // * GETTERS & SETTERS * //

        public function get on_connect_signal():NativeSignal {
            _on_connect_signal ||= new NativeSignal(_socket, Event.CONNECT, Event);

            return _on_connect_signal;
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

        private function get http_method_is_valid():Boolean {
            return _http_request_method == 'GET' || _http_request_method == 'POST' || _http_request_method == 'PUT' || _http_request_method == 'DELETE' || _http_request_method == 'OPTIONS' || _http_request_method == 'HEAD';
        }

    }
}

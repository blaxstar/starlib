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
    import flash.net.Socket;

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
        private var _http_request_vars:Dictionary;
        private var _num_request_vars:int;
        private var _timeout_timer:Timer;
        private var _chunked_response_holder:ByteArray;
        private var _active:Boolean
        private var _is_busy:Boolean;
        private var _compress:Boolean;

        public var on_connect_signal:NativeSignal;
        public var on_progress_signal:NativeSignal;
        public var on_close_signal:NativeSignal;
        public var on_io_error_signal:NativeSignal;
        public var on_complete_signal:Signal;

        public function Connection(url:URL) {
            _http_request_config = url;
            _socket = new SecureSocket();
            _chunked_response_holder = new ByteArray();
            config_socket();
        }

        public function connect(compress_data:Boolean = false):void {
            // * for security reasons, i think any machine that can't support SecureSocket is probably not worth developing for. i'll leave it like this for now.
            if (!SecureSocket.isSupported) {
                DebugDaemon.write_error("SecureSocket is not supported on this system! Secure connections cannot be made, so NO connections will be made. Cancelling connection request.");
                return;
            }

            // * verify host string and port number
            if (StringUtil.is_empty_or_null(_http_request_config.endpoint) || _http_request_config.port > 65535) {
                DebugDaemon.write_error("Invalid host address, cancelling connection " + "request. got: '%s:%i'", _http_request_config.endpoint, _http_request_config.port);
                return;
            }

            // * if the compress_data flag is true, we'll use msgpack to write bytes
            if (compress_data) {
                _compress = true;
                _msgpack ||= new MsgPack(MsgPackFlags.READ_RAW_AS_BYTE_ARRAY);
            }


            // * add delegates
            on_connect_signal.add(on_connect);
            on_progress_signal.add(on_progress);
            on_close_signal.add(on_close);
            on_io_error_signal.add(on_io_error);
            // * set the connection status to busy and begin the connection
            _is_busy = true;
            _socket.connect(_http_request_config.endpoint, _http_request_config.port);

        }

        /**
         * add a key value pair to be added as url request variables.
         * @param key
         * @param val
         */
        public function add_http_request_variable(key:Object, val:Object):void {
            if (!_http_request_vars) {
                _http_request_vars = new Dictionary(true);
                _num_request_vars = 0;
            }

            _http_request_vars[key] = val;
            _num_request_vars++;

        }

        private function config_socket():void {
            _socket.timeout = _REQUEST_TIMEOUT * _TIMEOUT_REPS;
            on_connect_signal ||= new NativeSignal(_socket, Event.CONNECT, Event);
            on_progress_signal ||= new NativeSignal(_socket, ProgressEvent.SOCKET_DATA, ProgressEvent);
            on_close_signal ||= new NativeSignal(_socket, Event.CLOSE, Event);
            on_io_error_signal ||= new NativeSignal(_socket, IOErrorEvent.IO_ERROR, Event);
            on_complete_signal ||= new Signal(ByteArray);
        }

        public function close():void {
            if (_socket.connected) {
                _socket.close();
            }
            on_connect_signal.remove(on_connect);
            on_progress_signal.remove(on_progress);
            on_close_signal.remove(on_close);
            on_io_error_signal.remove(on_io_error);
            active = false;
            busy = false;
        }

        private function build_header():String {
            if (_num_request_vars) {
                _http_request_config.query_path = _http_request_config.query_path.concat("?");

                for (var rvkey:Object in _http_request_vars) {
                    _http_request_config.query_path = _http_request_config.query_path.concat(String(rvkey) + "=" + String(_http_request_vars[rvkey]) + "&");
                }

                _http_request_config.query_path = _http_request_config.query_path.substr(0, _http_request_config.query_path.length - 1);
            }

            var header:String = _http_request_config.http_method + " " + _http_request_config.query_path + " HTTP/1.1\r\n";
            header = header.concat("Host: " + _http_request_config.endpoint + "\r\n");
            header = header.concat("User-Agent: AIR/32.0\r\n");
            header = header.concat("Accept: text/html\r\n");
            header = header.concat("Accept-Charset: utf-8\r\n");

            if (_http_request_config.auth_type == URL.AUTH_BASIC) {
                header = header.concat("Authorization: Basic " + _http_request_config.auth_value + "\r\n");
            } else if (_http_request_config.auth_type == URL.AUTH_TOKEN) {
                header = header.concat("Authorization: Bearer 6" + _http_request_config.auth_value + "\r\n");
            }

            if (_http_request_config.is_async) {
                header = header.concat("Connection: keep-alive" + "\r\n");
            } else {
                header = header.concat("Connection: keep-alive" + "\r\n");
            }

            header = header.concat("\r\n");

            return header;
        }

        private function build_data_stream():ByteArray {
            var data_bytes:ByteArray = new ByteArray();

            for (var i:int = 0; i < _http_request_config.http_request_data.length; i++) {
                if (_http_request_config.data_format == URL.DATA_FORMAT_TEXT) {
                    data_bytes.writeUTFBytes(_http_request_config.http_request_data[i])
                } else if (_http_request_config.data_format == URL.DATA_FORMAT_BINARY) {
                    data_bytes.writeBytes(_http_request_config.http_request_data[i]);
                }
            }

            return data_bytes;
        }


        // * DELEGATES * //

        private function on_progress(e:ProgressEvent):void {
            var current_chunk:ByteArray = new ByteArray();
            if (_http_request_config.is_async) {
                while (_socket.bytesAvailable > 0) {
                    _socket.readBytes(current_chunk);
                }
                var chunk_string:String = current_chunk.toString();
                if (chunk_string == "0\r\n\r\n" || chunk_string == "\r\n\r\n" || chunk_string == "") {
                    close();
                    on_complete_signal.dispatch(_chunked_response_holder);
                } else {
                    current_chunk.readBytes(_chunked_response_holder, _chunked_response_holder.length);
                }
            } else {
                // TODO: continuous byte stream for online gameplay and other synchronous transmissions
                /**
                 * * what we can do here is structure the data transmissions in a specific order with a leading identifier so that we know what the data is for and what we can expect. for example, we can start by writing an integer denoting the reason for the data i.e. player movement. so right away, we know the next few bytes or so will be related to a specific player's movement. we can terminate the data with a special character or integer, maybe a hex code. in case the data comes out of order, we might need to lead each byte sent with an integer or something to denote its order. so the full frame and packing order would come out to:
                 * * [INFO_TYPE > INFO [ORDER_ID > INFO_BYTES] * X > TERMINATOR]
                 *
                 * * where `X` is the number of info sub-frames. sub-frames can be sent as parts of a bigger subframe, or a single subframe. this function (or maybe a helper function) can be tasked with organizing the data and putting it together to be loaded into memory for the application.
                 */
                _socket.readBytes(current_chunk, current_chunk.length, _socket.bytesAvailable);
                process_response_subframes(current_chunk);
            }
        }

        /**
         * helper function for on_progress. processes recieved data after retreival.
         * @param subframes the data to process, in subframe format.
         */
        private function process_response_subframes(subframes:ByteArray):void {
            var string_data:Object = subframes.readUTFBytes(subframes.length);
            DebugDaemon.write_debug("incoming subframe: %s", string_data);
        }

        private function on_connect(e:Event):void {
            DebugDaemon.write_success("Connection successful to host %s:%i!", _http_request_config.endpoint, _http_request_config.port);
            // * build the header to be sent along with the request
            _socket.writeUTFBytes(build_header());
            // * we'll only send something if there's data to send
            if (_http_request_config.http_request_data && _http_request_config.http_request_data.length > 0) {
                // * check if http method is one of the 6 allowed options
                if (http_method_is_valid) {
                    // * compress the data with msgpack, if _compress is true
                    if (_compress) {
                        var request_data_bytes:ByteArray = new ByteArray();
                        request_data_bytes.writeBytes(build_data_stream());
                        _msgpack.write(request_data_bytes, _socket);
                    } else {
                        _socket.writeBytes(build_data_stream());
                    }
                }
                // * now write the data
                _socket.flush();
            }
            // * set busy status to false, since we sent what we need
            busy = false;
            // * we only need to set active to false if the connection is async
            if (_http_request_config.is_async) {
                active = false;
            } else {
                active = true;
            }

        }

        private function on_close(e:Event):void {
            // TODO: handle connection close

        }

        private function on_io_error(e:IOErrorEvent):void {
            DebugDaemon.write_debug(e.text);
        }


        // * GETTERS & SETTERS * //

        private function get http_method_is_valid():Boolean {
            return _http_request_config.http_method == 'GET' || _http_request_config.http_method == 'POST' || _http_request_config.http_method == 'PUT' || _http_request_config.http_method == 'DELETE' || _http_request_config.http_method == 'OPTIONS' || _http_request_config.http_method == 'HEAD';
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

    }
}

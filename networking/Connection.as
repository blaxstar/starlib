package net.blaxstar.starlib.networking {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.SecureSocket;
    import flash.utils.ByteArray;
    import flash.utils.Timer;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.io.URL;
    import thirdparty.org.msgpack.MsgPack;
    import thirdparty.org.msgpack.MsgPackFlags;
    import net.blaxstar.starlib.utils.Strings;

    import thirdparty.org.osflash.signals.Signal;
    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.utils.Dictionary;

    /**
     * TODO: documentation
     */
    public class Connection {

        // const
        static private const _REQUEST_TIMEOUT:uint = 7000;
        static private const _TIMEOUT_REPS:uint = 2;
        private const _CARRIAGE_RETURN_LINE_FEED:String = String.fromCharCode(13);

        // vars
        private var _socket:SecureSocket;
        private var _msgpack:MsgPack;
        private var _http_request_config:URL;
        private var _http_request_vars:String;
        private var _num_request_vars:int;
        private var _timeout_timer:Timer;
        private var _chunked_response_holder:ByteArray;
        private var _active:Boolean
        private var _is_busy:Boolean;
        private var _compress:Boolean;
        private var _bytes_loaded:uint;
        private var _bytes_total:int;

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

            // (re)set bytes_loaded and bytes_total
            _bytes_loaded = 0;
            _bytes_total = -1;

            // * verify host string and port number
            if (Strings.is_empty_or_null(_http_request_config.endpoint) || _http_request_config.port > 65535) {
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

        public function set_request_variables(request_vars_compiled:String):void {
            _http_request_vars = request_vars_compiled;
        }

        private function config_socket():void {
            _socket.timeout = _REQUEST_TIMEOUT; //* _TIMEOUT_REPS;
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

                if (!Strings.is_empty_or_null(_http_request_vars)) {
                    _http_request_config.query_path = _http_request_config.query_path.concat(_http_request_vars);
                }

                _http_request_config.query_path = _http_request_config.query_path.substr(0, _http_request_config.query_path.length - 1);
            }

            var header:String = _http_request_config.http_method + " " + _http_request_config.query_path + " HTTP/1.1\r\n";
            header = header.concat("Host: " + _http_request_config.endpoint + "\r\n");
            header = header.concat("User-Agent: AIR/32.0\r\n");
            header = header.concat("Accept: text/html\r\n");
            header = header.concat("Accept-Charset: utf-8\r\n");

            var content_type_string:String;

            switch (_http_request_config.content_type) {
                case URL.DATA_FORMAT_VARIABLES:
                default:
                    content_type_string = "x-www-form-urlencoded";
                    break;
                case URL.DATA_FORMAT_TEXT:
                    content_type_string = "text/plain";
                    break;
                case URL.DATA_FORMAT_BINARY:
                case URL.DATA_FORMAT_GRAPHICS:
                    content_type_string = "application/octet-stream";
                    break;
                case URL.DATA_FORMAT_JSON:
                    content_type_string = "application/json";
                    break;
            }

            var body_bytes:ByteArray = new ByteArray();
            if (_http_request_config.http_request_data && _http_request_config.http_request_data.length) {
                header = header.concat("Content-Type: " + content_type_string + "\r\n");

                body_bytes.writeUTFBytes(build_body());
                header = header.concat("Content-Length: " + body_bytes.length + "\r\n");
            }

            if (_http_request_config.auth_type == URL.AUTH_BASIC) {
                header = header.concat("Authorization: Basic " + _http_request_config.auth_value + "\r\n");
            } else if (_http_request_config.auth_type == URL.AUTH_TOKEN) {
                header = header.concat("Authorization: Bearer " + _http_request_config.auth_value + "\r\n");
            }

            // TODO: currently, all responses are returned as 'chunked', which means `Connection: close` terminates too early, before all the data from the request comes in. the work around for now is to keep it set to `Connection: keep-alive`, and check for the termination of the data in the on_progress method. for synchronous streams, we will skip this check. will look into any possible solutions later.
            header = header.concat("Connection: keep-alive" + "\r\n");

            var custom_headers:Dictionary = _http_request_config.custom_headers;

            if (custom_headers) {
                for (var custom_header:String in custom_headers) {
                    header = header.concat(custom_header + ": " + custom_headers[custom_header] + "\r\n");
                    delete custom_headers[custom_header];
                }
            }

            header = header.concat("\r\n");

            if (_http_request_config.is_async) {
                header = header.concat(body_bytes.toString());
            }

            return header;
        }

        private function build_data_stream():ByteArray {
            var data_bytes:ByteArray = new ByteArray();
            var body_data:Array = _http_request_config.http_request_data;
            var content_type:String = _http_request_config.content_type;

            for (var i:int = 0; i < body_data.length; i++) {
                if (content_type == URL.DATA_FORMAT_TEXT) {
                    data_bytes.writeUTFBytes(body_data[i])
                } else if (content_type == URL.DATA_FORMAT_BINARY) {
                    data_bytes.writeBytes(body_data[i]);
                } else if (content_type == URL.DATA_FORMAT_JSON) {
                    if (body_data.length == 1) {
                        data_bytes.writeObject(JSON.stringify(body_data[0]));
                    } else {
                        for (var j:int = 0; j < body_data.length; i++) {
                            data_bytes.writeObject(JSON.stringify(body_data[i]));
                        }
                    }
                }
            }

            return data_bytes;
        }

        private function build_body():String {
            var body:String = "";
            var body_data:Array = _http_request_config.http_request_data;
            var content_type:String = _http_request_config.content_type;

            for (var i:int = 0; i < body_data.length; i++) {
                if (content_type == URL.DATA_FORMAT_JSON) {
                    if (body_data.length == 1) {
                        body = body.concat(JSON.stringify(body_data[0]));
                    } else {
                        var final_json:Object = {};
                        for (var j:int = 0; j < body_data.length; i++) {
                            final_json[i] = JSON.stringify(body_data[i]);
                        }
                    }
                } else {
                    // TODO: content_type == application/octet-stream => write bytes to bytearray and use .toString() => add to body and return
                    body = body.concat(String(body_data[i]));
                }
            }

            return body;
        }


        // * DELEGATES * //

        private function on_progress(e:ProgressEvent):void {
            var current_chunk:ByteArray = new ByteArray();

            // we'll write the current chunk to its own byte array so we can process it individually. this will be used in both sync and async cases.
            _socket.readBytes(current_chunk, current_chunk.length, _socket.bytesAvailable);

            if (_http_request_config.is_async) {
                // for async requests, especially for http responses, we'll add the chunks to a big bytearray and process them all at once when its all loaded in
                current_chunk.readBytes(_chunked_response_holder, _chunked_response_holder.length);
                _bytes_loaded += current_chunk.length;
                // convert the current chunk to a string so we can check if it contains a termination sequence, and also look out for the content-length header
                var chunk_string:String = current_chunk.toString();
                // checking for content length so we can provide bytes_total
                if (!bytes_total) {
                    if (chunk_string.indexOf("Content-Length:")) {
                        var content_length_header_regex:RegExp = / /g;
                        var total_bytes:int = parseInt(String(chunk_string.match(content_length_header_regex)[0]).split(": ")[1]);
                        DebugDaemon.write_debug("total bytes: %s", total_bytes);
                    }
                }

                // the termination sequence can be either of these i think depending on the server, i'm just checking both to make sure
                if (chunk_string.indexOf("0\r\n\r\n") != -1 || chunk_string.indexOf("\r\n\r\n") != -1) {
                    // close the connection and dispatch the response data
                    close();
                    active = false;
                    on_complete_signal.dispatch(_chunked_response_holder);
                    _chunked_response_holder.clear();
                }
            } else {
                // TODO: continuous byte stream for online gameplay and other synchronous transmissions
                /**
                 * * what we can do here is structure the data transmissions in a specific order with a leading identifier so that we know what the data is for and what we can expect. for example, we can start by writing an integer denoting the reason for the data i.e. player movement. so right away, we know the next few bytes or so will be related to a specific player's movement. we can terminate the data with a special character or integer, maybe a hex code. in case the data comes out of order, we might need to lead each byte sent with an integer or something to denote its order. so the full frame and packing order would come out to:
                 * * [INFO_TYPE > INFO [ORDER_ID > INFO_BYTES] * X > TERMINATOR]
                 *
                 * * where `X` is the number of info sub-frames. sub-frames can be sent as parts of a bigger subframe, or a single subframe. this function (or maybe a helper function) can be tasked with organizing the data and putting it together to be loaded into memory for the application.
                 */
            }
            process_response_subframes(current_chunk);
        }

        /**
         * helper function for on_progress. processes recieved data after retreival.
         * @param subframes the data to process, in subframe format.
         */
        private function process_response_subframes(subframes:ByteArray):void {
            subframes.position = 0;
            var string_data:String = subframes.readUTFBytes(subframes.length);
            //DebugDaemon.write_debug("incoming subframe: %s", string_data);
        }

        private function on_connect(e:Event):void {
            var full_ting:String = "";
            DebugDaemon.write_success("Connection successful to host %s:%i!", _http_request_config.endpoint, _http_request_config.port);
            // * build the header to be sent along with the request, but only if its an async request (not a persistent connection)
            if (_http_request_config.is_async) {
                _socket.writeUTFBytes(build_header());
            }
            // * we'll only send something if there's data to send
            if (_http_request_config.http_request_data && _http_request_config.http_request_data.length > 0) {
                // * check if http method is one of the 6 allowed options
                if (http_method_is_valid) {
                    // * if the reqest is async (an http request), the body will have to be a string sent attached to the header

                    // * compress the data with msgpack, if _compress is true
                    if (_compress) {
                        var request_data_bytes:ByteArray = new ByteArray();
                        request_data_bytes.writeBytes(build_data_stream());
                        _msgpack.write(request_data_bytes, _socket);
                    } else {
                        _socket.writeBytes(build_data_stream());
                    }

                }
            }
            // * now write the data
            _socket.flush();
            // * set busy status to false, since we sent what we need
            busy = false;

        }

        private function on_close(e:Event):void {
            // TODO: handle connection close
            on_close_signal.dispatch();
        }

        private function on_io_error(e:IOErrorEvent):void {
            on_io_error_signal.dispatch(e);
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

        public function get bytes_loaded():int {
            return _bytes_loaded;
        }

        public function get bytes_total():int {
            return _bytes_total;
        }

    }
}

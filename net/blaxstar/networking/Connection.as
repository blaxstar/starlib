package net.blaxstar.networking {
  import flash.utils.Timer;
  import flash.events.TimerEvent;
  import flash.net.SecureSocket;
  import debug.DebugDaemon;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import net.blaxstar.io.URL;
  import flash.net.URLRequest;
  import flash.net.URLVariables;
  import thirdparty.org.osflash.signals.natives.NativeSignal;
  import thirdparty.org.osflash.signals.Signal;

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
    //-- sync
    private var _host:String;
    private var _port:uint;
    private var _socket:SecureSocket;

    //-- async
    private var _async_request:URLRequest;
    private var _async_request_vars:URLVariables;
    private var _timeout_timer:Timer;

    //-- general
    private var _url_request_data:URL;
    private var _async_response_signal:NativeSignal;
    private var _async_on_io_error_signal:NativeSignal;
    private var _active:Boolean
    private var _is_busy:Boolean;

    public function Connection(url:URL) {
      _url_request_data = url;
      _host = _url_request_data.host;
      _port = _url_request_data.port;
    }

    public function connect():void {

      if (!SecureSocket.isSupported) {
        DebugDaemon.write_log("SecureSocket is not supported on this system." +
        "Secure connections cannot be made, so NO persistent connections " +
        "will be made. Cancelling connection request.", DebugDaemon.ERROR_IO);
        return;
      }

      if (!_host || _host.replace(" ", "") == "" || _port > 65535 ) {
        DebugDaemon.write_log("Invalid host address, cancelling connection " +
        "request. got: '%s:%i'", DebugDaemon.ERROR_GENERIC, _host, _port);
        return;
      }

      if (!_socket) {
        _socket = new SecureSocket();
      }

      _socket.timeout = _REQUEST_TIMEOUT * _TIMEOUT_REPS;
      _socket.addEventListener(Event.CONNECT, on_connect);
      _socket.addEventListener(Event.CLOSE, on_close);
      _socket.addEventListener(IOErrorEvent.IO_ERROR, on_io_error);
      busy = true;
      _socket.connect(_host, _port);
    }

    public function connect_async():void {
      var current_timeout:uint =
      (_async_request.method == _POST ? _REQUEST_TIMEOUT : _RESPONSE_TIMEOUT);

      if (!_async_request) {
        set_async_vars();
      }

      if (_url_request_data.dataFormat == URL.VARIABLES) {
        _async_request.data = _async_request_vars;
      }

      _async_response_signal.add(on_async_request_complete);

      _timeout_timer = new Timer(current_timeout, _TIMEOUT_REPS);
      _timeout_timer.addEventListener(TimerEvent.TIMER, on_timer_tick);
      _timeout_timer.addEventListener(TimerEvent.TIMER_COMPLETE, on_timer_complete);
      _timeout_timer.start();

      busy = true;
      NetUtil.load_policy_file(_host, _port);
      _async_on_io_error_signal.add(on_io_error);
      _url_request_data.load(_async_request);
    }

    public function close():void {
      _timeout_timer.stop();
      if (_socket.connected) _socket.close();
      active = false;
      busy = false;
    }

    public function set_async_vars():void {
      _async_request = new URLRequest(_host + ":" + _port);
      _async_request_vars = new URLVariables();
      _async_response_signal = new NativeSignal(_url_request_data, Event.COMPLETE, Event);
      _async_on_io_error_signal = new NativeSignal(_url_request_data, IOErrorEvent.IO_ERROR, IOErrorEvent);
    }

    public function get async_request():URLRequest {
      if (!_async_request) {
        set_async_vars();
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

    private function on_timer_tick(e:TimerEvent):void {}

    private function on_timer_complete(e:TimerEvent):void {
      DebugDaemon.write_log("connection timeout: %s @ %s", DebugDaemon.WARN,
      _url_request_data.name, _host + ":" + _port)
    }

    public function on_async_request_complete(e:Event):void {
      _timeout_timer.stop();
      DebugDaemon.write_log("async request complete! got: %s",
      DebugDaemon.OK, e.target.data);

      if (_socket && !_socket.connected) {
        busy = false;
        active = false;
      }

    }

    private function on_connect(e:Event):void {
      _timeout_timer.stop();
      DebugDaemon.write_log("Connection successful to host %s:%i!",
      DebugDaemon.OK, _host, _port);

      busy = false;
      active = true;
    }

    private function on_close(e:Event):void {

    }

    private function on_io_error(e:IOErrorEvent):void {
      _timeout_timer.stop();
      DebugDaemon.write_log(e.text, DebugDaemon.DEBUG);
    }

  }
}

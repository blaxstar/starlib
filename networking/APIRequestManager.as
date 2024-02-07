package net.blaxstar.starlib.networking {

  import thirdparty.org.osflash.signals.Signal;
  import net.blaxstar.starlib.io.URL;
  import flash.events.Event;

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
    private var _backlog:Vector.<String>;
    private var _api_endpoint:URL;
    private var _connection:Connection;

    // constructor
    public function APIRequestManager(endpoint_path:String="http://localhost", port:uint=3000) {

      _api_endpoint = new URL(endpoint_path, port);
      _api_endpoint.name = "server";
      _backlog = new Vector.<String>();
    }

    public function query(q:String, http_method:String=URL.REQUEST_METHOD_GET):void {
      if (!q || q == "") {
        return;
      }

      if (_backlog.length > 0 || _api_endpoint.connection.busy) {
        _backlog.push(q);
      } else {
        _api_endpoint.http_method = http_method;
        _api_endpoint.on_request_complete.add(on_response);
        _api_endpoint.connect();
      }
    }

    private function send_next():void {

      if (!_connection || _backlog.length == 0) {
        return;
      }

      query(_backlog.splice(0, 1)[0]);
    }

    public function get endpoint_name():String {
      return _api_endpoint.name;
    }

    public function set endpoint_name(value:String):void {
      _api_endpoint.name = value;
    }

    public function get expected_data_type():String {
      return _api_endpoint.expected_data_type;
    }

    public function set expected_data_type(value:String):void {
      _api_endpoint.expected_data_type = value;
    }

    private function on_response(e:Event):void {
      on_result_signal.dispatch(e.target.data);
      send_next();
    }
  }
}

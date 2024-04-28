package net.blaxstar.starlib
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Stage;
  import net.blaxstar.starlib.style.Style;
  import thirdparty.com.lorentz.processing.ProcessExecutor;
  import net.blaxstar.starlib.debug.DebugDaemon;
  import net.blaxstar.starlib.input.InputEngine;

  public class Starlib {
    static public const VERSION_STRING:String = "STARLIB VERSION 0.8.0";
    static private var _input_engine:InputEngine;

    static public function init(main:DisplayObjectContainer, stage:Stage, write_errors_to_logfile:Boolean=false, error_log_name:String="starlib_log_file"):void {

        if (!main) {
          throw new Error("Main class is null!");
        } 
        if (!stage) {
          throw new Error("stage is null!");
        }

        _input_engine = new InputEngine(stage, true);
        Style.init(main);
        ProcessExecutor.instance.initialize(stage);

        if (write_errors_to_logfile) {
          DebugDaemon.init(stage.nativeWindow, error_log_name);
        }
    }
  }
}
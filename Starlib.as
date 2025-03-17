package net.blaxstar.starlib
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Stage;
  import net.blaxstar.starlib.style.Style;
  import com.lorentz.processing.ProcessExecutor;
  import net.blaxstar.starlib.debug.DebugDaemon;
  import net.blaxstar.starlib.input.InputEngine;

  public class Starlib {
    static public const VERSION_STRING:String = "STARLIB VERSION 0.9.0";
    static private var _input_engine:InputEngine;

    /**
     * @param main  a reference to the main stage, needed for initialization of the library.
     * @param stage
     */
    static public function init(main:DisplayObjectContainer, init_input:Boolean = false, write_errors_to_logfile:Boolean=false):void {

        if (!main) {
          throw new Error("Main class is null!");
        } 
        if (!main.stage) {
          throw new Error("stage is null!");
        }

        var stage:Stage = main.stage;

        if (init_input) {
          _input_engine = new InputEngine(stage, true);
        }
        
        Style.init(main);
        ProcessExecutor.instance.initialize(stage);

        if (write_errors_to_logfile) {
          DebugDaemon.init(stage.nativeWindow, "starlib_errlog");
        }
    }
  }
}
package net.blaxstar.starlib
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Stage;
  import net.blaxstar.starlib.style.Style;
  import thirdparty.com.lorentz.processing.ProcessExecutor;
  import net.blaxstar.starlib.debug.DebugDaemon;

  public class Starlib {
    static public function init(main:DisplayObjectContainer, stage:Stage, write_errors_to_logfile:Boolean=false, error_log_name:String="starlib_log_file"):void {

        if (!main) {
          throw new Error("Main class is null!");
        } 
        if (!stage) {
          throw new Error("stage is null!");
        }

        Style.init(main);
        ProcessExecutor.instance.initialize(stage);

        if (write_errors_to_logfile) {
          DebugDaemon.init(stage.nativeWindow, error_log_name);
        }
    }
  }
}
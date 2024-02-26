package net.blaxstar.starlib.debug {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.display.NativeWindow;
    import flash.events.Event;

    public class DebugDaemon {
        public static const OK:uint = 0;
        public static const DEBUG:uint = 1;
        public static const WARN:uint = 2;
        public static const ERROR:uint = 3;

        private static var _log_file:File;
        private static var _instance:DebugDaemon;
        private static var _log:Vector.<String>;
        private static var _filestream:FileStream;

        /**
         * TODO: class documentation
         */
        public function DebugDaemon() {
            if (_instance) {
                throw new Error("class is a singleton instance. use DebugDaemon.get_instance().");
            }
            _log = new Vector.<String>();
            _filestream = new FileStream();
        }

        static public function init(window:NativeWindow = null, logfile_name:String = "new_app_log"):void {
            _instance = _instance ? _instance : new DebugDaemon();
            _log_file = new File(File.applicationStorageDirectory.nativePath + File.separator + logfile_name + ".log");

            if (window) {
                window.addEventListener(Event.CLOSE, on_app_close);
            }
        }

        static public function get_instance():DebugDaemon {
            if (!_instance) {
                init();
            }

            return _instance;
        }

        static public function write_success(message:String, ... format):void {
            write_log.apply(null, [message, DebugDaemon.OK].concat(format));
        }

        static public function write_debug(message:String, ... format):void {
            write_log.apply(null, [message, DebugDaemon.DEBUG].concat(format));
        }

        static public function write_warning(message:String, ... format):void {
            write_log.apply(null, [message, DebugDaemon.WARN].concat(format));
        }

        static public function write_error(message:String, ... format):void {
            write_log.apply(null, [message, DebugDaemon.ERROR].concat(format));
        }

        static public function write_log(message:String, severity:uint = DebugDaemon.DEBUG, ... format):void {
            var prefix:String = "[".concat(new Date().toUTCString()).concat("]");
            var full_message:String = "";

            if (!_log) {
                _log = new Vector.<String>();
            }

            switch (severity) {
                case OK:
                    prefix = prefix.concat("[OK]");
                    break;
                case DEBUG:
                    prefix = prefix.concat("[DEBUG]");
                    break;
                case WARN:
                    prefix = prefix.concat("[WARN]");
                    break;
                case ERROR:
                    prefix = prefix.concat("[ERROR]");
                    break;
            }

            full_message = printf(prefix.concat(" ").concat(message), format);
            _log.push(full_message);

            if (severity == ERROR) {
                flush_log();
                throw new Error(full_message, severity);
            }
        }

        static public function flush_log():Boolean {
            _filestream.open(_log_file, FileMode.APPEND);
            for (var i:uint = 0; i < _log.length; i++) {
                try {
                    _filestream.writeUTFBytes(_log[i].concat("\n"));
                } catch (e:Error) {
                    write_log("error writing log file: %s", DebugDaemon.ERROR, e.message);
                }

            }

            _filestream.close();
            return true;
        }

        static private function on_app_close(e:Event):void {
            write_log("application terminated successfully.", OK);
            flush_log();
        }
    }
}

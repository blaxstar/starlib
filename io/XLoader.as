package net.blaxstar.starlib.io {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.utils.ByteArray;

    import thirdparty.org.osflash.signals.Signal;
    import flash.utils.getQualifiedClassName;
    import flash.display.Bitmap;
    import flash.filesystem.File;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import flash.net.FileFilter;

    /**
     * an elite loader for loading all kinds of content.
     * @author Deron Decamp (decamp.deron@gmail.com)
     *
     */

    public class XLoader {
        public const ON_ERROR:Signal = new Signal(String, String);
        public const ON_PROGRESS:Signal = new Signal(Number);
        public const ON_COMPLETE:Signal = new Signal(URL, ByteArray);
        public const ON_COMPLETE_GRAPHIC:Signal = new Signal(Object);
        private const _DIALOG_LOADER:File = File.documentsDirectory;

        private var _data:Vector.<ByteArray>;
        private var _queued_urls:Vector.<URL>;
        private var _loader_index:uint;
        private var _total_loaded:Number;
        private var _overall_total:Number;

        public function XLoader() {
            _data = new Vector.<ByteArray>;
            _queued_urls = new Vector.<URL>;
        }

        /**
         * opens a file dialog via the OS for loading a file with the specified file
         * filter(s).
         * @param title the title displayed on the dialog window.
         * @param filter an array of file filter strings, each in the format '*.ext'
         */
        public function load_file_dialog(on_file_select_callback:Function, on_file_cancel_callback:Function, title:String = "Load file...", filter:Array = null, filetype_description:String = "any"):void {

            var filefilter_array:Array = [];
            for (var i:uint = 0; i < filter.length; i++) {
                var current_filter:FileFilter = new FileFilter(filetype_description, filter[i]);
                filefilter_array.push(current_filter);
            }

            _DIALOG_LOADER.addEventListener(Event.SELECT, on_file_select_callback);
            _DIALOG_LOADER.addEventListener(Event.CANCEL, on_file_cancel_callback);
            _DIALOG_LOADER.browseForOpen(title, filefilter_array);
        }

        /**
         *
         * @param ...urls ...rest array of URL objects.
         */
        public function queue_files(... urls):void {
            if (!_queued_urls) {
                _queued_urls = new Vector.<URL>();
            } else if (_queued_urls.length == 0) {
                _total_loaded = _loader_index = 0;
            }

            for (var i:uint = 0; i < urls.length; i++) {
                var current_item:* = urls[i];

                if (current_item is URL) {
                    _queued_urls.push(current_item);
                    _overall_total += (current_item as URL).bytesTotal;
                } else {
                    DebugDaemon.write_error("could not queue files: one of the parameters is not a URL object (net.blaxstar.starlib.io::URL). got: %s", getQualifiedClassName(current_item));
                }
            }
            load_next();
        }

        public function get_loaded_data(name:String):ByteArray {
            for (var i:uint = 0; i < _queued_urls.length; i++) {
                if (_queued_urls[i].name == name)
                    return _data[i];
            }
            return null;
        }

        // * PRIVATE * /////////////////////////////////////////////////////////////

        private function load_next():void {
            var current_item:URL = _queued_urls[0];

            if (current_item.expected_data_type !== URL.GRAPHICS) {
                current_item.addEventListener(IOErrorEvent.IO_ERROR, on_io_error);
                current_item.addEventListener(SecurityErrorEvent.SECURITY_ERROR, on_security_error);
                current_item.addEventListener(ProgressEvent.PROGRESS, on_progress);
                current_item.addEventListener(Event.COMPLETE, on_complete);
                current_item.dataFormat = current_item.expected_data_type;
                current_item.connect();
            } else {
                IOUtil.loadExternalDisplayObject(current_item.endpoint_path, on_complete_graphic, on_progress, on_io_error);
            }
        }

        private function dispatch_overall_progress():void {
            if (_overall_total != 0) {
                ON_PROGRESS.dispatch(_total_loaded / _overall_total);
            }
        }

        private function null_current_loader_item(current_item:uint):void {
            _data[current_item] = null;
            _queued_urls[current_item].close();
            _queued_urls[current_item] = null;

            dispatch_overall_progress();
        }

        / * GETTERS & SETTERS * /;

        protected function get data_vector():Vector.<ByteArray> {
            return _data;
        }

        / * DELEGATES * /;

        private function on_io_error(e:IOErrorEvent):void {
            var target:URL = e.target as URL;

            ON_ERROR.dispatch(target.name, e.text);
            null_current_loader_item(_loader_index);
        }

        private function on_security_error(e:SecurityErrorEvent):void {
            var target:URL = e.target as URL;

            ON_ERROR.dispatch(target.name, e.text);
            null_current_loader_item(_loader_index);
        }

        private function on_progress(e:Event):void {
            _total_loaded += e.currentTarget.bytesLoaded - _total_loaded;
            dispatch_overall_progress();
        }

        private function on_complete(e:Event):void {
            var target:URL = e.target as URL;
            target.close();

            if (target.expected_data_type == URL.TEXT) {
                var ba:ByteArray = new ByteArray();
                ba.writeUTFBytes(target.data);
                ba.position = 0;
                target.data = ba;
            }
            _total_loaded += target.bytesLoaded;
            ON_COMPLETE.dispatch(target, target.data);
            prepare_next();
        }

        private function on_complete_graphic(e:Event):void {
            var graphic_data:* = e.currentTarget.content;
            ON_COMPLETE_GRAPHIC.dispatch(graphic_data);
            if (_queued_urls.length) {
                prepare_next();
            }
        }

        private function prepare_next():void {
            _queued_urls.removeAt(0);
            dispatch_overall_progress();

            if (_queued_urls.length > 0) {

                _loader_index++;
                load_next();
            }
        }
    }
}

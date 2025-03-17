package net.blaxstar.starlib.io {

    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    import net.blaxstar.starlib.debug.printf;
    import org.osflash.signals.Signal;
    import flash.net.FileFilter;
    import org.osflash.signals.natives.NativeSignal;

    /**
     * Utilities relating to the IO (input/output) of files.
     * @author Deron D.
     */
    public class IOUtil {
        static private const _FILESTREAM:FileStream = new FileStream();
        static private const _DIALOG_LOADER:File = File.documentsDirectory;
        static private var _on_complete_export_signal:Signal;
        static private var _on_complete_load_signal:Signal;
        static private var _on_dialog_load_select_signal:NativeSignal;
        static private var _on_dialog_load_cancel_signal:NativeSignal;
        static private var _on_dialog_save_select_signal:NativeSignal;
        static private var _on_dialog_save_cancel_signal:NativeSignal;
        static private var _on_display_object_complete_signal:NativeSignal;
        static private var _on_display_object_progress_signal:NativeSignal;
        static private var _on_display_object_error_signal:NativeSignal;

        /**
         * Loads an external DisplayObject (such as `SWF`, `JPEG`, `GIF`, or `PNG` files) using the `flash.display.Loader` class.
         * @param	url URL of the DisplayObject to load.
         * @param	onComplete Function to call when loading is complete.
         * @param	onProgress Function to call every time the loader progresses.
         * @param	onError Function to call if the loader encounters an error.
         */
        static public function load_external_display_object(url:String, on_complete:Function, on_progress:Function = null, on_error:Function = null):void {
            var display_object_loader:Loader = new Loader();

            _on_display_object_complete_signal ||= new NativeSignal(display_object_loader.contentLoaderInfo, Event.COMPLETE, Event);
            _on_display_object_complete_signal.add(on_complete);

            if (on_progress != null) {
                _on_display_object_progress_signal ||= new NativeSignal(display_object_loader.contentLoaderInfo, ProgressEvent.PROGRESS, ProgressEvent);
                _on_display_object_progress_signal.add(on_progress);
            }
            if (on_error != null) {
                display_object_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, on_error);
                _on_display_object_error_signal ||= new NativeSignal(display_object_loader.contentLoaderInfo, IOErrorEvent.IO_ERROR, IOErrorEvent);
                _on_display_object_error_signal.add(on_error);
            }

            display_object_loader.load(new URLRequest(url));
        }


        /**
         * opens a file dialog via the OS for loading a file with the specified file
         * filter(s).
         * @param title the title displayed on the dialog window.
         * @param filter an array of file filter strings, each in the format '*.ext'
         */
        static public function load_file_dialog(on_file_select_callback:Function, on_file_cancel_callback:Function = null, title:String = "Load file...", filter:Array = null, filetype_description:String = "any", multiple:Boolean=false):void {

            var filefilter_array:Array = [];
            for (var i:uint = 0; i < filter.length; i++) {
                var current_filter:FileFilter = new FileFilter(filetype_description, filter[i]);
                filefilter_array.push(current_filter);
            }

            _on_dialog_load_select_signal ||= new NativeSignal(_DIALOG_LOADER, Event.SELECT, Event);
            _on_dialog_load_cancel_signal ||= new NativeSignal(_DIALOG_LOADER, Event.CANCEL, Event);

            _on_dialog_load_select_signal.add(on_file_select_callback);

            if (on_file_cancel_callback != null) {
                _on_dialog_load_cancel_signal.add(on_file_cancel_callback);
            }

            if (multiple) {
                _DIALOG_LOADER.browseForOpenMultiple(title, filefilter_array);
            } else {
                _DIALOG_LOADER.browseForOpen(title, filefilter_array);
            }
        }

        /**
         * opens a file dialog via the OS for loading a file with the specified file
         * filter(s).
         * @param title the title displayed on the dialog window.
         * @param filter an array of file filter strings, each in the format '*.ext'
         */
        static public function save_file_dialog(on_file_select_callback:Function, on_file_cancel_callback:Function = null, title:String = "Save file..."):void {

            _on_dialog_save_select_signal ||= new NativeSignal(_DIALOG_LOADER, Event.SELECT, Event);
            _on_dialog_save_cancel_signal ||= new NativeSignal(_DIALOG_LOADER, Event.CANCEL, Event);

            _on_dialog_save_select_signal.add(on_file_select_callback);

            if (on_file_cancel_callback != null) {
                _on_dialog_save_cancel_signal.add(on_file_cancel_callback);
            }

            _DIALOG_LOADER.browseForSave(title);
        }

        /**
         * opens a file dialog via the OS for loading a folder.
         * filter(s).
         * @param title the title displayed on the dialog window.
         */
        static public function load_folder_dialog(on_folder_select_callback:Function, on_folder_cancel_callback:Function, title:String = "Load folder..."):void {

            _DIALOG_LOADER.addEventListener(Event.SELECT, on_folder_select_callback);

            _DIALOG_LOADER.addEventListener(Event.CANCEL, on_folder_cancel_callback);

            _DIALOG_LOADER.browseForDirectory(title);
        }

        static public function load_file(file:File, on_complete:Function):void {
            if (!file.exists) {
                throw new Error("file is null or does not exist.");
                return;
            }

            var bytes:ByteArray = new ByteArray();

            _FILESTREAM.open(file, FileMode.READ);
            _FILESTREAM.readBytes(bytes);
            _FILESTREAM.close();
            _on_complete_load_signal.dispatch(bytes);
        }

        static public function export_file(data:*, file:File, filemode:String = FileMode.UPDATE, on_complete:Function = null):void {

            var packed_bytes:ByteArray = new ByteArray();

            if (data is ByteArray) {
                packed_bytes = data;
            } else if (data is String) {
                packed_bytes.writeUTFBytes(data);
            } else if (data is int) {
                packed_bytes.writeInt(data);
            } else if (data is uint) {
                packed_bytes.writeUnsignedInt(data);
            } else if (data is Number) {
                packed_bytes.writeFloat(data);
            } else if (data is Boolean) {
                packed_bytes.writeBoolean(data);
            } else {
                packed_bytes.writeObject(data);
            }

            _FILESTREAM.open(file, filemode);
            _FILESTREAM.writeBytes(packed_bytes);
            _FILESTREAM.close();

            if (on_complete) {
                _on_complete_export_signal ||= new Signal();
                _on_complete_export_signal.add(on_complete);
                _on_complete_export_signal.dispatch();
            } else {
                printf("file write sucessful! %s%s @ %s", file.name, file.extension, file.parent.nativePath);
            }
        }

        /**
         * lists all the names of files in a directory.
         * @param	directory The directory to parse.
         * @return
         */
        static public function list_directory_filenames(directory:File):Vector.<String> {
            var name_list:Vector.<String> = new Vector.<String>();
            var files:Array = directory.getDirectoryListing();

            for (var i:int = 0; i < files.length; i++) {
                name_list.push(files[i].name);
            }
            return name_list;
        }

        /**
         * returns all of the files in a directory.
         * @param	directory The directory to parse.
         * @return
         */
        static public function get_directory_files(directory:File):Vector.<File> {
            var file_list:Vector.<File> = new Vector.<File>();
            var files:Array = directory.getDirectoryListing();

            for (var i:int = 0; i < files.length; i++) {
                file_list.push(files[i]);
            }
            return file_list;
        }

        /**
         * returns the names of all the files of a specific type within in a directory.
         * @param	path directory to check.
         * @param	filetype file extension to check for (e.g. exe, dmg, deb)
         * @return
         */
        static public function get_files_of_type_in_directory(directory:File, filetype:String):Vector.<String> {
            var file_list:Array = directory.getDirectoryListing();
            var files_of_type:Vector.<String> = new Vector.<String>();

            for (var i:int = 0; i < file_list.length; i++) {
                if (file_list[i].type == '.' + filetype) {
                    files_of_type.push(file_list[i].name);
                }
            }

            return files_of_type;
        }
    }
}

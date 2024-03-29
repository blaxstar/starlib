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

    /**
     * Utilities relating to the IO (input/output) of files.
     * @author Deron D.
     */
    public class IOUtil {
        /**
         * Loads an external DisplayObject (such as `SWF`, `JPEG`, `GIF`, or `PNG` files) using the `flash.display.Loader` class.
         * @param	url URL of the DisplayObject to load.
         * @param	onComplete Function to call when loading is complete.
         * @param	onProgress Function to call every time the loader progresses.
         * @param	onError Function to call if the loader encounters an error.
         */
        static public function loadExternalDisplayObject(url:String, on_complete:Function, on_progress:Function = null, on_error:Function = null):void {
            var displayObjectLoader:Loader = new Loader();

            displayObjectLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, on_complete);
            if (on_progress != null)
                displayObjectLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, on_progress);
            if (on_error != null)
                displayObjectLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, on_error);

            displayObjectLoader.load(new URLRequest(url));
        }

        static public function exportFile(target:*, filename:String, fileExtension:String = "", outputDirectory:String = "", on_complete:Function = null, filemode:String = FileMode.UPDATE):void {
            var packedBytes:ByteArray = new ByteArray();
            var stream:FileStream = new FileStream();
            var file:File = new File(File.applicationDirectory.nativePath);

            if (target is ByteArray) {
                packedBytes = target;
            } else if (target is String) {
                packedBytes.writeUTFBytes(target);
            } else if (target is Object || target is Array) {
                packedBytes.writeObject(target);
            }

            file = file.resolvePath(outputDirectory + File.separator + filename + fileExtension);
            stream.open(file, filemode);
            stream.writeBytes(packedBytes);
            stream.close();
            if (on_complete) {
                on_complete.apply(null, [0]);
            } else {
                printf("file write sucessful! %s%s @ %s", filename, fileExtension, outputDirectory);
            }
        }

        /**
         * lists all the names of files in a directory.
         * @param	directory The directory to parse.
         * @return
         */
        static public function listDirectoryFileNames(directory:File):Vector.<String> {
            var nameList:Vector.<String> = new Vector.<String>();
            var files:Array = directory.getDirectoryListing();

            for (var i:int = 0; i < files.length; i++) {
                nameList.push(files[i].name);
            }
            return nameList;
        }

        /**
         * returns all of the files in a directory.
         * @param	directory The directory to parse.
         * @return
         */
        static public function getDirectoryFiles(directory:File):Vector.<File> {
            var fileList:Vector.<File> = new Vector.<File>();
            var files:Array = directory.getDirectoryListing();

            for (var i:int = 0; i < files.length; i++) {
                fileList.push(files[i]);
            }
            return fileList;
        }

        /**
         * returns the names of all the files of a specific type within in a directory.
         * @param	path directory to check.
         * @param	filetype file extension to check for (e.g. exe, dmg, deb)
         * @return
         */
        static public function getFilesOfType(directory:File, filetype:String):Vector.<String> {
            var fileList:Array = directory.getDirectoryListing();
            var filesOfType:Vector.<String> = new Vector.<String>();

            for (var i:int = 0; i < fileList.length; i++) {
                if (fileList[i].type == '.' + filetype) {
                    filesOfType.push(fileList[i].name);
                }
            }

            return filesOfType;
        }
    }
}

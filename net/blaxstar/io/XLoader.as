package net.blaxstar.io {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;


import thirdparty.org.osflash.signals.Signal;

/**
	 * an elite loader for loading all kinds of content.
	 * @author Deron Decamp (decamp.deron@gmail.com)
	 * 
	 */
	
	public class XLoader {
		public const ON_ERROR:Signal    = new Signal(String, String);
		public const ON_PROGRESS:Signal = new Signal(Number);
		public const ON_COMPLETE:Signal = new Signal(URL, ByteArray);
		
		private var mData:Vector.<ByteArray>;
		private var mURLs:Vector.<URL>;
		private var _totalLoaded:Number;
		private var _overallTotal:Number;
		
		public function XLoader() {
			mData = new Vector.<ByteArray>;
			mURLs = new Vector.<URL>;
		}
		
		public function queueFiles(urlVector:Vector.<URL>):void {
			if (mURLs.length > 0) {
				for (var i:uint = 0; i < urlVector.length; i++) {
					mURLs.push(urlVector[i]);
					_overallTotal += urlVector[i].bytesTotal;
				}
			} else {
				mURLs = urlVector;
				_totalLoaded = 0;
				for (i = 0; i < mURLs.length; i++) {
					_overallTotal += mURLs[i].bytesTotal;
				}
				loadNext();
			}
		}
		
		private function loadNext():void {
			var currentItem:URL = mURLs[0];
			
			if (currentItem.type !== URL.GRAPHICS) {
				currentItem.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				currentItem.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				currentItem.addEventListener(ProgressEvent.PROGRESS, onProgress);
				currentItem.addEventListener(Event.COMPLETE, onComplete);
				currentItem.dataFormat = currentItem.type;
				currentItem.start();
			} else {
				IOUtil.loadExternalDisplayObject(currentItem.url, onComplete, onProgress, onIOError);
			}
		}
		
		private function dispatchOverallProgress():void {
			if (_overallTotal != 0) {
				ON_PROGRESS.dispatch(_totalLoaded / _overallTotal);
			}
		}
		
		public function getData(name:String):ByteArray {
			for (var i:uint = 0; i < mURLs.length; i++) {
				if (mURLs[i].name == name) return mData[i];
			}
			return null;
		}
		
		protected function get dataVector():Vector.<ByteArray> {
			return mData;
		}
		
		private function nullCurrentLoaderItem(targetID:uint):void {
			mData[targetID] = null;
			mURLs[targetID].close();
			mURLs[targetID] = null;
			
			dispatchOverallProgress();
		}
		
		private function onIOError(e:IOErrorEvent):void {
			var target:URL = e.target as URL;
			
			ON_ERROR.dispatch(target.name, e.text);
			nullCurrentLoaderItem(target.id);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			var target:URL = e.target as URL;
			
			ON_ERROR.dispatch(target.name, e.text);
			nullCurrentLoaderItem(target.id);
		}
		
		private function onProgress(e:ProgressEvent):void {
			var target:URL = e.target as URL;
			_totalLoaded += target.bytesLoaded - _totalLoaded;
			dispatchOverallProgress();
		}
		
		private function onComplete(e:Event):void {
			var target:URL = e.target as URL;
			target.close();
			
			if (target.type == URL.TEXT) {
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(target.data);
				ba.position = 0;
				target.data = ba;
			}
			_totalLoaded += target.bytesLoaded;
			mURLs.removeAt(0);
			ON_COMPLETE.dispatch(target, target.data);
			dispatchOverallProgress();
			if (mURLs.length > 0) loadNext();
		}
	
	}
}
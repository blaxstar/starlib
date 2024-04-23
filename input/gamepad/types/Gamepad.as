package net.blaxstar.starlib.input.gamepad.types {
import flash.ui.GameInputDevice;
import net.blaxstar.starlib.debug.DebugDaemon;

/**
	 * A class abstracting away the input controls for a single controller.
	 */
	public class Gamepad implements IGamepad {
		
		/** The underlying source game device. */
		public var device:GameInputDevice;
		/** A flag indicating if this controller was removed (no longer usable). */
		public var removed:Boolean = false;
		protected var _type:uint;
		
		/** Creates a game controller and binds the controlers to the source device. */
		public function Gamepad(device:GameInputDevice) {
			this.device = device;
			bind_controls();
		}
		
		/**
		 * Sets the enabled flag to true.
		 */
		public function enable():void {
			device.enabled = true;
		}
		
		/**
		 * Sets the enabled flag to false.
		 */
		public function disable():void {
			device.enabled = true;
		}
		
		/**
		 * Sets the controller as removed.
		 */
		public function remove():void {
			removed = true;
		}
		
		/**
		 * Resets all the inputs on the controller. Useful after a state change when you don't want the inputs to trigger in the new state.
		 */
		public function reset():void {
      DebugDaemon.write_error("implement reset() in each GamePad subclass!");
		}
		
		/**
		 * Private method that is called on initialization. All control bindings should go in this method.
		 */
		protected function bind_controls():void {
			DebugDaemon.write_error("implement bind_controls() in each GameController subclass!");
		}
		
		public function get type():uint {
			return _type;
		}
	}
}

package net.blaxstar.starlib.debug.terminal.commands {
    import net.blaxstar.starlib.debug.terminal.commands.TerminalCommand;
    import flash.utils.Dictionary;
    import net.blaxstar.starlib.utils.Strings;

    public class EvalObjectCommand extends TerminalCommand {
        private static var _registry:Dictionary;

        public function EvalObjectCommand() {
            super("eval", eval);
        }

        public static function register_object(name:String, object:*):void {
            if (!_registry) {
                _registry = new Dictionary();
            }

            _registry[name] = object;
        }

        public function eval(query:String):String {
            query = Strings.trim(query);
            var properties:Array = query.split(".");
            var object_name:String = properties.shift();
            var accessible_property:Object;

            if (_registry.hasOwnProperty(object_name)) {
              accessible_property = _registry[object_name];
              for (var i:uint = 0; i < properties.length; i++) {
                if (accessible_property.hasOwnProperty(properties[i])) {
                  accessible_property = accessible_property[properties[i]];
                  object_name = object_name + "." + properties[i];
                } else if (accessible_property.hasOwnProperty(String(properties[i]).toLowerCase())) {
                  var lowercase_property:String = String(properties[i]).toLowerCase();
                  accessible_property = accessible_property[lowercase_property];
                  object_name = object_name + "." + lowercase_property;
                } else {
                  return object_name + "." + properties[i] + " is not an accessible property: " + properties[i] + " is inaccessible!";
                }
              }
              properties.length = 0;
            }
            if (accessible_property != null) {
              return String(accessible_property);
            }
            return "null";
        }
    }


}

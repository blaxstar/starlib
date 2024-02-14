package net.blaxstar.starlib.components {
    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.Card;
    import net.blaxstar.starlib.components.List;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import net.blaxstar.starlib.components.ListItem;
    import flash.utils.Dictionary;
    import debug.DebugDaemon;
    import geom.Point;

    public class ContextMenu extends Component {

        private var _card:Card;
        private var _list:List;
        private var _current_context:String;
        private var _context_directory:Dictionary;

        public function ContextMenu(parent:DisplayObjectContainer = null, xpos:uint = 0, ypos:uint = 0) {
            super(parent, xpos, ypos);
        }

        override public function init():void {
            _list = new List(this);
            _context_directory = new Dictionary();
            _current_context = "default";
            super.init();
        }

        override public function draw(e:Event = null):void {
            //_card.set_size(_list.width, _list.height);
        }

        public function add_context_item(label:String, action:Function, context:String = 'default'):void {

            var item:ListItem = new ListItem();
            item.label = label;
            item.on_click.add(action);

            if (!has_context(context)) {
                _context_directory[context] = [item];
            } else {
                (_context_directory[context] as Array).push(item);
            }

            if (_list.num_items > 0 && _current_context !== context) {
                _list.cache_current_list(_current_context);
                _list.clear();
            }

            _list.add_item(item);
            _current_context = context;
            draw();
        }

        public function add_context_array(context_items:Array, context:String, on_click:Function):void {
            for (var i:uint = 0; i < context_items.length; i++) {
                add_context_item(context_items[i], on_click, context);
            }
        }

        public function add_context(context_id:String):void {
            if (has_context(context_id)) {
                DebugDaemon.write_log("cannot add context: the context name already exists in this object!", DebugDaemon.ERROR_GENERIC);
                return;
            } else {
                _context_directory[context_id] = [];
            }
        }

        public function has_context(context_id:String):Boolean {
            return _context_directory[context_id] != null;
        }

        public function set_context(context_id:String):void {
            if (has_context(context_id)) {
                _current_context = context_id;

                if (_list.has_cached_group(context_id)) {
                    _list.set_from_cache(context_id);
                } else {
                    DebugDaemon.write_log("failed to set context: the context was not registered to this menu! got: %s", DebugDaemon.WARN, context_id);

                }
            } else {
                DebugDaemon.write_log("failed to set context: the specified context does not exist in this object! please use add_context. got: %s", DebugDaemon.ERROR_GENERIC, context_id);
            }
        }

        public function show():void {
            _list.set_from_cache(_current_context);
            _list.show_items();
        }

        public function hide(cache_list_to_context:Boolean = false):void {
            if (cache_list_to_context && !_list.has_cached_group(_current_context)) {
                _list.cache_current_list(_current_context);
            }
            _list.hide_items();
        }

        public function clear_selection():void {
            _list.deselect_all_items();
        }
    }
}

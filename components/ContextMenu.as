package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.components.Card;
    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.List;
    import net.blaxstar.starlib.components.ListItem;
    import net.blaxstar.starlib.debug.DebugDaemon;

    public class ContextMenu extends Component {

        private var _card:Card;
        private var _list:List;
        private var _current_context:String;
        private var _context_cache:Dictionary;

        public function ContextMenu(parent:DisplayObjectContainer = null, xpos:uint = 0, ypos:uint = 0) {
            super(parent, xpos, ypos);
        }

        override public function init():void {
            _list = new List(this);
            _context_cache = new Dictionary();
            _current_context = "default";
            super.init();
        }

        override public function draw(e:Event = null):void {
        }

        public function add_context_item(label:String, action:Function, context:String = "default"):void {

            var item:ListItem = new ListItem();
            item.label = label;
            item.on_click.add(action);

            if (!has_context(context)) {
                _context_cache[context] = [item];
            } else {
                (_context_cache[context] as Array).push(item);
            }
            // we'll update the context and list here, but first we'll cache the context items for the current context so we can quickly retrieve them later
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
                DebugDaemon.write_warning("cannot add context: the context name already exists in this object!");
                return;
            } else {
                _context_cache[context_id] = [];
            }
        }

        public function has_context(context_id:String):Boolean {
            return _context_cache[context_id] != null;
        }

        public function set_context(context_id:String):void {
            if (has_context(context_id)) {
                _current_context = context_id;

                if (_list.has_cached_group(context_id)) {
                    _list.apply_cached_list(context_id);
                } else {
                    DebugDaemon.write_warning("failed to set context: the context was not registered to this menu! got: %s", context_id);

                }
            } else {
                DebugDaemon.write_warning("failed to set context: the specified context does not exist in this object! please use add_context. got: %s", context_id);
            }
        }

        public function show():void {
            _list.apply_cached_list(_current_context);
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

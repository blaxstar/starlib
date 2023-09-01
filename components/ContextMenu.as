package net.blaxstar.starlib.components {
    import net.blaxstar.starlib.components.Component;
    import net.blaxstar.starlib.components.Card;
    import net.blaxstar.starlib.components.List;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import net.blaxstar.starlib.components.ListItem;
    import flash.utils.Dictionary;
    import debug.DebugDaemon;

    public class ContextMenu extends Component {

        private var _card:Card;
        private var _list:List;
        private var _current_context:String;
        private var _context_directory:Dictionary;

        public function ContextMenu(parent:DisplayObjectContainer, xpos:uint = 0, ypos:uint = 0) {
            super(parent, xpos, ypos);
        }

        override public function init():void {
            _card = new Card(this);
            _list = new List(_card);
            _context_directory = new Dictionary();
            _current_context = "default";
            _card.setSize(50, PADDING);
            super.init();
        }

        override public function draw(e:Event = null):void {
            _list.draw();
            _card.setSize(_list.width, _list.height);
        }

        public function add_context_item(label:String, action:Function, context:String = 'default'):void {
            var item:ListItem = new ListItem();
            item.label = label;
            item.on_click.add(action);
            _list.multi_add([[label, action]]);

            if (!has_context(context)) {
                _context_directory[context] = [item];
            } else {
                (_context_directory[context] as Array).push(item);
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
            return _context_directory[context_id];
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
            _card.visible = true;
            _list.show_items();
        }

        public function hide(cache_list_to_context:Boolean = false):void {
            if (cache_list_to_context) {
                _list.cache_current_list(_current_context);
            }
            _list.hide_items();
            _card.visible = false;
        }

    }
}

package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;

    import net.blaxstar.starlib.style.Style;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.utils.StringUtil;
    import net.blaxstar.starlib.style.Color;
    import thirdparty.com.greensock.TweenLite;

    /**
     * ...
     * @author Deron Decamp
     */
    public class List extends Component {
        private const PADDING:uint = 7;

        private var _list_width:uint;
        private var _item_height:uint;
        private var _items:Vector.<ListItem>;
        private var _group_cache:Dictionary;
        private var _items_cache:Dictionary;
        private var _item_container:VerticalBox;
        private var _max_visible:uint;
        private var _selection_indicator:LED;
        private var _background_card:Card;
        private var _selected_item:ListItem;
        private var _use_selection_indicator:Boolean;
        private var _alternating_colors:Boolean;
        private var _custom_delegates:Vector.<Function>;
        private var _default_fill:uint;

        public function List(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, altColors:Boolean = false) {
            super(parent, xpos, ypos);
            _alternating_colors = altColors;
            _default_fill = Style.SURFACE.value;
        }

        override public function init():void {
            _width_ = _list_width = 200;
            _height_ = _item_height = 35;
            _items = new Vector.<ListItem>();
            _group_cache = new Dictionary();
            _items_cache = new Dictionary();
            super.init();
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {
            _item_container = new VerticalBox();
            _item_container.spacing = 0;
            _background_card = new Card(this, 0, 0, false);
            _background_card.width = _list_width;
            super.addChild(_item_container);
            super.add_children();
            _item_container.addEventListener(MouseEvent.RELEASE_OUTSIDE, on_item_rollout);
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {
            if (_item_container.numChildren > 0) {
                _item_container.removeChildren();
            }

            for (var i:uint; i < _items.length; i++) {
                _item_container.addChild(_items[i]);
                _width_ = Math.max(_list_width, _items[i].label_component.width + PADDING);
            }

            _height_ = _background_card.height = _item_container.height;
            _background_card.width = _list_width;
            deselect_all_items();
            super.draw();
        }

        override public function update_skin():void {
            _default_fill = Style.SURFACE.value;
        }

        public function add_item(list_item:ListItem):List {
            if (list_item != null) {

                _items.push(list_item);
                list_item.set_size(_list_width, _item_height + PADDING);
                list_item.on_resize_signal.add(on_item_resize);
                list_item.on_rollover.add(on_item_rollover);
                list_item.on_rollout.add(on_item_rollout);
                list_item.on_click.add(on_item_click);
                list_item.mouseChildren = false;

                if (_custom_delegates) {
                    for (var j:uint = 0; j < _custom_delegates.length; j++) {
                        list_item.on_click.add(_custom_delegates[j]);
                    }
                    _item_container.addChild(list_item);
                }
                draw();
            }
            return this;
        }

        public function add_item_at(li:ListItem, index:uint = 0):List {
            if (li) {
                _items.splice(index, 0, li);
                commit();
            }
            return this;
        }

        public function multi_add_string_array(itemStringArray:Array, listener:Function = null):void {
            for (var i:uint = 0; i < itemStringArray.length; i++) {

                if (itemStringArray[i] is String) {
                    var new_list_item:ListItem = new ListItem(null, 0, 0, itemStringArray[i]);
                    new_list_item.width = _list_width;
                    add_item(new_list_item);

                    if (listener) {
                        new_list_item.on_click.add(listener);
                    }
                }
            } // end for
        }

        /**
         * @param items an array of tuples (string,function).
         */
        public function multi_add(items:Array):void {
            // time for edge cases!
            // lets make sure that this is an array of tuples...
            for (var i:uint = 0; i < items.length; i++) {
                if (!(items[i] is Array)) {
                    DebugDaemon.write_error("cannot multi add items to list: an item is of an invalid type!");
                    return;
                } else if (((items[i] as Array).length !== 2)) {
                    DebugDaemon.write_error("cannot multi add items to list: one of the parameters are invalid! got: %s", StringUtil.from_array(items[i]));
                    return;
                }

                var current_item:Array = items[i];
                // ...then enforce the tuple type.
                if (!(current_item[0] is String) || !(current_item[1] is Function)) {
                    DebugDaemon.write_error("cannot multi add items to list: one of the parameters are invalid! got %s, expected [String, Function]", StringUtil.from_array(current_item));
                    return;
                }

                var list_item:ListItem = new ListItem();
                list_item.label = current_item[0];
                list_item.on_click.add(current_item[1]);
                add_item(list_item);
            }
        }

        public function get_cached_item(id:uint):ListItem {
            var list_item:ListItem;

            if (has_cached_item(id)) {
                return _items_cache[id] as ListItem;
            }

            return null;
        }

        public function cache_item(item:ListItem):void {
            if (has_cached_item(item.linkage_id)) {
                return;
            } else {
                _items_cache[item.linkage_id] = item;
            }
        }

        public function has_cached_item(item_id:uint):Boolean {
            return _items_cache[item_id];
        }

        public function has_cached_group(group_name:String):Boolean {
            return _group_cache[group_name];
        }

        public function cache_current_list(group_name:String):void {
            if (!has_cached_group(group_name)) {
                _group_cache[group_name] = [];
            }

            for (var i:uint = 0; i < _items.length; i++) {
                (_group_cache[group_name] as Array).push(_items[i]);
                _items[i].in_cache = true;
            }
        }

        public function set_from_cache(group_name:String):void {
            if (has_cached_group(group_name)) {
                clear();
                var group:Array = _group_cache[group_name] as Array;

                for (var i:uint = 0; i < group.length; i++) {
                    _items.push(group[i]);
                    _item_container.addChild(group[i]);
                }
            }
            draw();
        }

        public function hide_items(e:MouseEvent = null):void {
            this.visible = false;
        }

        public function show_items():void {
            this.visible = true;
        }

        public function set_selection(item_index:uint):void {
            select_item(_item_container.getChildAt(item_index) as ListItem);
        }

        public function add_delegate_to_all(func:Function):void {
            _custom_delegates ||= new Vector.<Function>();
            _custom_delegates.push(func);
            for (var i:uint; i < _items.length; i++) {
                _items[i].on_click.add(func);
            }
        }

        public function remove_delegate_from_all(func:Function):void {
            for (var i:uint; i < _items.length; i++) {
                _items[i].on_click.remove(func);
            }
        }

        public function clear():void {
            _items.length = 0;
            _item_container.removeChildren();
            draw();
        }

        public function get_item_at(itemIndex:uint):ListItem {
            return _items[itemIndex];
        }

        public function deselect_all_items():void {
            _background_card.clear_highlight();
        }

        override public function destroy():void {

            for (var i:uint = 0; i < _items.length; i++) {
                _item_container.removeChildren();
                var child:ListItem = _items[i];
                child.on_resize_signal.remove(on_item_resize);
                child.on_click.removeAll();
            }
        }

        / * PRIVATE METHODS * /;

        private function select_item(list_item:ListItem):void {
            _background_card.mouseChildren = false;
        }

        / * GETTERS, SETTERS * /;

        public function get num_items():uint {
            return _item_container.numChildren;
        }

        override public function set width(value:Number):void {
            _list_width = value;
            super.width = value;
        }

        public function set item_height(val:Number):void {
            if (val > 0) {
                _item_height = val;
                _background_card.height = _item_height;
            }
            draw();
        }

        public function get selected_item():ListItem {
            return _selected_item;
        }

        public function set use_selection_indicator(val:Boolean):void {
            _use_selection_indicator = val;
            if (_use_selection_indicator) {
                add_selection_indicator_delegates();
            } else {
                remove_selection_indicator_delegates();
            }
        }

        / * DELEGATES * /;

        private function on_item_rollout(e:MouseEvent):void {
            deselect_all_items();
        }

        private function on_item_rollover(e:MouseEvent = null):void {
            var list_item:ListItem = (e.currentTarget as ListItem);
            deselect_all_items();
            select_item(list_item);
        }

        private function on_item_click(e:MouseEvent):void {
            _selected_item = e.currentTarget as ListItem;
            hide_items();
        }

        private function on_item_resize(e:Event = null):void {
            draw();
        }

        private function add_selection_indicator_delegates():void {
            for (var i:uint = 0; i < _items.length; i++) {
                _items[i].on_click.add(on_item_click);
            }
        }

        private function remove_selection_indicator_delegates():void {
            for (var i:uint = 0; i < _items.length; i++) {
                _items[i].on_click.remove(on_item_click);
            }
        }

    } // end class
} // end package

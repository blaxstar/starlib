package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.style.Style;

    /**
     * ...
     * @author Deron Decamp
     */
    public class Dropdown extends Component {
        private const MIN_HEIGHT:uint = 30;
        private const MIN_WIDTH:uint = 100;
        private var _display_label:PlainText;
        private var _label_fill:Sprite;
        private var _label_text:String;
        private var _default_label:String;
        private var _dropdown_button:Button;
        private var _list_component:List;
        private var _selected_item:ListItem;
        private var _list_visible:Boolean;

        public function Dropdown(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, default_label:String = "Select an Item") {
            _label_text = _default_label = default_label;
            super(parent, xpos, ypos);
        }

        override public function init():void {
            _width_ = MIN_WIDTH;
            _height_ = MIN_HEIGHT;
            buttonMode = useHandCursor = true;
            super.init();
        }

        override public function add_children():void {
            _display_label = new PlainText(this, 0, 0, _label_text);
            _display_label.width = _width_;

            _dropdown_button = new Button(this, _display_label.width, 0);
            _dropdown_button.icon = Icon.EXPAND_DOWN_CIRCLED;
            _dropdown_button.set_size(MIN_HEIGHT, MIN_HEIGHT);
            _dropdown_button.get_icon().set_color(Style.TEXT.to_hex_string());
            _dropdown_button.on_click.add(on_click);

            _list_component ||= new List(null, 0, _display_label.height + PADDING);
            _list_component.width = _display_label.width;
            _list_component.add_delegate_to_all(on_list_item_click);
            _label_fill = new Sprite();
            _display_label.addEventListener(Event.RESIZE, on_label_resize);

            super.add_children();
        }

        // ! PUBLIC ! //

        override public function draw(e:Event = null):void {
            if (_list_visible) {
                _height_ = MIN_HEIGHT + _list_component.height;
            } else {
                _height_ = MIN_HEIGHT;
            }
            _display_label.text = _label_text;
            _display_label.move(PADDING/2, PADDING/2);
            _dropdown_button.move(_display_label.x + _display_label.width + (PADDING/2), 0);
            _width_ = _display_label.width + PADDING + _dropdown_button.width;
            draw_border();


            if (_list_component.num_items == 1) {
                _selected_item = _list_component.get_item_at(0);
            }


            dispatchEvent(_resize_event_);
            super.draw(e);
        }

        public function add_list_item(item:ListItem):void {
            _list_component.add_item(item);
        }

        /**
         * Create Dropdown items from an array of tuples.
         * @param ...tuple_array an array of tuples (string, function).
         */
        public function multi_add(... tuple_array):void {
            _list_component.multi_add(tuple_array);
        }

        /**
         * Creates Dropdown items from an array of strings, with a single optional listener.
         * @param ...string_array an array of strings for each label in the list.
         * @param optional_listener a single listener for handling item clicks with the items created from `string_array`.
         */
        public function multi_add_string_array(string_array:Array, optional_listener:Function = null):void {
            _list_component.multi_add_string_array(string_array, optional_listener);
        }

        public function hide_list():void {
            _list_component.hide_items();
        }

        public function reset():void {
            _selected_item = null;
            _label_text = _default_label;
            commit();
        }

        // ! PRIVATE ! //

        private function draw_border():void {
            var g:Graphics = _label_fill.graphics;
            g.clear();
            g.beginFill(Style.SURFACE.value, 1);
            g.lineStyle(2, Style.SECONDARY.value);
            g.drawRoundRect(0, 0, _width_, MIN_HEIGHT, 7, 7);
            g.endFill();
            if (!_label_fill.parent) {
                addChild(_label_fill);
                _label_fill.addEventListener(MouseEvent.CLICK, on_click);
            }
            setChildIndex(_label_fill, 0);
        }

        // ! GETTERS & SETTERS ! //

        public function get value():String {
            return _label_text;
        }

        public function set value(value:String):void {
            _label_text = value;
            commit();
        }

        // ! DELEGATE FUNCTIONS ! //
        private function on_label_resize(event:Event):void {
            commit();
        }

        private function on_list_item_click(e:MouseEvent):void {
            _selected_item = e.currentTarget as ListItem;
            _label_text = _selected_item.label;
            on_click();
        }

        private function on_click(e:MouseEvent=null):void {
            if (!_list_component.parent) {
                addChild(_list_component);
                _list_visible = false;
            }

            if (_list_visible) {
              _list_component.hide_items();
            } else {
              _list_component.show_items();
            }
            _list_visible = !_list_visible;
            
            commit();
        }
    }

}

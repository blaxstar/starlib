package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.style.Style;
    import flash.display.Stage;
    import flash.display.Shape;
    import flash.display.Sprite;

    /**
     * ...
     * @author Deron Decamp
     */
    // TODO (dyxribo, STARLIB-6): implement dropdown component
    public class Dropdown extends Component {
        private const MIN_HEIGHT:uint = 30;
        private const MIN_WIDTH:uint = 150;
        private var _displayLabel:PlainText;
        private var _labelFill:Sprite;
        private var _labelText:String;
        private var _dropdownButton:Button;
        private var _list_component:List;
        private var _selectedItem:ListItem;

        public function Dropdown(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, initLabel:String = "Select an Item") {
            _labelText = initLabel;
            super(parent, xpos, ypos);
        }

        /** INTERFACE net.blaxstar.starlib.components.IComponent ===================== */

        /**
         * initializes the component by adding all the children and committing the visual changes to be written on the next frame. created to be overridden.
         */
        override public function init():void {
            _width_ = MIN_WIDTH;
            _height_ = MIN_HEIGHT;
            buttonMode = useHandCursor = true;
            super.init();
        }

        /**
         * base method for initializing and adding children of the component. created to be overridden.
         */
        override public function add_children():void {
            _displayLabel = new PlainText(this, 0, 0, _labelText);
            _displayLabel.width = _width_;

            _dropdownButton = new Button(this, _displayLabel.width, 0);
            _dropdownButton.icon = Icon.EXPAND_DOWN;
            _dropdownButton.set_size(MIN_HEIGHT, MIN_HEIGHT);

            var buttonIcon:Icon = _dropdownButton.get_icon();
            buttonIcon.set_color(Style.TEXT.value.toString(16));
            _dropdownButton.on_click.add(onClick);

            _list_component ||= new List(null, 0, _displayLabel.height - 2);
            _list_component.visible = false;
            _list_component.width = _displayLabel.width;
            _list_component.add_delegate_to_all(onListItemClick);

            super.add_children();
        }

        private function onListItemClick(e:MouseEvent):void {
            _selectedItem = e.currentTarget as ListItem;
            _labelText = _selectedItem.label;
            draw();
        }

        private function onClick(e:MouseEvent):void {
            if (!_list_component.parent) {
                addChild(_list_component);
            }
            _list_component.visible = !_list_component.visible;

            draw();
        }

        /**
         * base method for (re)drawing the component itself. created to be overridden.
         */
        override public function draw(e:Event = null):void {
            if (_list_component.visible) {
                _height_ = MIN_HEIGHT + _list_component.height;
            } else {
                _height_ = MIN_HEIGHT;
            }

            drawBorder();

            if (_list_component.num_items == 1) {
                _selectedItem = _list_component.get_item_at(0);
            }

            _displayLabel.text = _labelText;

            super.draw(e);
        }

        private function drawBorder():void {
            _labelFill = new Sprite();
            var g:Graphics = _labelFill.graphics;
            g.clear();
            g.lineStyle(2, Style.SECONDARY.value);
            g.beginFill(Style.SURFACE.value, 1);
            g.drawRoundRect(0, 0, _width_, MIN_HEIGHT, 7, 7);
            g.endFill();
            if (!_labelFill.parent) {
                addChild(_labelFill);
                _labelFill.addEventListener(MouseEvent.CLICK, onClick);
            }
            setChildIndex(_labelFill, 0);
        }

        /** END INTERFACE ===================== */
        // public

        public function add_list_item(item:ListItem):void {
            _list_component.add_item(item);
        }

        /**
         *
         * @param ...tuple_array an array of tuples (string, function).
         */
        public function multi_add(... tuple_array):void {
            _list_component.multi_add(tuple_array);
        }

        /**
         *
         * @param ...string_array an array of strings for each label in the list.
         */
        public function multi_add_string_array(string_array:Array, optional_listener:Function=null):void {
            _list_component.multi_add_string_array(string_array, optional_listener);
        }
        // private
        // getters/setters

        public function get value():String {
            return _labelText;
        }
        // delegate functions
    }

}

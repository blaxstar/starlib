package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import thirdparty.org.osflash.signals.Signal;
    import flash.sampler._getInvocationCount;
    import flash.display.Sprite;
    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.events.MouseEvent;

    /**
     * ...
     * @author Deron Decamp
     */
    public class Dialog extends Component {
        static private const MIN_WIDTH:uint = 200;
        static private const MIN_HEIGHT:uint = 200;
        static public const OPTION_EMPHASIS_LOW:uint = 0;
        static public const OPTION_EMPHASIS_HIGH:uint = 1;
        /* TODO:
           . create a vector of dialogs that are inactive, and a variable for the current active dialog.
           . keep track of the currently active one via a `currentlyActive` property.
           . when a dialog is clicked (mousedown), move `currentlyActive` to the inactive vector, then set the clicked dialog to `currentlyActive`.
           also bring the currently active to the front.
           . also make a `pin()` method, which will always ensure the dialog is on top. only one dialog should be pinned at a time, since multiple cannot possibly be placed at the same index.
         */
        private var _dialog_card:Card;
        private var _mask:Sprite;
        private var _child_dialog_vector:Vector.<Dialog>;
        private var _component_container:VerticalBox;
        private var _text_container:VerticalBox;
        private var _option_container:HorizontalBox;
        private var _prev_parent_container:DisplayObjectContainer;
        private var _title_textfield:PlainText;
        private var _message_textfield:PlainText;
        private var _title_string:String;
        private var _message_string:String;
        private var _draggable:Boolean;
        private var _auto_resize:Boolean;
        private var _on_close:Signal;
        private var _on_mouse_up_signal:NativeSignal;
        private var _on_mouse_down_signal:NativeSignal;

        public function Dialog(parent:DisplayObjectContainer = null, title:String = '', message:String = '') {
            _title_string = title;
            _message_string = message;
            _on_close = new Signal();
            super(parent);
        }

        // * PUBLIC * //
        /**
         * initializes the component by adding all the children
         * and committing the visual changes to be written on the next frame.
         * created to be overridden.
         */
        override public function init():void {
            _width_ = MIN_WIDTH;
            _height_ = MIN_HEIGHT;
            super.init();
        }

        override protected function on_added(e:Event):void {
            _prev_parent_container = parent;
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {
            _dialog_card = new Card();
            super.addChild(_dialog_card);

            _mask = new Sprite();
            _mask.mouseEnabled = false;
            super.addChild(_mask);

            super.addChild(_dialog_card);
            _dialog_card.mask = _mask;

            _text_container = new VerticalBox();
            _title_textfield = new PlainText();
            _message_textfield = new PlainText();

            _title_textfield.enabled = false;
            _title_textfield.text = _title_string;
            _message_textfield.text = _message_string;
            _dialog_card.draggable = false;
            this.draggable = true;
            _dialog_card.auto_resize = false;

            _dialog_card.add_child_native(_text_container);
            _text_container.addChild(_title_textfield);
            _text_container.addChild(_message_textfield);
            // cache the containers, no need to keep accessing them via dot
            _component_container = _dialog_card.component_container;
            _option_container = _dialog_card.option_container;
            _component_container.addEventListener(Event.RESIZE, on_card_resize);
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {
            if (_title_textfield.text != _title_string) {
                _title_textfield.text = _title_string;
            }

            if (_message_textfield.text != _message_string) {
                _message_textfield.text = _message_string;
            }

            if (_auto_resize) {
                _width_ = (PADDING * 2) + Math.max(_text_container.width, _component_container.width, _option_container.width);
                _height_ = (PADDING * 3) + _text_container.height + _component_container.height + _option_container.height;
                _dialog_card.set_size(_width_, _height_);
                _text_container.move(PADDING, PADDING);
                _component_container.move(PADDING, _text_container.y + _text_container.height);
                _option_container.move(PADDING, _component_container.y + _component_container.height + PADDING);
                dispatchEvent(new Event(Event.RESIZE));
            } else {
                _dialog_card.set_size(_width_, _height_);
                _component_container.move(PADDING, _text_container.y + _text_container.height + PADDING);
                _option_container.move(PADDING, _component_container.y + _component_container.height + PADDING);
                super.draw(e);
            }

            _mask.graphics.clear();
            _mask.graphics.beginFill(0xff0000);
            _mask.graphics.drawRoundRect(0, 0, _width_, _height_, 7);
            _mask.graphics.endFill();

        }

        private function on_card_resize(e:Event = null):void {
            commit();
        }

        public function add_component(val:DisplayObject):DisplayObject {
            var c:DisplayObject = _dialog_card.add_child_to_container(val);
            commit();
            return c;
        }

        public function add_button(name:String, action:Function = null, emphasis:uint = Button.GROUNDED):Button {

            var b:Button = new Button(_dialog_card.option_container, 0, 0, name.toUpperCase());

            if (action != null) {
                b.add_click_listener(action);
            }

            b.style = emphasis;

            commit();

            return b;
        }

        public function push_dialog(dialog:Dialog):void {
            if (!_child_dialog_vector) {
                _child_dialog_vector = new Vector.<Dialog>();
            }

            _child_dialog_vector.push(dialog);
            dialog.move(this.x + PADDING, this.y + PADDING);
            enabled = false;
            dialog.open();
        }

        public function pop_dialog():Dialog {
            return _child_dialog_vector.pop();
        }

        override public function addChild(child:DisplayObject):DisplayObject {
            return _component_container.addChild(child);
        }

        override public function move(x_position:Number, y_position:Number):void {
            if (_child_dialog_vector && _child_dialog_vector.length) {
                for (var i:int = 0; i < _child_dialog_vector.length; i++) {
                    _child_dialog_vector[i].move(x_position + PADDING, y_position + PADDING);
                }
            }
            super.move(x_position, y_position);
        }

        override public function set_size(w:Number, h:Number):void {
            _dialog_card.set_size(w, h);
            super.set_size(w, h);
        }

        override public function set width(value:Number):void {
            _dialog_card.width = value;
            super.width = value;
        }

        override public function set height(value:Number):void {
            _dialog_card.height = value;
            super.height = value;
        }

        // * DELEGATE FUNCTIONS * //


        private function on_mouse_down(e:MouseEvent = null):void {
            _on_mouse_down_signal.remove(on_mouse_down);
            this.startDrag();
            if (!_on_mouse_up_signal)
                _on_mouse_up_signal = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent);
            _on_mouse_up_signal.add(on_mouse_up);
        }

        private function on_mouse_up(e:MouseEvent = null):void {
            _on_mouse_up_signal.remove(on_mouse_up);
            this.stopDrag();

            if (!_on_mouse_down_signal) {
                _on_mouse_down_signal = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
            }

            _on_mouse_down_signal.add(on_mouse_down);
        }

        // * GETTERS & SETTERS * //


        public function set title(val:String):void {
            _title_string = (val.length > 0) ? val : _title_string;
            commit();
        }

        public function get title():String {
            return _title_string;
        }

        public function set message(val:String):void {
            _message_string = (val.length > 0) ? val : _message_string;
            commit();
        }

        public function get message():String {
            return _message_string;
        }

        public function get onClose():Signal {
            return _on_close;
        }

        public function set viewableItems(val:uint):void {
            _dialog_card.viewable_items = val;
        }

        public function set maskThreshold(val:Number):void {
            _dialog_card.mask_threshold = val;
        }

        public function get draggable():Boolean {
            return _draggable;
        }

        public function set draggable(val:Boolean):void {
            _draggable = val;

            if (_draggable) {
                _on_mouse_down_signal ||= new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
                _on_mouse_down_signal.add(on_mouse_down);
            }
        }

        public function close(e:Event = null):void {
            if (parent) {
                parent.removeChild(this);
                _on_close.dispatch();
            }
        }

        public function open():void {
            if (_prev_parent_container != null) {
                _prev_parent_container.addChild(this);
            }
        }

        public function removeOptions():void {
            _dialog_card.option_container.removeChildren();
        }

        public function set auto_resize(val:Boolean):void {
            _auto_resize = val;
            commit();
        }

        public function get active():Boolean {
            return parent && enabled;
        }

        public function get component_container():VerticalBox {
            return _dialog_card.component_container;
        }

        public function get option_container():HorizontalBox {
            return _dialog_card.option_container;
        }
    }

}

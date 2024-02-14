package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import thirdparty.org.osflash.signals.Signal;

    /**
     * ...
     * @author Deron Decamp
     */
    public class Dialog extends Component {
        static public const OPTION_EMPHASIS_LOW:uint = 0;
        static public const OPTION_EMPHASIS_HIGH:uint = 1;
        /* TODO:
           . create a vector of dialogs that are inactive, and a variable for the current active dialog.
           . keep track of the currently active one via a `currentlyActive` property.
           . when a dialog is clicked (mousedown), move `currentlyActive` to the inactive vector, then set the clicked dialog to `currentlyActive`.
           also bring the currently active to the front.
           . also make a `pin()` method, which will always ensure the dialog is on top. only one dialog should be pinned at a time, since multiple cannot possibly be placed at the same index.
         */
        private var _title_textfield:PlainText;
        private var _message_textfield:PlainText;
        private var _title_string:String;
        private var _message_string:String;
        private var _text_container:VerticalBox;
        private var _dialog_card:Card;
        private var _component_container:VerticalBox;
        private var _option_container:HorizontalBox;
        private var _draggable:Boolean;
        private var _prev_parent:DisplayObjectContainer;
        private var _on_close:Signal;

        public function Dialog(parent:DisplayObjectContainer = null, title:String = '', message:String = '') {
            _title_string = title;
            _message_string = message;
            _on_close = new Signal();
            addEventListener(Event.ADDED_TO_STAGE, on_added_to_stage);
            super(parent);
        }

        /** INTERFACE net.blaxstar.starlib.components.IComponent ===================== */

        /**
         * initializes the component by adding all the children
         * and committing the visual changes to be written on the next frame.
         * created to be overridden.
         */
        override public function init():void {
            _dialog_card = new Card();
            _text_container = new VerticalBox();
            _title_textfield = new PlainText();
            _message_textfield = new PlainText();

            _title_textfield.enabled = false;
            _dialog_card.draggable = true;
            _dialog_card.auto_resize = true;
            //_text_container.isShowingBounds = true;
            isShowingBounds = true;
            super.init();
        }

        override protected function on_added(e:Event):void {
            super.on_added(e);
            move((stage.nativeWindow.width / 2) - (_width_ / 2), (stage.nativeWindow.height / 2) - (_width_ / 2));
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {

            _text_container.move(PADDING, PADDING);
            _dialog_card.add_child_native(_text_container);
            _title_textfield.text = _title_string;
            _message_textfield.text = _message_string;
            // cache the containers, no need to keep accessing them via dot
            _component_container = _dialog_card.component_container;
            _option_container = _dialog_card.option_container;
            _component_container.move(0, _text_container.y + _text_container.height);
            _text_container.addChild(_title_textfield);
            _text_container.addChild(_message_textfield);
            addChild(_dialog_card);

            _dialog_card.on_resize_signal.add(draw);
            commit();
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

            _width_ = _dialog_card.width;
            _height_ = _dialog_card.height;
            _component_container.move(PADDING, _text_container.y + _text_container.height + PADDING);
            _option_container.move(PADDING, _height_ - option_container.height);
            //_component_container.isShowingBounds = true;
            super.draw(e);
        }

        override public function set_size(w:Number, h:Number):void {
            _dialog_card.set_size(w, h);
            super.set_size(w, h);
        }

        /** END INTERFACE ===================== */

        public function add_component(val:DisplayObject):DisplayObject {
            return _dialog_card.add_child_to_container(val);
        }

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
            _dialog_card.draggable = val;
        }

        public function addOption(name:String, action:Function = null, emphasis:uint = OPTION_EMPHASIS_LOW):Button {

            var b:Button = new Button(_dialog_card.option_container, 0, 0, name);

            if (action != null) {
                b.addClickListener(action);
            }

            if (emphasis == OPTION_EMPHASIS_LOW) {
                b.style = Button.DEPRESSED;
            } else if (emphasis == OPTION_EMPHASIS_HIGH) {
                b.style = Button.GROUNDED;
            }

            commit();

            return b;
        }

        public function close(e:Event = null):void {
            if (parent) {
                parent.removeChild(this);
                _on_close.dispatch();
            }
        }

        public function open():void {
            if (_prev_parent != null) {
                _prev_parent.addChild(this);
            }
        }

        public function removeOptions():void {
            _dialog_card.option_container.removeChildren();
        }

        public function set auto_resize(val:Boolean):void {
            _dialog_card.auto_resize = val;
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

        private function on_added_to_stage(e:Event):void {
            _prev_parent = parent;
        }
    }

}

package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.style.Style;

    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;
    import net.blaxstar.starlib.structs.LinkedList;
    import net.blaxstar.starlib.structs.LinkedListNode;
    import flash.utils.Dictionary;

    /**
     * ...
     * @author Deron Decamp
     */
    public class Dialog extends Component {
        static private const MIN_WIDTH:uint = 200;
        static private const MIN_HEIGHT:uint = 300;
        static public const OPTION_EMPHASIS_LOW:uint = 0;
        static public const OPTION_EMPHASIS_HIGH:uint = 1;
        /* TODO:
           . create a vector of dialogs that are inactive, and a variable for the current active dialog.
           . keep track of the currently active one via a `currentlyActive` property.
           . when a dialog is clicked (mousedown), move `currentlyActive` to the inactive vector, then set the clicked dialog to `currentlyActive`.
           also bring the currently active to the front.
           . also make a `pin()` method, which will always ensure the dialog is on top. only one dialog should be pinned at a time, since multiple cannot possibly be placed at the same index.
         */
        static private var _efficiency_mode:Boolean = true;
        static private var _dialog_cache:Dictionary;
        static private var _active_dialog:Dialog;
        private var _dialog_card:Card;
        private var _mask:Sprite;
        private var _child_dialog_list:LinkedList;
        private var _active_nested_dialog:Dialog;
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
        protected var _is_nested:Boolean;
        private var _on_close_signal:Signal;
        private var _on_mouse_up_signal:NativeSignal;
        private var _on_release_outside:NativeSignal;
        private var _on_mouse_down_signal:NativeSignal;

        public function Dialog(parent:DisplayObjectContainer = null, title:String = '', message:String = '') {
            if (!_dialog_cache) {
                _dialog_cache = new Dictionary();
            }
            _title_string = title;
            _message_string = message;
            _on_close_signal = new Signal();
            super(parent);
        }

        // * PUBLIC * //
        /**
         * initializes the component by adding all the children
         * and committing the visual changes to be written on the next frame.
         * created to be overridden.
         */
        override public function init():void {
            
            _dialog_cache[this.id] = this;
            _width_ = MIN_WIDTH;
            _height_ = MIN_HEIGHT;
            super.init();
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {
            _dialog_card = new Card();
            super.addChild(_dialog_card);
            // mask
            _mask = new Sprite();
            _mask.mouseEnabled = false;
            super.addChild(_mask);
            super.addChild(_dialog_card);
            _dialog_card.mask = _mask;
            // textfields
            _text_container = new VerticalBox();
            _title_textfield = new PlainText();
            _message_textfield = new PlainText();
            _title_textfield.enabled = false;
            _title_textfield.text = _title_string;
            _message_textfield.multiline = true;
            _message_textfield.width = 300;
            _message_textfield.text = _message_string;
            _text_container.addChild(_title_textfield);
            _text_container.addChild(_message_textfield);
            // card
            _dialog_card.draggable = false;
            this.draggable = true;
            _dialog_card.auto_resize = false;
            _dialog_card.add_child_native(_text_container);
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
                _height_ = (PADDING * 4) + _text_container.height + _component_container.height + _option_container.height;
                _dialog_card.set_size(_width_, _height_);
                _text_container.move(PADDING, PADDING);
                _component_container.move(PADDING, _text_container.y + _text_container.height);
                _option_container.move(PADDING, _component_container.y + _component_container.height + PADDING);
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
            dispatchEvent(_resize_event_);
            _component_container.draw();
        }

        /**
         * Adds an option button for the current dialog. subsequent calls pushes additional buttons.
         * @param name
         * @param action
         * @param emphasis
         * @return
         */
        public function add_button(name:String, action:Function = null, emphasis:uint = Button.GROUNDED):Button {

            var b:Button = new Button(_dialog_card.option_container, 0, 0, name.toUpperCase());

            if (action != null) {
                b.add_click_listener(action);
            }

            b.style = emphasis;
            commit();

            return b;
        }

        /**
         * pushes a child dialog and disables the currently active one. if there is a dialog that is already pushed, it pushes another one on top, and disables the previously pushed dialog.
         * @param dialog the dialog to add as a child.
         */
        public function push_dialog(dialog:Dialog):void {
            if (!_child_dialog_list) {
                _child_dialog_list = new LinkedList();
            }

            _child_dialog_list.append(new LinkedListNode(dialog));
            _active_nested_dialog = dialog;
            _active_nested_dialog.is_nested = true;
            dialog.move(this.x + PADDING, this.y + PADDING);
            enabled = false;
            parent.addChild(dialog);
            dialog.on_close_signal.add(pop_dialog);
            dialog.open();
        }

        public function pop_dialog(event:Event=null):Dialog {
            var d:Dialog = _child_dialog_list.remove_at(_child_dialog_list.size - 1) as Dialog;
            d.is_nested = false;
            d.close();
            if (_child_dialog_list.size > 0) {
                _active_nested_dialog = _child_dialog_list.remove_at(_child_dialog_list.size - 1) as Dialog;
            } else {
                _active_nested_dialog = this;
                enabled = true;
            }
            return d;
        }

        /**
         * adds a child to the current dialogs component container (VerticalBox).
         * @param child
         * @return
         */
        override public function addChild(child:DisplayObject):DisplayObject {
            return _component_container.addChild(child);
        }

        /**
         * adds a child to the current dialog's actual container (Sprite).
         * @param child
         * @return
         */
        public function add_child_native(child:DisplayObject):DisplayObject {
            return super.addChild(child);
        }

        override public function move(x_position:Number, y_position:Number):void {
            if (_child_dialog_list) {
                var num_dialogs:uint = _child_dialog_list.size;
            }
            if (num_dialogs) {
                for (var i:int = 0; i < num_dialogs; i++) {
                    _child_dialog_list[i].move(x_position + PADDING, y_position + PADDING);
                }
            }
            super.move(x_position, y_position);
        }

        private function create_efficiency():void {
            if (_efficiency_mode) {
                for each (var dialog:Dialog in _dialog_cache) {
                    if (dialog.is_nested && dialog != _active_nested_dialog) {
                        continue;
                    }
                    dialog.component_container.enabled = false;
                    dialog.option_container.enabled = false;
                    dialog.alpha = 1;
                }
                _active_dialog = this;
                option_container.enabled = true;
                component_container.enabled = true;
                parent.setChildIndex(this, parent.numChildren - 1);
            }
        }

        override public function set enabled(val:Boolean):void {
          this.component_container.enabled = val;
          this.option_container.enabled = val;
        }

        public function set message_color(color:uint):void {
            _message_textfield.color = color;
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

        // ! DELEGATE FUNCTIONS ! //

        override protected function on_added(e:Event):void {
            _prev_parent_container = parent;
        }

        private function on_card_resize(e:Event = null):void {
            commit();
        }

        private function on_mouse_down(e:MouseEvent = null):void {
            _on_mouse_down_signal.remove(on_mouse_down);
            this.startDrag();

            create_efficiency();

            if (!_on_mouse_up_signal) {
                _on_mouse_up_signal = new NativeSignal(_title_textfield, MouseEvent.MOUSE_UP, MouseEvent);
                _on_release_outside = new NativeSignal(_title_textfield, MouseEvent.RELEASE_OUTSIDE, MouseEvent);
            }
            _on_mouse_up_signal.add(on_mouse_up);
            _on_release_outside.add(on_mouse_up);
        }

        private function on_mouse_up(e:MouseEvent = null):void {
            _on_mouse_up_signal.remove(on_mouse_up);
            _on_release_outside.remove(on_mouse_up);
            this.stopDrag();

            if (y < 0) {
                y = 5;
            }
            if (x < 0) {
                x = 5;
            }
            if (parent === stage && y > stage.stageHeight) {
                y = stage.stageHeight - _height_;
            }
            if (parent === stage && x > stage.stageWidth) {
                x = stage.stageWidth - _width_;
            }

            if (!_on_mouse_down_signal) {
                _on_mouse_down_signal = new NativeSignal(_title_textfield, MouseEvent.MOUSE_DOWN, MouseEvent);
            }

            _on_mouse_down_signal.add(on_mouse_down);
        }

        // ! GETTERS & SETTERS ! //
        static public function get efficiency_mode():Boolean {
          return _efficiency_mode;
        }
        static public function set efficiency_mode(value:Boolean):void {
          _efficiency_mode = value;
        }

        public function set title(val:String):void {
            _title_string = (val.length > 0) ? val : _title_string;
            commit();
        }

        public function get title():String {
            return _title_string;
        }

        public function set message(val:String):void {
            _message_string = (val && val.length > 0) ? val : _message_string;
            commit();
        }

        public function get message():String {
            return _message_string;
        }

        public function get on_close_signal():Signal {
            return _on_close_signal;
        }

        public function get draggable():Boolean {
            return _draggable;
        }

        public function set draggable(val:Boolean):void {
            _draggable = val;

            if (_draggable) {
                _title_textfield.enabled = true;

                if (Style.CURRENT_THEME == Style.DARK) {
                    _title_textfield.color = Style.TEXT.shade().value;
                } else {
                    _title_textfield.color = Style.TEXT.tint().value;
                }

                _on_mouse_down_signal ||= new NativeSignal(_title_textfield, MouseEvent.MOUSE_DOWN, MouseEvent);
                _on_mouse_down_signal.add(on_mouse_down);
            } else {
                _title_textfield.enabled = false;

                if (Style.CURRENT_THEME == Style.DARK) {
                    _title_textfield.color = Style.TEXT.tint().value;
                } else {
                    _title_textfield.color = Style.TEXT.shade().value;
                }
            }
        }

        public function close(e:Event = null):void {
            if (_child_dialog_list) {
                var num_dialogs:uint = _child_dialog_list.size;
            }
            if (num_dialogs > 0) {
                for (var i:int = num_dialogs - 1; i > -1; i--) {
                    pop_dialog();
                }
            }

            if (parent) {
                parent.removeChild(this);
                _on_close_signal.dispatch();
            }
        }

        public function open():void {
            if (!parent && _prev_parent_container != null) {
                _prev_parent_container.addChild(this);
            }
        }

        public function removeOptions():void {
            _dialog_card.option_container.removeChildren();
        }

        // ! GETTERS & SETTERS ! //

        public function set auto_resize(val:Boolean):void {
            _auto_resize = val;
            draw();
        }

        public function get is_nested():Boolean {
            return _is_nested;
        }

        public function set is_nested(value:Boolean):void {
            _is_nested = value;
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

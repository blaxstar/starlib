package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.style.Style;

    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import net.blaxstar.starlib.style.RGBA;
    import flash.geom.Rectangle;
    import flash.display.Graphics;

    /**
     * Card class, a component inspired by Google's Material Card. It can be used as a layout container for components.
     * @author SnaiLegacy
     */
    public class Card extends Component {
        static private const MIN_WIDTH:uint = 200;
        static private const MIN_HEIGHT:uint = 200;

        private var _card_background:Sprite;
        private var _component_container:VerticalBox;
        private var _option_container:HorizontalBox;
        private var _highlight_region:Rectangle;
        private var _region_highlighted:Boolean;
        private var _auto_resize:Boolean;
        private var _draggable:Boolean;
        private var _checkable:Boolean;
        private var _color_overriden:Boolean;
        private var _override_color:RGBA;
        private var _on_mouse_down_signal:NativeSignal;
        private var _on_mouse_up_signal:NativeSignal;
        private var _on_click_signal:NativeSignal;

        /**
         *
         * @param    parent the parent object to add this card to.
         */
        public function Card(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, autoResize:Boolean = true) {
            _auto_resize = autoResize;
            super(parent);
        }

        /** INTERFACE net.blaxstar.starlib.components.IComponent ===================== */

        /**
         * initializes the component by adding all the children
         * and committing the visual changes to be written on the next frame.
         * created to be overridden.
         */
        override public function init():void {
            _width_ = MIN_WIDTH;
            _height_ = MIN_HEIGHT;
            _color_overriden = false;

            _component_container = new VerticalBox();
            _option_container = new HorizontalBox();
            _card_background = new Sprite();

            super.init();
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {

            _component_container.width = 30;
            _component_container.spacing = 10;
            _option_container.spacing = 10;

            _card_background.graphics.beginFill(Style.SURFACE.value, 1);
            _card_background.graphics.drawRect(0, 0, 1, 1);
            _card_background.graphics.endFill();

            super.addChild(_card_background);
            super.addChild(_component_container);
            super.addChild(_option_container);
            apply_shadow();

            super.add_children();
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {
            // auto resize if enabled, and there are children present

            if (_auto_resize) {
                var totalW:Number = (PADDING * 4) + Math.max(_component_container.width, _option_container.width);
                var totalH:Number = (PADDING * 4) + _component_container.height + _option_container.height;

                if (totalW > MIN_WIDTH) {
                    _width_ = totalW;
                }
                if (totalH > MIN_HEIGHT) {
                    _height_ = totalH;
                }
            }

            draw_background();
            _option_container.move(PADDING, _height_ - PADDING - _option_container.height - PADDING);

            super.draw();
        }

        /** END INTERFACE ===================== */
        override public function update_skin():void {
            draw_background();
        }

        // adds child to card, nesting it inside a layout container (Vertical Box).
        public function add_child_native(child:DisplayObject):flash.display.DisplayObject {
            return super.addChild(child);
        }

        override public function addChild(child:DisplayObject):flash.display.DisplayObject {
            return add_child_to_container(child);
        }

        override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
            return add_child_to_container(child, index);
        }

        public function add_child_to_container(child:DisplayObject, index:int = -1):DisplayObject {
            if (index > -1)
                _component_container.addChildAt(child, index);
            else
                _component_container.addChild(child);
            commit();
            return child;
        }

        public function set_color(color:uint):void {
            _color_overriden = true;
            _override_color = RGBA.from_hex(color);
            draw_background();
        }

        public function set_color_rgba(color:RGBA):void {
            _color_overriden = true;
            _override_color = color;
            draw_background();
        }

        public function set_default_color():void {
            _color_overriden = false;
            _override_color = null;
            draw_background();
        }

        public function highlight_region(x: uint, y:uint, width:uint, height:uint):void {
            _region_highlighted = true;
            _highlight_region ||= new Rectangle();
            _highlight_region.x = x;
            _highlight_region.y = y;
            _highlight_region.width = width;
            _highlight_region.height = height;
            draw_background();
        }

        public function clear_highlight():void {
          _highlight_region = null;
          _region_highlighted = false;
          draw_background();
        }

        private function draw_background():void {
            var g:Graphics = _card_background.graphics;
            g.clear();
            g.beginFill((!_color_overriden ? Style.SURFACE.value : _override_color.value), (!_color_overriden ? 1 : _override_color.alpha));
            g.lineStyle(0.5, Style.SURFACE.value, .2);
            g.drawRoundRect(0, 0, _width_, _height_, 7);

            if (_region_highlighted && _highlight_region != null) {
              g.beginFill(Style.SECONDARY.value);
              g.drawRoundRect(_highlight_region.x, _highlight_region.y, _highlight_region.width, _highlight_region.height, 7);
            }

            g.endFill();
        }

        public function set viewable_items(val:Number):void {
            _component_container.max_visible = val;
        }

        public function set mask_threshold(val:Number):void {
            _component_container.maskThreshold = val;
        }

        public function set auto_resize(val:Boolean):void {
            _auto_resize = val;
            draw();
        }

        public function set draggable(val:Boolean):void {
            _draggable = val;
            if (_draggable) {
                if (!_on_mouse_down_signal)
                    _on_mouse_down_signal = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
                _on_mouse_down_signal.add(on_mouse_down);
            } else {
                if (!_on_mouse_down_signal)
                    return;
                else
                    _on_mouse_down_signal.remove(on_mouse_down);
            }
        }

        public function get component_container():VerticalBox {
            return _component_container;
        }

        public function get option_container():HorizontalBox {
            return _option_container;
        }

        public function set checkable(val:Boolean):void {
            _checkable = val;
            if (_checkable) {
                if (!_on_click_signal)
                    _on_click_signal = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
                _on_click_signal.add(onSelect);
            }
        }


        private function onSelect():void {
            // TODO (dyxribo): Implement selection property and indicator to Card

        }

        private function on_mouse_down(e:MouseEvent = null):void {
            this.startDrag();
            if (!_on_mouse_up_signal)
                _on_mouse_up_signal = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent);
            _on_mouse_up_signal.add(on_mouse_up);
        }

        private function on_mouse_up(e:MouseEvent = null):void {
            this.stopDrag();

            if (!_on_mouse_down_signal) {
                _on_mouse_down_signal = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
            }

            _on_mouse_down_signal.add(on_mouse_down);
        }

        override public function destroy():void {
            if (_on_mouse_down_signal) {
                _on_mouse_down_signal.removeAll();
            }
            if (_on_mouse_up_signal) {
                _on_mouse_up_signal.removeAll();
            }
            if (_on_click_signal) {
                _on_click_signal.removeAll();
            }
        }

    }

}

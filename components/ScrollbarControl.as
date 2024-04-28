package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import net.blaxstar.starlib.style.Style;

    import thirdparty.org.osflash.signals.Signal;

    public class ScrollbarControl extends Component {
        private const XMIN:uint = 0;
        private const YMIN:uint = 0;
        private const THICKNESS:uint = 7;

        private var _track:Sprite;
        private var _grip:Sprite;
        private var _vertical:Boolean;
        private var _auto_attach:Boolean;
        private var _content:DisplayObject;
        private var _viewport:DisplayObject;
        private var _y_offset:uint;
        private var _max_grip_y:uint;
        private var _x_offset:uint;
        private var _max_grip_x:uint;
        private var _scroll_ratio:Number;
        private var _grip_up_color:uint;
        private var _grip_down_color:uint;
        private var on_scroll_signal:Signal;

        public function ScrollbarControl(content:DisplayObject, viewport:DisplayObject, parent:DisplayObjectContainer = null, vertical:Boolean = true, attach_outside:Boolean=true) {
            _vertical = vertical;
            _content = content;
            _viewport = viewport;
            _auto_attach = attach_outside;

            super(parent);
        }

        override public function init():void {
            _width_ = _height_ = 0;
            _track = new Sprite();
            _grip = new Sprite();
            on_scroll_signal = new Signal(Number);
            _grip_up_color = Style.SECONDARY.value;
            _grip_down_color = Style.SECONDARY_LIGHT.value;
            super.init();
        }

        override public function draw(e:Event = null):void {

            if (_vertical) {
                _width_ = THICKNESS;
                _height_ = _viewport.height;
            } else {
                _width_ = _viewport.width;
                _height_ = THICKNESS;
            }

            draw_track();
            draw_grip();

            attach();
            _grip.addEventListener(MouseEvent.MOUSE_DOWN, on_grip_down);
        }

        private function draw_track():void {
            var corner_radius:Number = (_vertical) ? _width_ / 2 : _height_ / 2;
            _track.graphics.clear();
            _track.graphics.beginFill(Style.SECONDARY_DARK.value);
            _track.graphics.drawRoundRect(0, 0, _width_, _height_, corner_radius, corner_radius);
            _track.graphics.endFill();
            if (!_track.parent)
                addChild(_track);
        }

        private function draw_grip(isDown:Boolean = false):void {
            // (re)draw the grip
            var corner_radius:Number = (_vertical) ? _width_ / 2 : _height_ / 2;
            _grip.graphics.clear();
            _grip.graphics.beginFill((isDown) ? _grip_down_color : _grip_up_color);
            _grip.graphics.drawRoundRect(0, 0, _width_, _height_, corner_radius, corner_radius);
            _grip.graphics.endFill();
            update_scrollbar_size();
            if (!_grip.parent)
                addChild(_grip);

            _grip.addEventListener(MouseEvent.MOUSE_DOWN, on_grip_down);
            _grip.addEventListener(MouseEvent.RELEASE_OUTSIDE, on_grip_up);
            _grip.addEventListener(MouseEvent.MOUSE_UP, on_grip_up);
        }

        private function attach():void {
            // if content is vertical
            if (_vertical) {
                
                x = _viewport.x + _viewport.width - (_auto_attach ? 0 : _width_);
                y = _viewport.y;
                _height_ = _viewport.height;
                // only show the scrollbar if the content is taller than the viewport, and apply scroll listeners.
                if (_content.height > _viewport.height) {
                    this.visible = true;
                    on_scroll_signal.add(scroll);
                } else
                    this.visible = false;
            } else {
                // same thing but horizontally 👇
                x = _viewport.x;
                y = _viewport.y + _viewport.height - (_auto_attach ? 0 : _height_);

                if (_content.x + _content.width > _viewport.x + _viewport.width) {
                    this.visible = true;
                    on_scroll_signal.add(scroll);
                } else
                    this.visible = false;
            }

            draw_track();
            draw_grip();
            on_content_resize();
            _content.addEventListener(Event.RESIZE, on_content_resize);
            scroll(0);
        }

        private function on_content_resize(e:Event = null):void {
            _content.scrollRect = new Rectangle(0, 0, _viewport.width, _viewport.height);
            update_scrollbar_size();
            scroll(0);
            //x = _viewport.x + _viewport.width;
            //y = _viewport.y;

            if (_vertical) {
                _height_ = _viewport.height;
            } else {
                _width_ = _viewport.width;
            }
        }

        private function update_scrollbar_size():void {
            _scroll_ratio ||= _content.height / _viewport.height;
            var scroll_thumb_height:Number = Math.max(20, _height_ / _scroll_ratio);
            _grip.height = scroll_thumb_height;
        }

        private function scroll(percent:Number):void {
            // stay calm and ✨ s c r o l l ✨
            var current_rect:Rectangle = (_content.scrollRect) ? _content.scrollRect : new Rectangle(0, 0, _viewport.width, _viewport.height);

            if (_vertical) {
                current_rect.y = ((_grip.y + (PADDING * (percent / 50))) / (_height_) ) * _content.height
            } else {
                current_rect.x = -(_grip.x / _width_) * _content.width;
            }

            _content.scrollRect = current_rect;
        }

        private function on_grip_up(e:MouseEvent):void {
            // redraw to show that the grip is released after being pressed.
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, move_grip);
            draw_grip();
        }

        private function on_grip_down(e:MouseEvent):void {
            // start moving the grip if the grip is being pressed down...
            stage.addEventListener(MouseEvent.MOUSE_MOVE, move_grip);

            // ...then redraw to show that the grip is being pressed.
            draw_grip(true);

            // again, draw it horizontally unless stated otherwise.
            if (_vertical) {
                // limit the drag distance of the grip to the height of the track (while accounting for the grip, of course)
                _max_grip_y = (height) - _grip.height;
                // also account for the location of the mouse, relative to the grip's position.
                _y_offset = mouseY - _grip.y;
            } else {
                // do the same thing as above but horizontally 👇
                _max_grip_x = width - _grip.width;
                // that includes the mouse location!
                _x_offset = mouseX - _grip.x;
            }
        }

        private function move_grip(e:MouseEvent):void {
            // move the grip (and content) based on the scrollbar's orientation.
            if (_vertical) {
                // move the content up or down. get the ratio of the grip y to track length, then multiply it by the content height.
                // _viewport.y = (_grip.y / _height_) * _contentBounds.height;
                // account for the y offset of the mouse
                _grip.y = mouseY - _y_offset;

                // force the grip to stay within bounds 🔒
                if (_grip.y <= YMIN)
                    _grip.y = YMIN;
                if (_grip.y >= _max_grip_y)
                    _grip.y = _max_grip_y;

                // dispatch the scroll percentage as the grip slides.
                on_scroll_signal.dispatch(_grip.y + YMIN / (_max_grip_y - YMIN));
            } else {
                // move the content left or right. get the ratio of the grip x to track length, then multiply by the content width.
                // _viewport.x = -(_grip.y / _width_) * _contentBounds.width;
                // account for the x offset instead of y since we're horizontal!
                _grip.x = mouseX - _x_offset;

                // force the grip to stay within bounds, horizontal edition
                if (_grip.x <= XMIN)
                    _grip.x = XMIN;
                if (_grip.x >= _max_grip_x)
                    _grip.x = _max_grip_x;

                // dispatch the scroll percentage as the grip slides.
                on_scroll_signal.dispatch(_grip.x + XMIN / (_max_grip_x - XMIN));
            }
            // make sure to render after this event.
            e.updateAfterEvent();
        }

        public function set scroll_ratio(val:Number):void {
            _scroll_ratio = val;
            commit();
        }

        public function set auto_attach(value:Boolean):void {
          _auto_attach = value;
          commit();
        }
    }
}

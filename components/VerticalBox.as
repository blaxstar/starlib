package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class VerticalBox extends Component {
        private static const MIN_HEIGHT:uint = 50;
        public static const LEFT:String = "left";
        public static const RIGHT:String = "right";
        public static const CENTER:String = "center";
        public static const NONE:String = "none";

        protected var _spacing_:Number = 5;

        private var _alignment:String = NONE;

        /**
         * Constructor
         * @param parent The parent DisplayObjectContainer on which to add this PushButton.
         * @param xpos The x position to place this component.
         * @param ypos The y position to place this component.
         */
        public function VerticalBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
            super(parent, xpos, ypos);
        }

        /**
         * override of addChild to force layout.
         */
        override public function addChild(child:DisplayObject):DisplayObject {
            super.addChild(child);

            if (child is Component) {
                (child as Component).on_resize_signal.add(on_component_resize);
            } else {
                child.addEventListener(Event.RESIZE, on_component_resize);
            }

            draw();
            return child;
        }

        /**
         * override of addChildAt to force layout.
         */
        override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
            super.addChildAt(child, index);

            if (child is Component) {
                Component(child).on_resize_signal.add(on_component_resize);
            } else {
                child.addEventListener(Event.RESIZE, on_component_resize);
            }

            draw();
            return child;
        }

        /**
         * override of removeChild to force layout.
         */
        override public function removeChild(child:DisplayObject):DisplayObject {
            super.removeChild(child);

            if (child is Component) {
                Component(child).on_resize_signal.remove(on_component_resize);
            } else {
                child.removeEventListener(Event.RESIZE, on_component_resize);
            }

            draw();
            return child;
        }

        /**
         * override of removeChild to force layout.
         */
        override public function removeChildAt(index:int):DisplayObject {
            var child:DisplayObject = super.removeChildAt(index);

            if (child is Component) {
                Component(child).on_resize_signal.remove(on_component_resize);
            } else {
                child.removeEventListener(Event.RESIZE, on_component_resize);
            }

            draw();
            return child;
        }

        /**
         * internal handler for resize event of any attached component. Will redo the layout based on new size.
         */
        protected function on_component_resize(event:Event = null):void {
            commit();
        }

        /**
         * Sets element's y positions based on alignment value.
         */
        protected function align():void {
            if (_alignment != NONE) {
                for (var i:int = 0; i < numChildren; i++) {
                    var child:DisplayObject = getChildAt(i);
                    if (_alignment == LEFT) {
                        child.x = 0;
                    } else if (_alignment == RIGHT) {
                        child.x = _width_ - child.width;
                    } else if (_alignment == CENTER) {
                        child.x = (_width_ - child.width) / 2;
                    }
                }
            }
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {
            super.draw(e);
            _width_ = _height_ = 0;
            var ypos:Number = 0;
            var child:DisplayObject;

            for (var i:int = 0; i < numChildren; i++) {
                child = getChildAt(i);
                child.y = ypos;
                ypos += child.height;
                ypos += _spacing_;
                _height_ += child.height;
                _width_ = Math.max(_width_, child.width);
            }

            align();
            _height_ += _spacing_ * (numChildren - 1);
            if (_height_ < MIN_HEIGHT) {
              _height_ = MIN_HEIGHT;
            }

            dispatchEvent(new Event(Event.RESIZE));
        }

        /**
         *  getter and setter for the spacing between each subcomponent.
         */
        public function set spacing(pixel_spacing:Number):void {
            _spacing_ = pixel_spacing;
            commit();
        }

        public function get spacing():Number {
            return _spacing_;
        }

        /**
         * getter and setter for the horizontal alignment of components in the box (left, right, center).
         */
        public function set alignment(value:String):void {
            _alignment = value;
            commit();
        }

        public function get alignment():String {
            return _alignment;
        }

        override public function destroy():void {

            for (var i:uint = 0; i < numChildren; i++) {
                var child:DisplayObject = getChildAt(i);
                if (child is Component)
                    Component(child).on_resize_signal.remove(on_component_resize);
                else
                    child.removeEventListener(Event.RESIZE, on_component_resize);
            }
        }
    }
}

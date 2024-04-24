package net.blaxstar.starlib.components {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class HorizontalBox extends FunctionQueueableComponent {
        public static const TOP:String = "top";
        public static const CENTER:String = "middle";
        public static const BOTTOM:String = "bottom";
        public static const NONE:String = "none";

        protected var _spacing_:Number = 5;

        private var _alignment:String = NONE;

        /**
         * Constructor
         * @param parent The parent DisplayObjectContainer on which to add this PushButton.
         * @param xpos The x position to place this component.
         * @param ypos The y position to place this component.
         */
        public function HorizontalBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
            super(parent, xpos, ypos);
        }

        /**
         * override of addChildAt to force layout.
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
         * internal handler for resize event of any attached component. will redo the layout based on new size.
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
                    if (_alignment == TOP) {
                        child.y = 0;
                    } else if (_alignment == BOTTOM) {
                        child.y = _height_ - child.height;
                    } else if (_alignment == CENTER) {
                        child.y = (_height_ - child.height) / 2;
                    }
                }
            }
        }

        /**
         * (re)draws the componentS and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {
            super.draw(e);
            var xpos:Number = 0;
            _width_ = _height_ = 0;
            var child:DisplayObject;

            for (var i:int = 0; i < numChildren; i++) {
                child = getChildAt(i);
                child.x = xpos;
                xpos += child.width;
                xpos += _spacing_;
                _width_ += child.width;
                _height_ = Math.max(_height_, child.height);
            }

            align();
            _width_ += _spacing_ * (numChildren - 1);
            dispatchEvent(new Event(Event.RESIZE));
        }

        public function set maskThreshold(value:Number):void {
            if (_width_ > value) {
                cacheAsBitmap = true;
                scrollRect = new Rectangle(0, 0, _width_, value);
            } else
                queue_function(arguments.callee, value);
        }

        public function set viewableItems(value:Number):void {
            if (value > numChildren) {
                queue_function(arguments.callee, value);
                return;
            }
            var lastChild:DisplayObject = getChildAt(value - 1);
            cacheAsBitmap = true;
            scrollRect = new Rectangle(0, 0, lastChild.x + lastChild.width, _height_);
        }

        /**
         *  getter and setter for the spacing between each subcomponent.
         */
        public function set spacing(s:Number):void {
            _spacing_ = s;
            commit();
        }

        public function get spacing():Number {
            return _spacing_;
        }

        /**
         *  getter and setter for the horizontal alignment of components in the box.
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

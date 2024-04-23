package net.blaxstar.starlib.gui {
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;

    import net.blaxstar.starlib.style.Style;
    import flash.events.NativeWindowBoundsEvent;

    /**
     * a checker-patterened surface to be applied to the `Main` class.
     * great for visual accessibility, especially in tandem with semi-transparent graphics.
     *
     * @author Deron Decamp (decamp.deron@gmail.com)
     */
    public class CheckeredSurface extends Sprite {
        private const DEFAULT_SIZE:uint = 15;
        private var _checkerbox_size:uint;
        private var _canvas:Shape;
        private var _parent:DisplayObjectContainer;

        /**
         *  a checker-pattern generator, typically used for backgrounds that should be visually accessible.
         * @param parent
         *
         */
        public function CheckeredSurface() {
            super();
            // cache as bitmap, this won't be animated
            cacheAsBitmap = true;
            // set default size of the checker boxes (perfect square)
            _checkerbox_size = DEFAULT_SIZE;
            // create a shape for drawing the checker pattern
            _canvas = new Shape();
        }

        /**
         *
         * @param parent a displayobject container, typically the `Main` class, which extends `Sprite`. a container other than `Main` can be supplied; however, this may affect the z-position of the surface.
         * @return void
         */
        public function apply_to(parent:DisplayObjectContainer):void {
            if (!parent) {
                throw new Error("parent cannot be null!");
                return;
            }
            _parent = parent;
            _parent.addChild(this);
            draw();
            stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, on_window_resize);
        }

        public function remove():void {
            if (parent) {
                _canvas.graphics.clear();
                _parent.removeChild(this);
            }
        }

        /**
         * draws the checker pattern to the background shape object.
         * @return void
         */
        public function draw():void {
            // store some variables for quick access
            var g:Graphics = _canvas.graphics;
            var color0:uint = Style.SURFACE.value;
            var color1:uint = (Style.CURRENT_THEME == Style.DARK) ? Style.SURFACE.tint().value : Style.SURFACE.shade().value;
            // the boxes should be the width and/or height of the stage divided by the expected size of each checkerbox, which should all be uniform via the _checkerbox_size variable.
            var horizontal_boxes:uint = Math.ceil(_parent.stage.stageWidth / _checkerbox_size);
            var vertical_boxes:uint = Math.ceil(_parent.stage.stageHeight / _checkerbox_size);

            // if there is not an even number of vertical boxes, add one to make it so
            if (vertical_boxes % 2 !== 0)
                vertical_boxes++;
            // clear the canvas and start drawing
            g.clear();

            // to break this down: loop through the number horizontal boxes so we can deal with the horizontal logic...
            for (var i:uint = 0; i < horizontal_boxes + 1; i++) {
                // and nest a loop for the vertical boxes so we can do it all in one go
                for (var j:uint = 0; j < vertical_boxes; j++) {
                    // based on the iteration and whether that number is even or odd, change the color and draw the square using it
                    g.beginFill((i % 2 == 0) ? color0 : color1, .2);
                    g.drawRect(i * _checkerbox_size, j * _checkerbox_size, _checkerbox_size, _checkerbox_size);
                    // then swap the color variable values. this makes sure that the starting color of each row alternates, creating the checkerboard effect. without this swap, each row would start with the same color, and you'd end up with stripes instead of a checkerboard.
                    color0 ^= color1;
                    color1 ^= color0;
                    color0 ^= color1;
                    // end the fill process, we're done here until the next drawing
                    g.endFill();
                }

            }
            // the checkerboard should be complete, so at this point, add it to the canvas
            addChild(_canvas);
        }

        public function set checkerbox_size(val:uint):void {
            _checkerbox_size = (val > 0) ? val : DEFAULT_SIZE;
            draw();
        }

        private function on_window_resize(event:NativeWindowBoundsEvent):void {
            draw();
        }
    }

}

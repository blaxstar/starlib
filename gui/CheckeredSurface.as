package net.blaxstar.gui {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.display.Sprite;

  import net.blaxstar.style.Style;
  import flash.events.NativeWindowBoundsEvent;

  /**
   * a checker-patterened surface to be applied to the `Main` class.
   * great for visual accessibility, especially in tandem with semi-transparent graphics.
   *
   * @author Deron Decamp (decamp.deron@gmail.com)
   */
  public class CheckeredSurface extends Sprite {
    private const DEFAULT_SIZE:uint = 15;
    private var _checkerboxSize:uint;
    private var _canvasBG:Shape;
    private var _parent:DisplayObjectContainer;

    /**
     *
     * @param parent  a displayobject container, typically the `Main` class, which extends `Sprite`.
     * a container other than `Main` can be supplied; however, this may affect the z-position of the surface.
     */
    public function CheckeredSurface(parent:DisplayObjectContainer) {
      super();
      
      if (!parent) {
        throw new Error("parent cannot be null!");
        return;
      }
      cacheAsBitmap = true;
      _checkerboxSize = DEFAULT_SIZE;
      _canvasBG = new Shape();
      _parent = parent;
      _parent.addChild(this);
      draw();
      stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowResize);
    }

    public function draw():void {

      var g:Graphics = _canvasBG.graphics;
      var color0:uint = Style.SURFACE.value;
      var color1:uint = (Style.CURRENT_THEME == Style.DARK) ? Style.SURFACE.tint().value : Style.SURFACE.shade().value;
      var horizontalBoxes:uint = Math.ceil(_parent.stage.stageWidth / _checkerboxSize);
      var verticalBoxes:uint = Math.ceil(_parent.stage.stageHeight / _checkerboxSize);

      if (verticalBoxes % 2 !== 0)
        verticalBoxes++;
      g.clear();

      for (var i:uint = 0; i < horizontalBoxes + 1; i++) {
        for (var j:uint = 0; j < verticalBoxes; j++) {
          g.beginFill((i % 2 == 0) ? color0 : color1, .2);
          g.drawRect(i * _checkerboxSize, j * _checkerboxSize, _checkerboxSize, _checkerboxSize);
          color0 ^= color1;
          color1 ^= color0;
          color0 ^= color1;
          g.endFill();
        }

      }
      addChild(_canvasBG);
    }

    public function set checkerSize(val:uint):void {
      _checkerboxSize = (val > 0) ? val : DEFAULT_SIZE;
      draw();
    }
    
    private function onWindowResize(event:NativeWindowBoundsEvent):void {
      draw();
    }
  }

}

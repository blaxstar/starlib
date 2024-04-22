package net.blaxstar.starlib.utils {
  import flash.display.DisplayObjectContainer;
  import flash.display.DisplayObject;
  import flash.display.Loader;
  import flash.display.Stage;
  import flash.display.Sprite;
  import flash.geom.Matrix;

  public class DisplayObjects {
    static public function setRegistrationPoint(s:Sprite, regx:Number, regy:Number, showRegistration:Boolean):void {
      s.transform.matrix = new Matrix(1, 0, 0, 1, -regx, -regy);

      // draw registration point.
      if (showRegistration) {
        var mark:Sprite = new Sprite();
        mark.graphics.lineStyle(1, 0x000000);
        mark.graphics.moveTo(-5, -5);
        mark.graphics.lineTo(5, 5);
        mark.graphics.moveTo(-5, 5);
        mark.graphics.lineTo(5, -5);
        s.parent.addChild(mark);
      }
    }

    static public function removeAndNullChildren(root_container:DisplayObjectContainer, nullSelf:Boolean = true):void {
      if (!root_container)
        return;
      for (var i:uint = 0; i < root_container.numChildren; ++i) {
        // check if child is a DisplayObjectContainer, which could hold more children
        if (root_container.getChildAt(i) is DisplayObjectContainer)
          removeAndNullChildren(DisplayObjectContainer(root_container.getChildAt(i)));
        else {
          // remove and null child of parent
          var child:DisplayObject = root_container.getChildAt(i);
          if (!(root_container is Loader))
            root_container.removeChild(child);
          child = null;
        }
      }
      // remove and null parent
      if (!(root_container is Stage)) {
        if (root_container.parent)
          root_container.parent.removeChild(root_container);
        if (nullSelf)
          root_container = null;
      }
    }

    static public function getNumChildren(root_container:DisplayObjectContainer):uint {
      if (!root_container)
        return 0;
      var numCh:uint = 0;

      for (var i:uint = 0; i < root_container.numChildren; ++i) {
        // check if child is a DisplayObjectContainer, which could hold more children
        if (root_container.getChildAt(i) is DisplayObjectContainer)
          numCh += getNumChildren(DisplayObjectContainer(root_container.getChildAt(i)));
        else {
          ++ numCh;
        }
      }

      return numCh;
    }
  }
}

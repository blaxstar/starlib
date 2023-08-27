package net.blaxstar.utils {
  public class DisplayObjectUtil {
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

    static public function removeAndNullChildren(dOC:DisplayObjectContainer, nullSelf:Boolean = true):void {
      if (!dOC)
        return;
      for (var i:uint = 0; i < dOC.numChildren; ++i) {
        // check if child is a DisplayObjectContainer, which could hold more children
        if (dOC.getChildAt(i) is DisplayObjectContainer)
          removeAndNullChildren(DisplayObjectContainer(dOC.getChildAt(i)));
        else {
          // remove and null child of parent
          var child:DisplayObject = dOC.getChildAt(i);
          if (!(dOC is Loader))
            dOC.removeChild(child);
          child = null;
        }
      }
      // remove and null parent
      if (!(dOC is Stage)) {
        if (dOC.parent)
          dOC.parent.removeChild(dOC);
        if (nullSelf)
          dOC = null;
      }
    }

    static public function getNumChildren(dOC:DisplayObjectContainer):uint {
      if (!dOC)
        return 0;
      var numCh:uint = 0;

      for (var i:uint = 0; i < dOC.numChildren; ++i) {
        // check if child is a DisplayObjectContainer, which could hold more children
        if (dOC.getChildAt(i) is DisplayObjectContainer)
          numCh += getNumChildren(DisplayObjectContainer(dOC.getChildAt(i)));
        else {
          ++ numCh;
        }
      }

      return numCh;
    }
  }
}

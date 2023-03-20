package net.blaxstar.math {
  import flash.display.DisplayObject;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  public class Geometry {
    /**
     * <b>Checks if a rectangle contains a point.</b>
     * @param   A Rectangle to use for checking.
     * @param   B Point to use for checking.
     * @return
     */
    static public function rectContainsPoint(A:Rectangle, B:Point):Boolean {
      return (B.x > A.x)
        && (B.x < A.x + A.width)
        && (B.y > A.y)
        && (B.y < A.y + A.height);
    }

    static public function localToGlobalRect(rec:Rectangle, targetCoordinateSpace:DisplayObject):Rectangle {
      var topLeft:Point = targetCoordinateSpace.localToGlobal(rec.topLeft);
      var bottomRight:Point = targetCoordinateSpace.localToGlobal(rec.bottomRight);
      var rect:Rectangle = new Rectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);

      return rect;
    }

    static public function flipRectangle(rec:Rectangle, scale:int = -1):Rectangle {
      rec.x = (scale == -1) ? (rec.left - rec.right) - rec.x : (rec.right + rec.width) + rec.x;
      return rec;
    }

    /**
     * @param rect
     * @param targetCoordinateSpace
     * @return
     *
     */
    static public function globalToLocalRect(rect:Rectangle, targetCoordinateSpace:DisplayObject):Rectangle {
      var topLeft:Point = rect.topLeft;
      var bottomRight:Point = rect.bottomRight;
      topLeft = targetCoordinateSpace.globalToLocal(topLeft);
      ;
      bottomRight = targetCoordinateSpace.globalToLocal(bottomRight);
      return new Rectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
    }

    static public function getRectangleCenter(rec:Rectangle):Point {
      return new Point((rec.x + rec.width) * .5, (rec.y + rec.height) * .5);
    }

    /**
     *
     * @param	from
     * @param	to
     * @return
     */
    static public function getDistanceFrom(from:DisplayObject, to:DisplayObject):Number {
      if (!from || !to)
        return 0;
      return Arithmetic.sqrt(Arithmetic.pow(from.x - to.x, 2) + Arithmetic.pow(from.y - to.y, 2));
    } // end function

    /**
     *
     * @param	colliderSpeed the current speed of the item that will crash.
     * @param	distanceToTarget the distance from the item that will crash to the item that it will collide into.
     * @return true if next step is collision; false if otherwise
     */
    static public function fastCollision(colliderSpeed:Number, distanceToTarget:Number):Boolean {
      var time:Number = distanceToTarget / colliderSpeed;

      if (time < 1)
        return true;
      else
        return false;
    }

  }
}
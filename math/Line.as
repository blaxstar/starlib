package net.blaxstar.starlib.math {
  import flash.geom.Point;

  /**
   *
   * 	...
   * @author 	Deron D. (SnaiLegacy)
   *
   */
  public class Line {
    public var start_point:Point;
    public var end_point:Point;

    public static function parse(x1:Number, y1:Number, x2:Number, y2:Number):Line {
      return new Line(new Point(x1, y1), new Point(x2, y2));
    }

    public function Line(fromPoint:Point, toPoint:Point) {
      this.start_point = fromPoint;
      this.end_point = toPoint;
    }

    /**
     * calculates the intersection point of two line segments (or lines, if includeExtensionCord is set to true) and returns that point if it exists. 
     * If there is no intersection or the intersection point is outside the line segments, it returns null.
     * 
     * @param line  another line segment.
     * @param includeExtensionCord boolean flag that determines whether to consider the line segments as extended infinitely.
     */
    public function intersect(intersecting_line:Line, includeExtensionCord:Boolean = false):Point {
      // current line instance values
      var x1:Number = start_point.x;
      var y1:Number = start_point.y;
      var x2:Number = end_point.x;
      var y2:Number = end_point.y;
      // intersecting line values
      var x3:Number = intersecting_line.start_point.x;
      var y3:Number = intersecting_line.start_point.y;
      var x4:Number = intersecting_line.end_point.x;
      var y4:Number = intersecting_line.end_point.y;
      // intersection point
      var intersect_x:Number;
      var intersect_y:Number;

      // Calculate the determinants
      var determinant:Number = (y2 - y1) * (x4 - x3) - (y4 - y3) * (x2 - x1);
      
      if (determinant == 0) {
        return null;
      }
      
      // calculating the intersection point
      intersect_x = ((x2 - x1) * (x4 - x3) * (y3 - y1) + (y2 - y1) * (x4 - x3) * x1 - (y4 - y3) * (x2 - x1) * x3) / determinant;
      intersect_y = ((y2 - y1) * (y4 - y3) * (x3 - x1) + (x2 - x1) * (y4 - y3) * y1 - (x4 - x3) * (y2 - y1) * y3) / (-determinant);
      
      if (includeExtensionCord) {
        // if we're not checking that the line is directly intersecting (physically touching), then just return the intersect point
        return new Point(intersect_x, intersect_y);
      } else {
        // otherwise, lets check to see if the lines are physically intersecting, and return the intersection point if they are
        if (((intersect_x - x1) * (intersect_x - x2) <= 0) && ((intersect_x - x3) * (intersect_x - x4) <= 0) && ((intersect_y - y1) * (intersect_y - y2) <= 0) && ((intersect_y - y3) * (intersect_y - y4) <= 0)) {
          return new Point(intersect_x, intersect_y);
        } else {
          // otherwise return null
          return null;
        }
      }
    }

    public function get length():Number {
      return Point.distance(start_point, end_point);
    }
  }
}
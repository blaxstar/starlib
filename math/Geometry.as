package net.blaxstar.starlib.math {

  import flash.display.DisplayObject;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  public class Geometry {
    /**
     * Checks if a rectangle contains a point.
     * @param rectangle Rectangle to use for checking.
     * @param point Point to use for checking.
     * @return true if the rectangle contains the point; false if otherwise
     */
    static public function rect_contains_point(rectangle:Rectangle, point:Point):Boolean {

      return (point.x > rectangle.x)
        && (point.x < rectangle.x + rectangle.width)
        && (point.y > rectangle.y)
        && (point.y < rectangle.y + rectangle.height);
    }

    static public function local_to_global_rect(local_rectangle:Rectangle, target_coordinate_space:DisplayObject):Rectangle {
      
      var top_left:Point = target_coordinate_space.localToGlobal(local_rectangle.topLeft);
      var bottom_right:Point = target_coordinate_space.localToGlobal(local_rectangle.bottomRight);

      var global_rect:Rectangle = new Rectangle(top_left.x, top_left.y, bottom_right.x - top_left.x, bottom_right.y - top_left.y);

      return global_rect;
    }

    static public function flip_rectangle(rectangle:Rectangle, scale_value:int = -1):Rectangle {
      rectangle.x = (scale_value == -1) ? (rectangle.left - rectangle.right) - rectangle.x : (rectangle.right + rectangle.width) + rectangle.x;
      return rectangle;
    }

    /**
     * 
     * @param rectangle 
     * @param target_coordinate_space 
     * @return 
     */
    static public function global_to_local_rect(rectangle:Rectangle, target_coordinate_space:DisplayObject):Rectangle {
      var top_left:Point = rectangle.topLeft;
      var bottom_right:Point = rectangle.bottomRight;
      top_left = target_coordinate_space.globalToLocal(top_left);

      bottom_right = target_coordinate_space.globalToLocal(bottom_right);
      return new Rectangle(top_left.x, top_left.y, bottom_right.x - top_left.x, bottom_right.y - top_left.y);
    }

    static public function get_rectangle_center(rectangle:Rectangle):Point {
      return new Point((rectangle.x + rectangle.width) * 0.5, (rectangle.y + rectangle.height) * 0.5);
    }

    /**
     * 
     * @param origin_object 
     * @param destination_object 
     * @return 
     */
    static public function get_distance_from(origin_object:DisplayObject, destination_object:DisplayObject):Number {
      if (!origin_object || !destination_object) {
        return 0;
      }
      return Arithmetic.sqrt(Arithmetic.pow(origin_object.x - destination_object.x, 2) + Arithmetic.pow(origin_object.y - destination_object.y, 2));
    } 

    /**
     *
     * @param	collider_speed the current speed of the object that will collide.
     * @param	distance_to_target the distance from the item that will collide to the item that it will collide into.
     * @return true if next step is collision; false otherwise.
     */
    static public function test_fast_collision(collider_speed:Number, distance_to_target:Number):Boolean {
      var time:Number = distance_to_target / collider_speed;

      if (time < 1) {
        return true;
      }

      return false;
    }

  }
}
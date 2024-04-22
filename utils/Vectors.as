package net.blaxstar.starlib.utils {
  public class Vectors {

    public static function from_array(array:Array):Vecto.<Object> {
      var new_vector:Vector.<Object> = new Vector.<Object>();

      for (var i:int = 0; i < array.length; i++) {
        new_vector.push(array[i]);
      }

      return new_vector;
    }
  }
}

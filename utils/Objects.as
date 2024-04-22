package net.blaxstar.starlib.utils {
  import flash.utils.ByteArray;
  import avmplus.getQualifiedClassName;
  import flash.utils.getDefinitionByName;

  public class Objects {
    static public function getObjectClass(obj:*):Class {
        return getDefinitionByName(getQualifiedClassName(obj)) as Class;
    }

    static public function getObjectClassName(obj:*):String {
        return getQualifiedClassName(obj);
    }

    static public function deepCopy(source:Object):* {
        var bytes:ByteArray = new ByteArray();
        bytes.position = 0;
        bytes.writeObject(source);
        bytes.position = 0;
        return bytes.readObject();
    }

    static public function numProperties(obj:Object):uint {
        var i:uint = 0;

        for (var o:Object in obj) {
            i++;
        }

        return i;
    }

    static public function hasProperties(obj:Object):Boolean {
        for (var o:Object in obj) {
            return true;
        }
        return false;
    }

    static public function isUniformObject(obj:Object, type:Class):Boolean {
        for (var o:* in obj) {
            if (!obj is type) {
                return false;
            }
        }
        return true;
    }

    static public function mergeObjects(...rest):Object {
        var finalObject:Object = {};

        for (var i:int = 0; i < rest.length; i++) {
            if (!getQualifiedClassName(rest[i]) == "Object")
                continue;
            if (rest[i] == {})
                continue;

            for (var o:Object in rest[i]) {
                finalObject[o] = rest[i][o];
            }
        }
        return finalObject;
    }

    static public function from_array(arr:Array, propNames:Array = null):Object {
        var outputObj:Object = {};
        for (var i:uint = 0; i < arr.length; i++) {
            if (propNames)
                outputObj[propNames[i]] = arr[i];
            else
                outputObj["obj_" + i] = arr[i];
        }

        return outputObj;
    }
  }
}

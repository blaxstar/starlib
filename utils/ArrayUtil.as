package net.blaxstar.starlib.utils {
  public class ArrayUtil {

    static public function merge(overwrite:Boolean, ...rest):Array {
        var arr:Array = [];

        for (var i:int = 0; i < rest.length; i++) {
            for (var j:int = 0; j < rest[i].length; j++) {
                if (!overwrite || !(arr.indexOf(rest[i][j]) > -1)) arr.push(rest[i][j]);
            }
        }
        return arr;
    }

     static public function from_object(obj:Object):Array {
        if (!obj)
            return null;

        var finalArray:Array = [];

        for (var o:Object in obj) {
            finalArray.push(o);
        }
        return finalArray;
    }

    static public function toByteArray(objs:Array):ByteArray {
        if (!objs) {
            return null;
        }

        var temp:ByteArray = new ByteArray();

        for each (var obj:* in objs) {
            var currentClassName:String = getQualifiedClassName(obj);
            if (currentClassName == "String") {
                temp.writeUTF(obj as String);
            } else if (currentClassName == "Array") {
                temp.writeObject(obj);
            } else if (getQualifiedClassName(obj) == "Boolean") {
                temp.writeBoolean(obj as Boolean);
            } else if (currentClassName == "Number") {
                temp.writeDouble(obj as Number);
            } else if (currentClassName == "int") {
                temp.writeInt(obj as int);
            } else if (currentClassName == "uint") {
                temp.writeUnsignedInt(obj as uint);
            } else {
                temp.writeObject(temp as Object);
            }
        }

        temp.position = 0;
        return temp;
    }

    static public function fromByteArray(bytes:ByteArray, classes:Array):Array {
        if (!bytes || !classes || bytes.length == 0 || classes.length == 0) {
            return null;
        }

        var retArr:Array = [];

        bytes.position = 0;

        for each (var cl:* in classes) {
            if (!(cl is Class)) {
                return null;
            }

            try {
                if (getQualifiedClassName(cl) == "String") {
                    retArr.push(bytes.readUTF());
                } else if (getQualifiedClassName(cl) == "Array") {
                    retArr.push(fromByteArray(bytes, classes));
                } else if (getQualifiedClassName(cl) == "Boolean") {
                    retArr.push(bytes.readBoolean());
                } else if (getQualifiedClassName(cl) == "Number") {
                    retArr.push(bytes.readDouble());
                } else if (getQualifiedClassName(cl) == "int") {
                    retArr.push(bytes.readInt());
                } else if (getQualifiedClassName(cl) == "uint") {
                    retArr.push(bytes.readUnsignedInt());
                } else {
                    retArr.push(bytes.readObject() as cl);
                }
            } catch (e:Error) {
                return null;
            }
        }

        return retArr;
    }
  }
}

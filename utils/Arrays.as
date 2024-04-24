package net.blaxstar.starlib.utils {
    import flash.utils.ByteArray;
    import avmplus.getQualifiedClassName;
    import net.blaxstar.starlib.debug.DebugDaemon;

    public class Arrays {

        static public function merge(overwrite:Boolean = false, ... rest):Array {
            var arr:Array = [];

            for (var i:int = 0; i < rest.length; i++) {
                for (var j:int = 0; j < rest[i].length; j++) {
                    if (!overwrite || !(arr.indexOf(rest[i][j]) > -1)) {
                        arr.push(rest[i][j]);
                    }
                }
            }
            return arr;
        }

        static public function from_vector(vector:*):Array {
            var vector_class_name:String = getQualifiedClassName(vector);
            if (!(vector_class_name.indexOf("__AS3__.vec::Vector") > -1)) {
              // is a vector instance
              DebugDaemon.write_error("argument `vector` must be a valid Vector instance!");
              return null;
            }

            var array:Array = [];
            vector.forEach(function(item:*, index:int, vector:*):void {
                array[index] = item;
            });
            return array;
        }

        static public function from_object(obj:Object):Array {
            if (!obj)
                return null;

            var final_array:Array = [];

            for (var o:Object in obj) {
                final_array.push(o);
            }
            return final_array;
        }

        static public function toByteArray(objs:Array):ByteArray {
            if (!objs) {
                return null;
            }

            var temp:ByteArray = new ByteArray();

            for each (var obj:* in objs) {

                var current_class_name:String = getQualifiedClassName(obj);

                if (current_class_name == "String") {
                    temp.writeUTF(obj as String);
                } else if (current_class_name == "Array") {
                    temp.writeObject(obj);
                } else if (getQualifiedClassName(obj) == "Boolean") {
                    temp.writeBoolean(obj as Boolean);
                } else if (current_class_name == "Number") {
                    temp.writeDouble(obj as Number);
                } else if (current_class_name == "int") {
                    temp.writeInt(obj as int);
                } else if (current_class_name == "uint") {
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

            var return_array:Array = [];

            bytes.position = 0;

            for each (var current_item_class:* in classes) {
                if (!(current_item_class is Class)) {
                    return null;
                }

                try {
                    if (getQualifiedClassName(current_item_class) == "String") {
                        return_array.push(bytes.readUTF());
                    } else if (getQualifiedClassName(current_item_class) == "Array") {
                        return_array.push(fromByteArray(bytes, classes));
                    } else if (getQualifiedClassName(current_item_class) == "Boolean") {
                        return_array.push(bytes.readBoolean());
                    } else if (getQualifiedClassName(current_item_class) == "Number") {
                        return_array.push(bytes.readDouble());
                    } else if (getQualifiedClassName(current_item_class) == "int") {
                        return_array.push(bytes.readInt());
                    } else if (getQualifiedClassName(current_item_class) == "uint") {
                        return_array.push(bytes.readUnsignedInt());
                    } else {
                        return_array.push(bytes.readObject() as current_item_class);
                    }
                } catch (e:Error) {
                    return null;
                }
            }

            return return_array;
        }
    }
}

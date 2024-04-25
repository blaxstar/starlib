package net.blaxstar.starlib.structs {

    public class LinkedListNode {

        private var _node_value:Object;
        private var _next:LinkedListNode;

        public function LinkedListNode(node_value:Object = null, next:LinkedListNode = null) {

            if (!node_value) {
                _node_value = {};
            } else {
                _node_value = node_value;
            }

            if (next) {
                _next = next;
            }
        }

        public function get value():Object {
            return _node_value;
        }

        public function set value(value:Object):void {
            _node_value = value;
        }

        public function get next():LinkedListNode {
            return _next;
        }

        public function set next(value:LinkedListNode):void {
            _next = value;
        }
    }
}

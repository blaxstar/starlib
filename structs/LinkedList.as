package net.blaxstar.starlib.structs {

    public class LinkedList {

        private var _head:LinkedListNode;
        private var _tail:LinkedListNode;
        private var _size:uint;
        private var _print_string:String;

        public function LinkedList() {
            _size = 0;
            _print_string = "";
        }

        public function append(list_node:LinkedListNode):LinkedListNode {
            if (!_head) {
                _head = list_node;
                _tail = _head;
                _print_string = String(_head.value);
            } else {
                var current_node:LinkedListNode = _head;
                while (current_node.next) {
                    current_node = current_node.next;
                }
                current_node.next = list_node;
                _tail = list_node;
                _print_string = _print_string.concat(" => " + list_node.value);
            }
            return list_node;
        }

        public function insert_at(list_node:LinkedListNode, index:uint):LinkedListNode {
            var current_node:LinkedListNode = this._head;
            if (index == 0) {
                list_node.next = _head;
                _head = list_node;
                
            } else {
                if (_head == null) {
                    _head == list_node;
                } else {
                    for (var i:int = 0; i < index - 1 && current_node != null; i++) {
                        current_node = current_node.next;
                    }
                    if (current_node != null) {
                        list_node.next = current_node.next;
                        current_node.next = list_node;
                    }
                }
            }
            return list_node;
        }

        public function remove_at(index:uint):Object {
            var deleted_node_data:Object;
            if (index == 0) {
                deleted_node_data = _head.value;
                _head = _head.next;
            } else {
                var previous_node:LinkedListNode = null;
                var current_node:LinkedListNode = _head;

                for (var i:int = 0; i < index && current_node != null; i++) {
                    previous_node = current_node;
                    current_node = current_node.next;
                }
                if (current_node != null) {
                    if (current_node === _tail) {
                      _tail = previous_node;
                    }
                    deleted_node_data = current_node.value;
                    previous_node.next = current_node.next;
                }
            }
            return deleted_node_data;
        }

        public function print():String {
            generate_print_string();
            return _print_string;
        }

        private function generate_print_string():void {
            var current_node:LinkedListNode = _head;
            _print_string = "";
            _size = 0;
            while (current_node.next) {
                _print_string = _print_string.concat(String(current_node.value) + " => ");
                _size = _size + 1;
                current_node = current_node.next;
            }
            _print_string = _print_string.concat(String(current_node.value));
            _tail = current_node;
        }

        public function get head():LinkedListNode {
            return _head;
        }

        public function get tail():LinkedListNode {
            return _tail;
        }

        public function get size():uint {
          var current_node:LinkedListNode = _head;
          _size = 0;

          while (current_node != null) {
            _size = _size + 1;
            current_node = current_node.next;
          }

          return _size;
        }

    }
}

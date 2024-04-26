package net.blaxstar.starlib.components {

    import flash.utils.Dictionary;

    /**
     * ...
     * @author Deron Decamp
     */
    public class Suggestitron {
        static private var _num_suggestions:uint = 0;
        private var _suggestion_datastore:Vector.<Suggestion>;
        private var _input_prefix_cache:Dictionary;

        public function Suggestitron() {
            _suggestion_datastore = new Vector.<Suggestion>();
            _input_prefix_cache = new Dictionary(true);
        }

        public function generate_suggestions_from_input(input:String, suggestion_limit:uint = 10):Vector.<Suggestion> {

            if (_input_prefix_cache.hasOwnProperty(input)) {
              return _input_prefix_cache[input];
            }

            var suggestion_list:Vector.<Suggestion> = new Vector.<Suggestion>();
            // using regex for validation of the pattern...
            var words_regex:RegExp = new RegExp('(' + input.split(' ').join('|') + ')', / /gi);

            for (var i:uint = 0; i < _num_suggestions; i++) {
                if (i > suggestion_limit + 1) {
                    return suggestion_list;
                }
                // ...but using string function for search, as it is an order of magnitude faster.
                var matches:Array = _suggestion_datastore[i].label.match(words_regex);
                if (!matches)
                    return suggestion_list;
                if (matches.length < 1) {
                    continue;
                } else {
                    suggestion_list.push(_suggestion_datastore[i]);
                }
            }
            _input_prefix_cache[input] = suggestion_list;
            return suggestion_list;
        }

        public function add_suggestion_data(label:String, data:Object):void {
            var resource:Suggestion = new Suggestion();
            resource.id = _num_suggestions++;
            resource.label = label ? label : "null label";
            resource.data = data ? data : null;
            _suggestion_datastore.push(resource);
        }

        public function parse_json_string(json_string:String):void {
            var json:Object = JSON.parse(json_string);
            for (var item:String in json) {
                add_suggestion_data(item, json[item]);
            }
        }

        public function print_suggestion_list():String {
            return JSON.stringify(_suggestion_datastore);
        }

        public function clear():void {
            _suggestion_datastore.length = 0;
            _num_suggestions = 0;
            _input_prefix_cache = null;
        }

        public function get has_suggestions():Boolean {
            return _suggestion_datastore && _suggestion_datastore.length > 0;
        }
    }

}

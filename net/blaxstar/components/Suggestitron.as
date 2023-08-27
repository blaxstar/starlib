package net.blaxstar.components {

  import flash.filesystem.File;
  import flash.utils.ByteArray;

  import net.blaxstar.io.URL;

  /**
   * ...
   * @author Deron Decamp
   */
  public class Suggestitron {
    static private var _rid:uint = 0;

    private var _resourceVector:Vector.<Suggestion>;

    public function Suggestitron() {
      _resourceVector = new Vector.<Suggestion>();
    }

    public function generateSuggestions(input:String, suggestionLimit:uint = 10):Vector.<Suggestion> {

      var suggestionVector:Vector.<Suggestion> = new Vector.<Suggestion>();

      // using regex for validation of the pattern...
      var wordreg:RegExp = new RegExp('(' + input.split(' ').join('|') + ')', / /gi);

      for (var i:uint = 0; i < _resourceVector.length; i++) {
        if (i > suggestionLimit + 1)
          return suggestionVector;
        // ...but using string function for search, as it is an order of magnitude faster.
        var matches:Array = _resourceVector[i].label.match(wordreg);
        if (!matches)
          return suggestionVector;
        if (matches.length < 1) {
          continue;
        }
        else {
          suggestionVector.push(_resourceVector[i]);
        }
      }
      return suggestionVector;
    }

    public function addData(label:String, data:Object):void {
      var resource:Suggestion = new Suggestion();
      resource.linkageid = _rid++;
      resource.label = label;
      resource.data = data;
      _resourceVector.push(resource);
    }

    public function loadFromJsonString(s:String):void {
      var json:Object = JSON.parse(s);
      for (var item:String in json) {
        addData(item, json[item]);
      }
    }

    public function printDB():String {
      return JSON.stringify(_resourceVector);
    }

    public function get hasSuggestions():Boolean {
      return (_resourceVector && _resourceVector.length > 0);
    }
  }

}
package net.blaxstar.starlib.utils {
  import avmplus.getQualifiedClassName;

  /**
   * ...
   * @author Deron D.
   */
  public class Strings {

    static public function is_empty_or_null(val:String):Boolean {
      if (!val) return true;
      val = condenseString(val);
      return (val == "");
    }

    static public function is_valid_email(email:String):Boolean {
      var emailExpression:RegExp = /([a-z0-9._-]+?)@([a-z0-9.-]+)\.([a-z]{2,4})/i;
      return emailExpression.test(email);
    }

    static public function is_valid_filepath(filepath:String):Boolean {
      if (is_empty_or_null(filepath)) {
        return false;
      }

      var windows_filepath_expression:RegExp = /^(?:[a-zA-Z]:\\|\\\\)(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$/igm;

      var linux_mac_filepath_expression:RegExp = /^(?:\/(?:[^\/]+\/?)*)$/igm;

      return windows_filepath_expression.test(filepath) || linux_mac_filepath_expression.test(filepath);
    }

    /**
     * Removes whitespace and extras from a string.
     * @param	inputString The string to condense.
     * @return
     */
    static public function condenseString(inputString:String, removeHTML:Boolean = false, removeSpecialChars:Boolean = false):String {
      var c:RegExp = /"/g;
      inputString = inputString.replace(c, "");
      inputString = inputString.split(" ").join("");
      inputString = inputString.split("\r").join("");
      inputString = inputString.split("\t").join("");
      inputString = inputString.split("%20").join(" ");

      if (removeHTML)
        inputString = html_to_string(inputString);
      if (removeSpecialChars)
        inputString = getWordsFromString(inputString, true).join(" ");
      return inputString;
    }
    /**
     * replaces empty spaces at the beginning and end of a string.
     * @param str the string to trim.
     * @return the trimmed string.
     */
    static public function trim(str:String):String {
      return str.replace(/^\s+|\s+$/g, '');
    }

    /**
     * 
     * @param inputString 
     * @param withNumbers 
     * @return 
     */
    static public function getWordsFromString(inputString:String, withNumbers:Boolean = false):Vector.<String> {
      var onlyWords:String = (withNumbers) ? "/([a-zA-Z0-9]+)/g" : "/([a-zA-Z]+)/g";
      var wordArray:Array = inputString.match(onlyWords);
      var wordArrayLen:uint = wordArray.length;
      var words_array:Vector.<String> = new Vector.<String>();

      for (var i:uint = 0; i < wordArrayLen; i++) {
        words_array.push(wordArray[i]);
      }

      return words_array;
    }

    /**
     * Splits a string into an array or vector by the specified delimiter.
     * @param	string the string you want to split.
     * @param	splitTo the array or vector you want to split to.
     * @param	splitAt specifies the delimiter used to split the string.
     */
    static public function splitStringTo(string:String, splitAt:String, result_list:* = null):* {

      if (!result_list) {
        result_list = new Array();
      }

      for (var i:int = 0; i < string.split(splitAt).length; ++i) {
        result_list.push(string.split(splitAt)[i]);
      }

        return result_list;
    }

    /**
     * 
     * @param array 
     * @return 
     */
    static public function from_array(array:Array):String {
        var final_string:String = "{&quot}";
        var i:uint = 0;

        for (var array_item:Object in array) {
            ++i;
            if (array_item is Array)
                final_string = final_string + from_array(array_item as Array) + "{&quot}";
            else if (getQualifiedClassName(array_item) == "Object")
                final_string = final_string + JSON.stringify(array[array_item]) + "{&quot}";
            else
                (i == array.length) ? final_string = final_string + array[array_item] + "{&quot}" : final_string = final_string + array[array_item] + "|";
        }

        return final_string.replace("{&quot}", "\"");
    }

    /**
     * 
     * @return 
     */
    static public function current_time_as_string():String {
      var date:Date = new Date();
      var date_string:String = "";
      date_string = (date.hours >= 13) ? String(date.hours - 12) : String(date.hours);
      date_string = date_string + ":" + ((date.minutes < 10) ? ("0" + date.minutes) : (date.minutes));
      date_string = date_string + ((date.hours >= 12) ? "p" : "a");

      return date_string;
    }

    /**
     * 
     * @param text 
     * @return 
     */
    static public function html_to_string(text:String):String {
      var remove_html_regexp:RegExp = new RegExp("<[^<]+?>", "gi");
      text = text.replace(remove_html_regexp, "");
      text = text.replace("&amp;", "&");
      return text;
    }

    /**
     * 
     * @param url 
     * @return 
     */
    static public function get_file_name_from_url(url:String):String {
      var file_name_index:int = url.lastIndexOf("/");
      
      if (file_name_index == url.length - 1) {
        url = url.substr(0, (url.length - 1));
        file_name_index = url.lastIndexOf("/");
      }

      return url.substr(file_name_index + 1);
    }

    /**
     * 
     * @param a 
     * @param b 
     * @return 
     */
    static public function alpha_numeric_sort(a:String, b:String):int {
      a = a.toLowerCase();
      b = b.toLowerCase();
      
      var letters_expression:RegExp = /[^a-zA-Z]/g;
      var numbers_expression:RegExp = /[^0-9]/g;
      var string_a_letters:String = a.replace(letters_expression, "");
      var string_b_letters:String = b.replace(letters_expression, "");

      if (string_a_letters === string_b_letters) {
        var string_a_numbers:Number = parseInt(a.replace(numbers_expression, ""), 10);
        var string_b_numbers:Number = parseInt(b.replace(numbers_expression, ""), 10);
        return string_a_numbers === string_b_numbers ? 0 : string_a_numbers > string_b_numbers ? 1 : -1;
      }
      else {
        return string_a_letters > string_b_letters ? 1 : -1;
      }
    }

    /**
     * uses the levenshtein algorithm to determine the difference in two strings.
     * @param string_a 
     * @param string_b 
     * @return an integer denoting how many characters are different in one string than the other.
     */
    static public function levenshtein(string_a:String, string_b:String):int {
      var character_matrix:Array = [];
      var string_a_length:int = string_a.length;
      var string_b_length:int = string_b.length;

      for (var i:int = 0; i <= string_a_length; i++) {
        character_matrix[i] = new Array(string_b_length + 1);
        character_matrix[i][0] = i;
      }

      for (var j:int = 0; j <= string_b_length; j++) {
        character_matrix[0][j] = j;
      }

      for (i = 1; i <= string_a_length; i++) {
        for (j = 1; j <= string_b_length; j++) {
          var cost:int = (string_a.charAt(i - 1) == string_b.charAt(j - 1)) ? 0 : 1;
          character_matrix[i][j] = Math.min(character_matrix[i - 1][j] + 1, character_matrix[i][j - 1] + 1, character_matrix[i - 1][j - 1] + cost);
        }
      }

      return character_matrix[string_a_length][string_b_length];
    }
  }

}

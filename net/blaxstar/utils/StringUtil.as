package net.blaxstar.utils 
{
	/**
	 * ...
	 * @author Deron D.
	 */
	public class StringUtil 
	{
		
		static public function stringIsEmpty(val:String):Boolean
		{
			val = condenseString(val);
			return (val == "");
		}
		
		static public function isValidEmail(email:String):Boolean
		{
			var emailExpression:RegExp = /([a-z0-9._-]+?)@([a-z0-9.-]+)\.([a-z]{2,4})/i;
			return emailExpression.test(email);
		}
		
		/**
		 * Removes whitespace and extras from a string.
		 * @param	inputString The string to condense.
		 * @return
		 */
		static public function condenseString(inputString:String, removeHTML:Boolean = false, removeSpecialChars:Boolean = false):String
		{
			var c:RegExp = /"/g;
			inputString = inputString.replace(c, "");
			inputString = inputString.split(" ").join("");
			inputString = inputString.split("\r").join("");
			inputString = inputString.split("\t").join("");
			inputString = inputString.split("%20").join(" ");
			
			if (removeHTML) inputString = htmlToString(inputString);
			if (removeSpecialChars) inputString = getWordsFromString(inputString, true).join(" ");
			return inputString;
		}
		
    static public function trim(str:String):String {
      return str.replace(/^\s+|\s+$/g, '');
    }

		static public function getWordsFromString(inputString:String, withNumbers:Boolean=false):Vector.<String>
		{
			var onlyWords:String = (withNumbers) ? "/([a-zA-Z0-9]+)/g" : "/([a-zA-Z]+)/g";
			var wordArray:Array = inputString.match(onlyWords);
			var wordArrayLen:uint = wordArray.length;
			var retVec:Vector.<String> = new Vector.<String>();
			
			for (var i:uint = 0; i < wordArrayLen; i++)
			{
				retVec.push(wordArray[i]);
			}
			
			return retVec;
		}
		
		/**
		 * Splits a string into an array or vector by the specified delimiter.
		 * @param	string the string you want to split.
		 * @param	splitTo the array or vector you want to split to.
		 * @param	splitAt specifies the delimiter used to split the string.
		 */
		static public function splitStringTo(string:String, splitAt:String, splitTo:* = null):*
		{
			var isReturn:Boolean = false;
			if (!splitTo)
			{
				splitTo = new Array();
				isReturn = true;
			}
			
			for (var i:int = 0; i < string.split(splitAt).length; ++i)
			{
				splitTo.push(string.split(splitAt)[i]);
			}
			
			if (isReturn)
				return splitTo;
		}
		
		static public function currentTimeAsString():String
		{
			var date:Date = new Date();
			var stringDate:String = "";
			stringDate = (date.hours >= 13) ? String(date.hours - 12) : String(date.hours);
			stringDate = stringDate + ":" + ((date.minutes < 10) ? ("0" + date.minutes) : (date.minutes));
			stringDate = stringDate + ((date.hours >= 12) ? "p" : "a");
			
			return stringDate;
		}
		
		static public function htmlToString(text:String):String 
		{
			var removeHtmlRegExp:RegExp = new RegExp("<[^<]+?>", "gi");
			text = text.replace(removeHtmlRegExp, "");
			text = text.replace("&amp;", "&");
			return text;
		}
		
		static public function getFileNameFromURL(url:String) : String
        {
            var fileNameIndex:int = url.lastIndexOf("/");
            if (fileNameIndex == url.length - 1) url = url.substr(0, (url.length - 1));
            fileNameIndex = url.lastIndexOf("/");
			if (fileNameIndex == url.length - 1) return url;
            return url.substr(fileNameIndex + 1);
        }
		
		static public function alphaNumericSort(a:String, b:String):int
		{
			a = a.toLowerCase();
			b = b.toLowerCase();
			var reA:RegExp = /[^a-zA-Z]/g;
			var reN:RegExp = /[^0-9]/g;
			var aA:String = a.replace(reA, "");
			var bA:String = b.replace(reA, "");
			if (aA === bA)
			{
				var aN:Number = parseInt(a.replace(reN, ""), 10);
				var bN:Number = parseInt(b.replace(reN, ""), 10);
				return aN === bN ? 0 : aN > bN ? 1 : -1;
			}
			else
				return aA > bA ? 1 : -1;
		}

		static public function levenshtein(a:String, b:String):int {
			var matrix:Array = [];
			var aLen:int = a.length;
			var bLen:int = b.length;

			for (var i:int = 0; i <= aLen; i++) {
				matrix[i] = new Array(bLen + 1);
				matrix[i][0] = i;
			}

			for (var j:int = 0; j <= bLen; j++) {
				matrix[0][j] = j;
			}

			for (i = 1; i <= aLen; i++) {
				for (j = 1; j <= bLen; j++) {
					var cost:int = (a.charAt(i - 1) == b.charAt(j - 1)) ? 0 : 1;
					matrix[i][j] = Math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost);
				}
			}

			return matrix[aLen][bLen];
		}

		static private var mStrings:Object = {};
		
		static public function formatJSON(serializedJSON:String, useTabs:Boolean = false):String
		{
			// Save backslashes in strings and strings, so that they were not modified during the formatting.
			serializedJSON = serializedJSON.replace(/(\\.)/g, formatJSON_SaveString);
			serializedJSON = serializedJSON.replace(/(".*?"|'.*?')/g, formatJSON_SaveString);
			// Remove white spaces
			serializedJSON = serializedJSON.replace(/\s+/, "");
			
			var indent:int = 0;
			var result:String = "";
			
			for (var i:uint = 0; i < serializedJSON.length; i++)
			{
				var char:String = serializedJSON.charAt(i);
				switch (char)
				{
					case "{": 
					case "[": 
						result += char + "\n" + formatJSON_MakeTabs(++indent, useTabs);
						break;
					case "}": 
					case "]": 
						result += "\n" + formatJSON_MakeTabs(--indent, useTabs) + char;
						break;
					case ",": 
						result += ",\n" + formatJSON_MakeTabs(indent, useTabs);
						break;
					case ":": 
						result += ": ";
						break;
					default: 
						result += char;
						break;
				}
			}
			
			result = result.replace(/\{\s+\}/g, formatJSON_StripWhiteSpace);
			result = result.replace(/\[\s+\]/g, formatJSON_StripWhiteSpace);
			result = result.replace(/\[[\d,\s]+?\]/g, formatJSON_StripWhiteSpace);
			
			// restore strings
			result = result.replace(/\\(\d+)\\/g, formatJSON_RestoreString);
			// restore backslashes in strings
			result = result.replace(/\\(\d+)\\/g, formatJSON_RestoreString);
			
			return result;
		}
		
		static private function formatJSON_SaveString(... args):String
		{
			var string:String = args[0];
			var index:uint = uint(args[2]);
			
			mStrings[index] = string;
			
			return "\\" + args[2] + "\\";
		}
		
		static private function formatJSON_RestoreString(... args):String
		{
			var index:uint = uint(args[1]);
			return mStrings[index];
		}
		
		static private function formatJSON_StripWhiteSpace(... args):String
		{
			var value:String = args[0];
			return value.replace(/\s/g, '');
		}
		
		static private function formatJSON_MakeTabs(count:int, useTabs:Boolean):String
		{
			return new Array(count + 1).join(useTabs ? "\t" : "     ");
		}
	}

}
//CodeUtil
package jp.psyark.utils
{
    public class CodeUtil extends Object
    {
        public function CodeUtil()
        {
            super();
            return;
        }

        public static function getDefinitionLocalName(arg1:String):String
        {
            var loc1:*=arg1.match(new RegExp("\\Wpublic\\s+(?:class|interface|function|namespace)\\s+([_a-zA-Z]\\w*)"));
            return loc1 && loc1[1] ? loc1[1] : "";
        }

        public static function getDefinitionName(arg1:String):String
        {
            var loc1:*=getDefinitionLocalName(arg1);
            if (loc1 == "") 
            {
                return "";
            }
            var loc2:*=arg1.match(new RegExp("package\\s+([_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*)"));
            if (loc2 && loc2[1]) 
            {
                loc1 = loc2[1] + "." + loc1;
            }
            return loc1;
        }
    }
}



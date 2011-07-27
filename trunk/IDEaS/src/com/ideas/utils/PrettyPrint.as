package com.ideas.utils
{
	public class PrettyPrint
	{
		public static function autoIndent(str:String):String {
			
			var arr:Array=(str.split("\r"));
			var totalBrac:int = 0;
			var comment:int = 0;
			var updatedArr:Array = [];
			var string:int = 0;
			var brackPos:Array;
			for (var i:int=0; i<arr.length; i++) {//for each line
				var brac:int = 0;
				arr[i] = arr[i].split("\t").join('');
				while (String(arr[i]).charAt(0)==" ") {
					arr[i] = arr[i].substr(1,arr[i].length - 1);
				}
				if(arr[i].length==0){
					continue;
				}
				brackPos=[];
				for (var j:int=0; j<arr[i].length; j++) {//for each character in line
					while (String(arr[i]).charAt(arr[i].length-1)==" " || String(arr[i]).charAt(arr[i].length-1)=="\t") {
						arr[i] = arr[i].substr(0,arr[i].length - 1);
					}
					if (String(arr[i]).charAt(j) == "'" || String(arr[i]).charAt(j) == '"') {
						string++;
					}
					if (String(arr[i]).charAt(j) == "/") {//check for complex coment
						if (String(arr[i]).charAt(j + 1) && String(arr[i]).charAt(j + 1) == "*") {
							comment++;
						}
					}
					if (String(arr[i]).charAt(j) == "*") {//check for complex coment
						if (String(arr[i]).charAt(j + 1) && String(arr[i]).charAt(j + 1) == "/") {
							comment--;
						}
					}
					if (String(arr[i]).charAt(j) == "/") {//check for regular coment
						if (String(arr[i]).charAt(j + 1) && String(arr[i]).charAt(j + 1) == "/") {
							brac = 0;
							if (comment == 0) {
								//create problem maybe put a note
								break;//skip to next line
							}
						}
					}
					if (j >= arr[i].length - 1 && comment > 0) {
						brac = 0;
						break;
					}
					// if found inside string no indent change
					if (j >= arr[i].length - 1 && string > 0 && string % 2 == 0) {
						brac=0;
						string=0;
						brackPos=[];
						//trace("comment"+ string)
					}
					// if found left curly bracket increase indent
					if (String(arr[i]).charAt(j) == "{") {
						brackPos.push({pos:j,dir:1});
						brac++;
					}
					// if found right curly bracket decrease indent
					if (String(arr[i]).charAt(j) == "}") {
						brackPos.push({pos:j,dir:-1});
						brac--;
						//trace("tick " +j,brac);
					}
				}
				if(brackPos.length>1){
					//trace(brackPos[0].pos+" : "+brackPos[0].dir+":"+totalBrac)
					//trace("bef",i,arr.join("||"))
					arr.splice(i, 1, arr[i].substring(0,brackPos[0].pos+1),arr[i].substring(brackPos[0].pos+1,arr[i].length));
					//trace("aft",i,arr.join("||"))
					if(brackPos[0].dir<0){
						buildOutputLine(updatedArr,arr[i],totalBrac-1);
					}else{
						buildOutputLine(updatedArr,arr[i],totalBrac);
					}
					totalBrac+=brackPos[0].dir;
				}else{
					if(brac<0){
						buildOutputLine(updatedArr,arr[i],totalBrac-1);
					}else{
						buildOutputLine(updatedArr,arr[i],totalBrac);
					}
					totalBrac+=brac;
				}
			}
			//output
			var finalStr:String = "";
			for (var k:int=0; k<updatedArr.length; k++) {
				finalStr+=updatedArr[k].tabs+updatedArr[k].line+((k==updatedArr.length-1)?"":"\n");
			}
			return finalStr;
		}
		private static function buildOutputLine(ouputArr:Array,lineString:String,totalBrackets:int):void{
			var tabs:String = "";
			for (var t:int=0; t<totalBrackets; t++) {
				tabs +=  "\t";
			}
			
			ouputArr.push({line:lineString,tabs:tabs});
		}
	}
}
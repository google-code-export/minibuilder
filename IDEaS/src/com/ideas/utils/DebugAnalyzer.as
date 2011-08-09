package com.ideas.utils
{
	public class DebugAnalyzer
	{
		public static const WARNING:String="Warning";
		public static const ERROR:String="Error"
		public static function parse(log:String):Array{
			var warning:Array=getInfo(log,WARNING);
			var error:Array=getInfo(log,ERROR);
			if(warning && error){
				return warning.concat(error);
			}else if(warning){
				return warning;
			}else if(error){
				return error;
			}
			return null;
		}
		private static function getInfo(log:String,type:String):Array{
			var arr:Array;
			
			var warning:Array=log.split(type);
			
			for(var i:int=1;i<warning.length;i++){
				//trace(warning[i]);
				var nm:String=warning[i-1].substring(Math.max(0, warning[i-1].length - 20), warning[i-1].length).split('').reverse().join('')
				var pattern:RegExp = /\)([^(]+)\(/g
				var catches:Object = pattern.exec(nm);
				var line:uint=uint(catches[1].split('').reverse().join(''));
				
				var description:String=type+warning[i].split("^")[0]+"^";
				var ds:Array=description.split("\n");
				//trace(ds);
				var pos:uint=ds[3].length;
				
				if(!arr){
					arr=[]
				}
				var hasLine:Boolean=false;
				for(var k:int=0;k<arr.length;k++){
					if(arr[k].line==line){
						hasLine=true;
						
						break;
					}
				}
				if(!hasLine){
					//trace(line+" | "+ds[0]+" | "+pos);
					arr.push({line:line,type:type,message:ds[0],position:pos});
				}
			}
			return arr;
		}
	}
}
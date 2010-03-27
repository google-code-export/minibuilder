package ro.minibuilder.data
{
	import __AS3__.vec.Vector;
	import com.victordramba.console.debug;
	
	import flash.utils.ByteArray;
	
	import ro.minibuilder.asparser.Parser;
	import ro.minibuilder.asparser.TypeDB;
	import ro.minibuilder.swcparser.SWCParser;
	import ro.minibuilder.swcparser.SWFParser;

	public class BatchLoader
	{
		private var fileIndex:int;
		private var fileList:Vector.<String>;
		private var onProgress:Function;
		private var project:IProjectPlug;
		
		public function BatchLoader(project:IProjectPlug)
		{
			this.project = project;
		}
		
		/**
		 * function onProgress(p:Number, fileName:String):void // p=0..1
		 */
		public function load(fileList:Vector.<String>, onProgress:Function):void
		{
			if (this.fileList)
				throw new Error('Previous load did not finish');
			
			fileIndex = 0;
			this.fileList = fileList;
			this.onProgress = onProgress;
			addNextFile();
		}
		
		private function addNextFile():void
		{
			if (fileIndex == fileList.length)
			{
				fileList = null;
				onProgress(1, '');
				return;
			}
			var fileName:String = fileList[fileIndex++];
			//debug(fileName);
			onProgress(fileIndex/fileList.length, fileName);
			
			if (/\.as$/.test(fileName))
			{
				project.readTextFile(fileName, function (source:String):void
				{
					Parser.addSourceFile(source, fileName, addNextFile);
				});
			}
			//ignore bin, bin-relese and bin-debug swf
			else if (!fileName.indexOf('bin')==0 && /\.sw[fc]$/.test(fileName) && /^\\?libs?/.test(fileName))
			{
				debug('LIB ' + fileName);
				project.readBinFile(fileName, function (data:ByteArray):void
				{
					var db:TypeDB;
					if (/swf$/.test(fileName))
					{
						TypeDB.setDB(fileName, db = SWFParser.parse(data));
						/*debug('\nDUMP: ' + fileName);
						//debug(SWFParser.scripts.join('\n'));
						debug('len='+data.length);
						XML.prettyPrinting = true;
						debug(SWFParser.getDependency(data).toXMLString());
						XML.prettyPrinting = false;
						debug('\n\n');*/
					}
					else
					{
						TypeDB.setDB(fileName, db = SWCParser.parse(data));
					}
					addNextFile();
				});
			}
				
			else
				addNextFile();
		}		
	}
}
/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

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
			else if (!fileName.indexOf('bin')==0 && /\.sw[fc]$/.test(fileName) && 
				(/^\\?libs?/.test(fileName) || fileName.indexOf('sdk://') == 0))
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
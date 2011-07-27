/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.data.fileBased
{
	import __AS3__.vec.Vector;
	import com.victordramba.console.debug;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	import ro.minibuilder.data.IProjectPlug;
	import ro.minibuilder.data.ProjectConfig;

	public class FileProject implements IProjectPlug
	{
		private var fileList:Vector.<String>;
		private var rootPath:String;
		private var _config:ProjectConfig;
		
		/**
		 * function onReady():void
		 */
		public function open(url:String, onReady:Function):void
		{
			fileList = new Vector.<String>();
			rootPath = url.replace(/\\/g, '/');
			if (rootPath.charAt(rootPath.length-1) != '/')
				rootPath += '/';
			
			debug('rootPath='+rootPath);
			
			recListFiles(rootPath.substr(0, -1));
			
			_config = new ProjectConfig;
			
			//read config
			readTextFile('.actionScriptProperties', function(str:String):void {
				_config.load(XML(str));
				onReady();
			});
		}
		
		public function get config():ProjectConfig
		{
			return _config; 
		}
		
		public function get path():String
		{
			return rootPath;
		}
		
		public function get name():String
		{
			var tmp:String = path.substr(0, -1);
			return tmp.substr(tmp.lastIndexOf('/')+1);
		}
		
		private function recListFiles(path:String):void
		{
			var file:File = new File(path);
			fileList.push(path.substr(rootPath.length));
			if (!file.isDirectory) return;
			for each (var f:File in file.getDirectoryListing())
				recListFiles(path + '/' + f.name);
		}
		
		public function isDirectory(path:String):Boolean
		{
			return new File(rootPath).resolvePath(path).isDirectory
		}
		
		public function listFiles():Vector.<String>
		{
			return fileList;
		}
		
		/**
		 * function onReady(source:String):void
		 */
		public function readTextFile(url:String, onReady:Function):void
		{
			var file:File = new File(rootPath).resolvePath(url);
			filesReading[file] = true;
			file.load();
			file.addEventListener(Event.COMPLETE, function (e:Event):void {
				if (file.data[0]==239 && file.data[1]==187 && file.data[2]==191)
					file.data.position = 3;
				onReady(file.data.readUTFBytes(file.data.bytesAvailable));
				delete filesReading[file];
			});
		}
		
		private var filesReading:Dictionary = new Dictionary;
		
		
		/**
		 * function onReady(data:ByteArray):void
		 */
		public function readBinFile(url:String, onReady:Function):void
		{
			if (url.indexOf('sdk://') == 0)
			{
				SDKCompiler.getSDKFile(url, onReady);
			}
			else
			{
				var file:File = new File(rootPath).resolvePath(url);
				filesReading[file] = true;
				file.load();
				file.addEventListener(Event.COMPLETE, function (e:Event):void {
					onReady(file.data);
					delete filesReading[file];
				});
			}
		}
		
		/**
		 * function onReady(success:Boolean):void
		 */
		public function saveFile(url:String, data:String, onReady:Function=null):void
		{
			var str:FileStream = new FileStream;
			var file:File = new File(rootPath).resolvePath(url);
			str.open(file, FileMode.WRITE);
			str.writeUTFBytes(data);
			str.close();
			if (onReady != null)
				onReady();
		}
		
		public function unlink(url:String, onReady:Function=null):void
		{
			var file:File = new File(rootPath).resolvePath(url);
			if (file.isDirectory)
				file.deleteDirectory(true);
			else
				file.deleteFile();
			if (onReady != null) onReady();
		}
		
		public function newDir(url:String, onReady:Function=null):void
		{
			new File(rootPath).resolvePath(url).createDirectory();
			if (onReady != null) onReady();
		}
		
	}
}
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

package ro.minibuilder.data
{
	import __AS3__.vec.Vector;
	
	public interface IProjectPlug
	{
		/**
		 * function onReady():void
		 */
		function open(url:String, onReady:Function):void;
		
		function get config():ProjectConfig;
		
		function get path():String;
		
		function get name():String;
		
		//TODO rename to getFileList()
		function listFiles():Vector.<String>;

		/**
		 * Check if this path is a directory
		 */
		function isDirectory(url:String):Boolean;
		
		/**
		 * function onReady(source:String):void
		 */
		function readTextFile(url:String, onReady:Function):void;		
		
		/**
		 * function onReady(source:ByteArray):void
		 */
		function readBinFile(url:String, onReady:Function):void;
		
		/**
		 * function onReady(success:Boolean):void
		 */
		function saveFile(url:String, data:String, onReady:Function=null):void;
		
		function newDir(url:String, onReady:Function=null):void;
		
		function unlink(url:String, onReady:Function=null):void;
	}
}
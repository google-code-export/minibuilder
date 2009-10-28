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

package ro.minibuilder.main.editor
{
	import flash.events.Event;

	public class TextEditor extends ScriptAreaComponent implements ITextEditor
	{
		private var _filePath:String;
		
		public function get filePath():String
		{
			return _filePath;
		}
		
		public function set filePath(path:String):void
		{
			_filePath = path;
		}
		
		public function loadSource(source:String, fileName:String):void
		{
			text = source.replace(/\r?\n/g, '\r');
			dispatchEvent(new Event('status'));
		}
		
		
		
		public function get status():String
		{
			return '';
		}
		
		
		public function get percentReady():Number
		{
			return 1;
		}		
	}
}
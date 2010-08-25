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
	import org.aswing.Icon;
	
	import ro.minibuilder.main.Skins;

	public class EditorMap
	{
		public static function getEditorClass(fileName:String):Class
		{
			if (!fileName) return null;
			
			var ext:String = fileName.substr(fileName.lastIndexOf('.')+1);
			
			var map:Object = {
				'as' : AS3Editor,
				'txt' : TextEditor,
				'mxml' : TextEditor,
				'xml' : TextEditor,
				'conf' : TextEditor,
				'ini' : TextEditor,
				'html' : TextEditor,
				'js' : TextEditor,
				'php' : TextEditor,
				'sh' : TextEditor,
				'tpl' : TextEditor,
				'png' : ImageEditor,
				'gif' : ImageEditor,
				'jpg' : ImageEditor
			}
			
			return map[ext];
		}
		
		public static function getIcon(fileName:String):Icon
		{
			var ext:String = fileName.substr(fileName.lastIndexOf('.')+1);
			if (!fileName) return null;
			var map:Object = {
				'as' : 'icnAS',
				'swf': 'icnSWC',
				'swc': 'icnSWC',
				'txt' : 'icnFile',
				'mxml' : 'icnMX'
			}
			if (Skins[map[ext]])
				return Skins[map[ext]]();
			else
				return null;
		}
	}
}
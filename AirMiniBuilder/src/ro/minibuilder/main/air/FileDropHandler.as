/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main.air
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import ro.minibuilder.main.ProjectWindow;
	import ro.minibuilder.main.editor.AS3Editor;

	public class FileDropHandler
	{
		private var pwin:ProjectWindow;
		
		public function FileDropHandler(pwin:ProjectWindow)
		{
			this.pwin = pwin;
			
			pwin.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragEnter);
			
			pwin.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDrop);
		}
		
		protected function onDragEnter(e:NativeDragEvent):void 
		{
			NativeDragManager.acceptDragDrop(pwin);
		}
		
		protected function onDrop(e:NativeDragEvent):void 
		{
			NativeDragManager.dropAction = NativeDragActions.COPY;
			var list:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			if (list && list.length == 1)
			{
				var file:File = list[0];
				
				var editor:AS3Editor = pwin.crtEditor as AS3Editor;
				if (!editor) return;
				var src:String = editor.text;
				var pos:int = src.indexOf('class');
				pos = src.indexOf('{', pos);
				pos = src.indexOf('\r', pos);
				pos += 1;
				
				var inc:String = '\t\t[Embed(source="' +
					file.nativePath.replace(/\\/g, '/') +
					'")]\r\t\tprivate var ' + nextName(src) + ':Class;\r\r\r'
				
				editor.replaceText(pos, pos, inc);
				editor.dispatchChange();
			}
		}
		
		protected function nextName(src:String):String
		{
			var pos:int = 0;
			var i:int = 0;
			var re:RegExp;
			do {
				i++;
				re = new RegExp('\\bAsset'+i+'\\b');
			} while (re.test(src));
			
			return 'Asset' + i;
		}
	}
}
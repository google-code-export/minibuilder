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
	
	import ro.minibuilder.asparser.Controller;
	import ro.minibuilder.main.editor.IEditor;
	import ro.minibuilder.main.editor.ITextEditor;
	

	public class AS3Editor extends ScriptAreaComponent implements IEditor, ITextEditor
	{
		private var ctrl:Controller;
		private var assistMenu:AssistMenu;
		private var fileName:String;
		
		public function AS3Editor()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function get filePath():String
		{
			return fileName;
		}
		
		public function set filePath(path:String):void
		{
			fileName = path;
		}
		
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			ctrl = new Controller(stage, this);
			
			ctrl.addEventListener('status', function(e:Event):void
			{
				dispatchEvent(new Event('status'));
			});
			
			assistMenu = new AssistMenu(this, ctrl, stage, onAssistComplete);
			
			addEventListener(Event.CHANGE, onChange);
		}
		
		public function get status():String
		{
			return ctrl.status;
		}
		
		public function get percentReady():Number
		{
			return ctrl.percentReady;
		}
		
		
		private function onAssistComplete():void
		{
			ctrl.sourceChanged(text, fileName);
		}
		
		private function onChange(e:Event):void
		{
			if (triggerAssist())
				assistMenu.triggerAssist();
			else
				ctrl.sourceChanged(text, fileName);
		}
		
		protected function triggerAssist():Boolean
		{
			var str:String = text.substring(Math.max(0, caretIndex-10), caretIndex);
			str = str.split('').reverse().join('');
			return (/^(?:\(|\:|\.|\s+sa\b|\swen\b|\ssdnetxe)/.test(str))
		}
		
		public function loadSource(source:String, filePath:String):void
		{
			text = source.replace(/(\n|\r\n)/g, '\r');
			fileName = filePath;
			ctrl.sourceChanged(text, fileName);
		}
		
		public function findDefinition():Location
		{
			return ctrl.findDefinition(caretIndex);
		}
	}
}
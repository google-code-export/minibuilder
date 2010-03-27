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
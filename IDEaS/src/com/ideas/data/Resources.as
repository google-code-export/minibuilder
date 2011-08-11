package com.ideas.data {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	public class Resources {
		[Embed(source = './assets/data.xml', mimeType = "application/octet-stream")]
		private static var Data:Class;
		private static var ba:ByteArray = (new Data()) as ByteArray;
		private static var s:String = ba.readUTFBytes(ba.length);
		public static var data:XML = new XML(s);
		//
		[Embed(source = './assets/ActionScript-icon.png')]
		public static var ActionScriptIcon:Class;
		//
		[Embed(source = './assets/Help-Icon.png')]
		public static var HelpIcon:Class;
		//
		[Embed(source = './assets/Swf-icon.png')]
		public static var SwfIcon:Class;
		//
		[Embed(source = './assets/format-icon.png')]
		public static var FormatIcon:Class;
		//
		[Embed(source = './assets/Save-icon.png')]
		public static var SaveIcon:Class;
		//
		[Embed(source = './assets/Note-icon.png')]
		public static var NoteIcon:Class;
		//
		[Embed(source = './assets/Folder-parent-icon.png')]
		public static var FolderParentIcon:Class;
		//
		[Embed(source = './assets/New-Folder-icon.png')]
		public static var NewFolderIcon:Class;
		//
		[Embed(source = './assets/Folder-icon.png')]
		public static var FolderIcon:Class;
		//
		[Embed(source = './assets/Document-Blank-icon.png')]
		public static var DocumentBlankIcon:Class;
		//
		[Embed(source = './assets/Format-indent-less.png')]
		public static var IndentLessIcon:Class;
		//
		[Embed(source = './assets/Format-indent-more.png')]
		public static var IndentMoreIcon:Class;
		//
		[Embed(source = './assets/maximize.png')]
		public static var MaximizeIcon:Class;
		//
		[Embed(source = './assets/minimize.png')]
		public static var MinimizeIcon:Class;
		//
		[Embed(source = './assets/auto-indent.png')]
		public static var AutoIndentIcon:Class;
		//
		[Embed(source = './assets/Search-icon.png')]
		public static var SearchIcon:Class;
		//
		[Embed(source = './assets/Information-icon.png')]
		public static var InfoIcon:Class;
		//
		[Embed(source = './assets/navigate-up-icon.png')]
		public static var NavigateIcon:Class;
		//
		[Embed(source = './assets/Undo-icon.png')]
		public static var UndoIcon:Class;
		//
		[Embed(source = './assets/Redo-icon.png')]
		public static var RedoIcon:Class;
		//
		[Embed(source = './assets/log-icon.png')]
		public static var DebugIcon:Class;
		//
		//Menu icons
		[Embed(source = './assets/iconAbout.png')]
		public static var MenuAbout:Class;
		//
		[Embed(source = './assets/iconFork.png')]
		public static var MenuWonderfl:Class;
		//
		[Embed(source = './assets/iconSave.png')]
		public static var MenuSave:Class;
		//
		[Embed(source = './assets/iconSettings.png')]
		public static var MenuSettings:Class;
		//
		[Embed(source = './assets/iconHelp.png')]
		public static var MenuHelp:Class;
		//
		[Embed(source = './assets/iconNew.png')]
		public static var MenuNew:Class;
		//
		[Embed(source = './assets/iconOpen.png')]
		public static var MenuOpen:Class;
		//
		[Embed(source = './assets/iconSaveAs.png')]
		public static var MenuSaveAs:Class;
		//
		[Embed(source = './assets/iconSearch.png')]
		public static var MenuSearch:Class;
		//
		[Embed(source = './assets/iconRecent.png')]
		public static var MenuRecent:Class;
		//
		
		public function Resources() {
		}
	}
}

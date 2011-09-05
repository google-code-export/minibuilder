package com.ideas.file {
	import com.ideas.data.DataHolder;
	import com.ideas.data.Resources;
	import com.ideas.gui.buttons.GeneralButton;
	import com.ideas.gui.buttons.IconButton;
	import com.ideas.gui.scroller.BasicScrollerUnit;
	import com.ideas.gui.scroller.ScrollerContainer;
	import com.ideas.gui.scroller.ScrollerEvent;
	import com.ideas.utils.HtmlTemplate;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class FileManager extends Sprite {
		private var topTitle:TextField= new TextField();
		private var currentFile:File = File.documentsDirectory;
		private var scrollerContainer:ScrollerContainer;
		private var fileNameField:TextField = new TextField();
		private var saveButton:GeneralButton = new GeneralButton(90, 50, "Save");
		private var cancelButton:GeneralButton = new GeneralButton(90, 50, "Cancel")
		private var topOffset:int = 30;
		private var bottomOffset:int = 60;
		private var stageHeight:int = 0;
		private var _type:String;
		public static const MAIN_FILE_NAME:String = "Main";
		public static const OPEN_FILE:String = "OPEN_FILE";
		public static const SAVE_FILE:String = "SAVE_FILE";
		public static const CREATE_FOLDER:String = "CREATE_FOLDER";
		public static const SHOW_OVERWRITE:String = "SHOW_OVERWRITE";
		public static const CANCEL:String = "CANCEL";
		private var _fileName:String;
		private var _codeString:String;
		private var openedFile:File;
		private var _currentlyEditedFile:File;
		private var _killKeyboardManually:Boolean;
		private var parentFolder:IconButton;
		private var newFolder:IconButton;
		public function FileManager() {
			parentFolder = new IconButton(new Resources.FolderParentIcon(), 50, 50);
			newFolder = new IconButton(new Resources.NewFolderIcon(), 50, 50);
			
			topTitle.defaultTextFormat = new TextFormat("_sans", 24, 0xcccccc)
			addChild(topTitle);
			
			topTitle.y = 0;
			topTitle.height = topOffset;
			topTitle.selectable = false;
			topTitle.mouseEnabled = false;
			addChild(saveButton);
			addChild(cancelButton);
			addChild(fileNameField);
			addChild(parentFolder);
			addChild(newFolder)
			fileNameField.type = TextFieldType.INPUT;
			fileNameField.defaultTextFormat = new TextFormat("_sans", 30, 0)
			fileNameField.border = true;
			fileNameField.background = true;
			fileNameField.height = 50;
			fileNameField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyActive);
			fileNameField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyDeactive);
			fileNameField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			fileNameField.addEventListener(Event.CHANGE, onFileNameChanged);
			parentFolder.addEventListener(MouseEvent.CLICK, onParentFolderClick);
			newFolder.addEventListener(MouseEvent.CLICK, onNewFolderClick);
			fileNameField.x = 5;
			this.fileName = MAIN_FILE_NAME;
			scrollerContainer = new ScrollerContainer();
			scrollerContainer.addEventListener(ScrollerEvent.UNIT_SELECTED, onScrollerUnitSelected);
			scrollerContainer.y = topOffset;
			addChild(scrollerContainer);
			saveButton.addEventListener(MouseEvent.CLICK, onSaveClick);
			cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//
			for (var i:int = 0; i < 20; i++) {
				var unit:BasicScrollerUnit = new BasicScrollerUnit();
				unit.setGraphicUnit(new FileScrollerGraphic());
				scrollerContainer.addUnit(unit);
			}
			//
		}
		private function onNewFolderClick(e:Event):void {
			forceKeyboardClose();
			this.dispatchEvent(new Event(CREATE_FOLDER));
		}
		private function onParentFolderClick(e:Event):void {
			if (currentFile.parent) {
				currentFile = currentFile.parent;
				update();
			}
		}
		private function onSoftKeyActive(e:SoftKeyboardEvent):void {
			onResizeStage(null);
		}
		private function onSoftKeyDeactive(e:SoftKeyboardEvent):void {
			onResizeStage(null);
		}
		private function forceKeyboardClose():void {
			_killKeyboardManually = true;
			this.stage.focus = null;
		}
		private function onFocusOut(e:Event):void {
			if (_killKeyboardManually) {
				_killKeyboardManually = false;
				return;
			}
			this.stage.focus = fileNameField;
		}
		public function saveCurrentlyEditedFile():Boolean {
			currentFile = currentlyEditedFile;
			fileName = getCurrentFileName();
			var writed:Boolean = saveFile(this.codeString, this._fileName);
			if (writed) {
				this.dispatchEvent(new Event(SAVE_FILE));
			}
			return writed;
		}
		private function onRemove(e:Event):void {
			this.forceKeyboardClose();
			this.scrollerContainer.clearContainer();
			removeChild(scrollerContainer);
		}
		private function onFileNameChanged(e:Event):void {
			this.fileName = fileNameField.text;
		}
		public function setType(value:String):void {
			_type = value;
			newFolder.visible = fileNameField.visible = saveButton.visible = Boolean(_type == "save");
		}
		private function onSaveClick(e:Event):void {
			if (this.codeString.length > 0 && this._fileName.length > 0) {
				if (saveFile(this.codeString, this._fileName, true)) {
					forceKeyboardClose();
					this.dispatchEvent(new Event(SAVE_FILE));
				}
			}
		}
		private function onCancelClick(e:Event):void {
			forceKeyboardClose();
			this.dispatchEvent(new Event(CANCEL));
		}
		private function onAdd(e:Event):void {
			e.stopImmediatePropagation();
			addChild(scrollerContainer);
			openedFile = null;
			update();
			this.stage.addEventListener(Event.RESIZE, onResizeStage);
			//this.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			onResizeStage(null);
		}
		private function update():void {
			if (!currentFile.isDirectory && currentFile.extension == "as") {
				openedFile = currentFile;
				currentFile = currentFile.parent;
			}
			//TODO: Create update when opening filemanager
			topTitle.text = currentFile.nativePath;
			createList();
			redrawContainerMask();
		}
		private function createList():void {
			var len:int = currentFile.getDirectoryListing().length;
			scrollerContainer.clearContainer();
			var unit:BasicScrollerUnit;
			var file:File;
			var listData:Array = [];
			for (var i:int = 0; i < len; i++) {
				file = currentFile.getDirectoryListing()[i];
				listData.push({ title: file.name, file: file, extension: file.extension, isDirectory: file.isDirectory })
			}
			listData.sortOn([ "isDirectory", "title" ], [ Array.DESCENDING, null ]);
			parentFolder.visible = false;
			if (currentFile.parent) {
				parentFolder.visible = true;
				file = currentFile.parent;
				listData.unshift({ title: "../", is_parent: true, file: file, isDirectory: file.isDirectory });
			}
			scrollerContainer.setListData(listData);
		}
		private function onScrollerUnitSelected(e:Event):void {
			var data:Object = scrollerContainer.selectedItem.data;
			if (data.isDirectory) {
				trace("up");
				currentFile = data.file;
				update();
			} else {
				if (data.extension == "as" || data.extension == "txt") {
					currentFile = data.file;
					//e.stopImmediatePropagation();
					if (_type == "open") {
						forceKeyboardClose();
						this.dispatchEvent(new Event(OPEN_FILE));
					} else if (_type == "save") {
						this.fileName = getCurrentFileName();
					}
				}
			}
		}
		public function onResizeStage(e:Event):void {
			if (!this.stage) {
				return;
			}
			this.stageHeight = this.stage.stageHeight - this.topOffset - this.bottomOffset - this.stage.softKeyboardRect.height;
			cancelButton.x = this.stage.stageWidth - this.cancelButton.width - 5;
			newFolder.y = parentFolder.y = fileNameField.y = cancelButton.y = saveButton.y = this.stage.stageHeight - cancelButton.height - 5 - this.stage.softKeyboardRect.height;
			saveButton.x = this.stage.stageWidth - this.cancelButton.width - 5 - saveButton.width - 5;
			parentFolder.x = 5;
			this.scrollerContainer.onResize(this.stage.stageWidth, this.stageHeight);
			topTitle.width = this.stage.stageWidth;
			redrawContainerMask();
		}
		private function redrawContainerMask():void {
			newFolder.x = (parentFolder.width + 5) * int(parentFolder.visible) + 5;
			fileNameField.width = saveButton.x - 10 - (parentFolder.width + 5) * int(parentFolder.visible) - (newFolder.width + 5) * int(newFolder.visible);
			fileNameField.x = (parentFolder.width + 5) * int(parentFolder.visible) + (newFolder.width + 5) * int(newFolder.visible) + 5;
			this.graphics.clear();
			this.graphics.beginFill(0);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			this.graphics.endFill();
		}
		private function getCurrentFileName():String {
			return currentFile.name.split(".")[0];
		}
		public function getCurrentData():String {
			var stream:FileStream = new FileStream;
			try {
				stream.open(currentFile, FileMode.READ);
				var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
				this.fileName = getCurrentFileName();
				_currentlyEditedFile = currentFile;
				return fileData;
			} catch (e:*) {
			}
			return null;
		}
		public function overwriteFile():void {
			if (this.codeString.length > 0 && this._fileName.length > 0) {
				if (saveFile(this._codeString, _fileName)) {
					forceKeyboardClose();
					this.dispatchEvent(new Event(SAVE_FILE));
				}
			}
		}
		private function saveFile(code:String, fileName:String, checkExisting:Boolean = false):Boolean {
			var file:File = currentFile.isDirectory ? currentFile : currentFile.parent;
			file = file.resolvePath(fileName + ".as");
			if (checkExisting) {
				if (file.exists) {
					this.forceKeyboardClose();
					this.dispatchEvent(new Event(SHOW_OVERWRITE));
					return false;
				}
			}
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener(IOErrorEvent.IO_ERROR, onError);
			try {
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeMultiByte(code, "utf-8");
				fileStream.close();
				_currentlyEditedFile = file;
				return true;
			} catch (e:*) {
				trace(e);
			}
			return false;
		}
		public function onError(e:Event):void {
			trace("error");
		}
		public function get fileName():String {
			return _fileName;
		}
		public function set fileName(value:String):void {
			_fileName = value;
			this.fileNameField.text = _fileName;
		}
		public function get codeString():String {
			return _codeString;
		}
		public function set codeString(value:String):void {
			_codeString = value;
		}
		//Option for saving compiled swf files locally
		public function writeSwfOnDisk():Boolean {
			if (!DataHolder.swfData) {
				return false;
			}
			try{
				var swf:File = currentFile.isDirectory ? currentFile : currentFile.parent;
				swf = swf.resolvePath(fileName + ".swf");
				var fs:FileStream = new FileStream();
				fs.open(swf, FileMode.WRITE);
				fs.writeBytes(DataHolder.swfData);
				fs.close();
				//
				var str:String=HtmlTemplate.CODE.split("{scale}").join(DataHolder.htmlStage).split("{name}").join(fileName).split("{width}").join(DataHolder.htmlWidth + DataHolder.htmlSizeType).split("{height}").join(DataHolder.htmlHeight + DataHolder.htmlSizeType);
				var html:File = currentFile.isDirectory ? currentFile : currentFile.parent;
				html = html.resolvePath(fileName + ".html");
				fs= new FileStream();
				fs.open(html, FileMode.WRITE);
				fs.writeMultiByte(str, "utf-8");
				fs.close();
				
			}catch(e:*){
				return false;
			}
			return true;
		}
		public function get currentlyEditedFile():File {
			return _currentlyEditedFile;
		}
		public function set currentlyEditedFile(value:File):void {
			_currentlyEditedFile = value;
		}
		public function createNewDirectory(value:String):Boolean {
			var directory:File = currentFile.isDirectory ? currentFile : currentFile.parent;
			directory = directory.resolvePath(value);
			if (!directory.exists) {
				try {
					directory.createDirectory();
				} catch (e:*) {
					return false;
				}
			}
			if (directory.exists) {
				currentFile = directory;
				this.update();
			}
			return true;
		}
		public function getFolderName():String {
			var swf:File = currentFile.isDirectory ? currentFile : currentFile.parent;
			return swf.nativePath;
		}
	}
}

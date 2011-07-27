package com.ideas.gui {
	import com.ideas.data.DataHolder;
	import com.ideas.file.FileScrollerGraphic;
	import com.ideas.gui.buttons.LineSeparator;
	import com.ideas.gui.scroller.BasicScrollerUnit;
	import com.ideas.gui.scroller.ScrollerContainer;
	import com.ideas.gui.scroller.ScrollerEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class RecentFilesScreen extends Sprite {
		private static const WIDTH:int = 440;
		private static const HEIGHT:int = 440;
		private static const TOP:int = 40;
		public static const OPEN_FILE:String = "OPEN_FILE";
		public static const UPDATE_LIST:String = "UPDATE_LIST";
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var scrollerContainer:ScrollerContainer;
		private var lineCateg:LineSeparator = new LineSeparator();
		private var _currentFile:File;
		private var _fileName:String;
		private var labelBg:TextField = new TextField();
		public function RecentFilesScreen() {
			scrollerContainer = new ScrollerContainer();
			scrollerContainer.addEventListener(ScrollerEvent.UNIT_SELECTED, onScrollerUnitSelected);
			addChild(labelBg);
			addChild(scrollerContainer);
			this.addChild(lineCateg);
			labelBg.width = WIDTH;
			labelBg.selectable = false;
			this.labelBg.defaultTextFormat = new TextFormat("_sans", 30, 0xffffff, false, null, null, null, null, "center");
			labelBg.text = "Recent Files";
			for (var i:int = 0; i < 20; i++) {
				var unit:BasicScrollerUnit = new BasicScrollerUnit();
				unit.setGraphicUnit(new FileScrollerGraphic());
				scrollerContainer.addUnit(unit);
			}
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		public function get currentFile():File {
			return _currentFile;
		}
		public function get fileName():String {
			return _fileName;
		}
		private function onScrollerUnitSelected(e:Event):void {
			var data:Object = scrollerContainer.selectedItem.data;
			if (data.extension == "as" || data.extension == "txt") {
				_currentFile = data.file;
				this.dispatchEvent(new Event(OPEN_FILE));
			}
		}
		public function getCurrentData():String {
			var stream:FileStream = new FileStream;
			try {
				stream.open(_currentFile, FileMode.READ);
				var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
				_fileName = getCurrentFileName();
				return fileData;
			} catch (e:*) {
			}
			return null;
		}
		private function getCurrentFileName():String {
			return _currentFile.name.split(".")[0];
		}
		private function onAdd(e:Event):void {
			addChild(scrollerContainer);
			var file:File;
			var listData:Array = [];
			scrollerContainer.clearContainer();
			var i:int = 0;
			while (i < DataHolder.recentFiles.length) {
				file = File.documentsDirectory.resolvePath(DataHolder.recentFiles[i]);
				if (file && file.exists) {
					listData.push({ title: file.name, file: file, extension: file.extension, isDirectory: file.isDirectory })
					i++;
				} else {
					DataHolder.recentFiles.splice(i, 1);
					this.dispatchEvent(new Event(UPDATE_LIST));
				}
			}
			scrollerContainer.setListData(listData);
		}
		private function onRemoved(e:Event):void {
			this.scrollerContainer.clearContainer();
			removeChild(scrollerContainer);
		}
		public function resize(wid:int, hgt:int):void {
			_wid = wid;
			_hgt = hgt;
			redraw();
			this.scrollerContainer.onResize(WIDTH - 20, HEIGHT - TOP - 20);
			scrollerContainer.y = (_hgt - HEIGHT) / 2 + TOP + 10;
			scrollerContainer.x = (_wid - WIDTH) / 2 + 10;
			lineCateg.x = (_wid - WIDTH) / 2 + 10;
			lineCateg.draw(WIDTH - 10 - 10, 0, 0x808080);
			lineCateg.y = TOP + (_hgt - HEIGHT) / 2;
			labelBg.x = (_wid - WIDTH) / 2;
			labelBg.y = (_hgt - HEIGHT) / 2
		}
		private function redraw():void {
			DataHolder.drawBg(this, _wid, _hgt, WIDTH, HEIGHT);
			//
		}
	}
}

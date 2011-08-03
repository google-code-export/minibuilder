package com.ideas.gui {
	import by.blooddy.crypto.serialization.JSON;
	import com.ideas.data.Resources;
	import com.ideas.gui.buttons.GeneralButton;
	import com.ideas.gui.scroller.BasicScrollerUnit;
	import com.ideas.gui.scroller.ScrollerContainer;
	import com.ideas.gui.scroller.ScrollerEvent;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	public class WonderflScreen extends Sprite {
		public static const WONDERFL_KEY:String = Resources.data.wonderfl_key;
		public static const USER_URL:String = "http://api.wonderfl.net/user/<username>/codes?api_key=<api_key>";
		public static const CODE_URL:String = "http://api.wonderfl.net/code/<codeid>?api_key=<api_key>";
		private var userLoader:URLLoader = new URLLoader();
		private var codeLoader:URLLoader = new URLLoader();
		private var scrollerContainer:ScrollerContainer;
		private var _codeId:String = "";
		private var _codeString:String = "";
		private var _codeTitle:String = "";
		private var codes:Array = null;
		private var bottomOffset:int = 60;
		private var userNameField:TextField = new TextField();
		private var _killKeyboardManually:Boolean;
		private var _userName:String = "";
		private var saveButton:GeneralButton = new GeneralButton(140, 50, "Get Code");
		private var warningText:TextField = new TextField();
		private var format:TextFormat = new TextFormat("_sans", 18, 0xcccccc);
		public static const INFO:String = "Insert User Name";
		public static const WARNING:String = "No Data";
		public static const ERROR:String = "Load Error";
		private var preloader:Preloader = new Preloader();
		public function WonderflScreen() {
			scrollerContainer = new ScrollerContainer();
			scrollerContainer.addEventListener(ScrollerEvent.UNIT_SELECTED, onScrollerUnitSelected);
			userLoader.addEventListener(Event.COMPLETE, onLoadUserComplete);
			codeLoader.addEventListener(Event.COMPLETE, onLoadCodeComplete);
			userLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			codeLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//
			userNameField.type = TextFieldType.INPUT;
			userNameField.defaultTextFormat = new TextFormat("_sans", 36, 0)
			userNameField.border = true;
			userNameField.background = true;
			userNameField.height = 50;
			userNameField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyActive);
			userNameField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyDeactive);
			userNameField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			userNameField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			userNameField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			userNameField.addEventListener(KeyboardEvent.KEY_DOWN, function(e:*):void {
				warningText.visible = false;
			});
			userNameField.x = 5;
			addChild(userNameField);
			//
			addChild(saveButton);
			saveButton.addEventListener(MouseEvent.CLICK, onSaveClick);
			//
			warningText.defaultTextFormat = format;
			warningText.width = 180;
			warningText.height = 30;
			warningText.x = 5;
			warningText.text = INFO;
			warningText.selectable = false;
			warningText.mouseEnabled = false;
			addChild(warningText);
			//
			var unit:BasicScrollerUnit;
			for (var i:int = 0; i < 20; i++) {
				unit = new BasicScrollerUnit();
				unit.setGraphicUnit(new WonderScrollerGraphic());
				//unit.setWidth(this.stage.stageWidth);
				scrollerContainer.addUnit(unit);
			}
		}
		public function get codeTitle():String {
			return _codeTitle;
		}
		public function get codeString():String {
			return _codeString;
		}
		private function onAdd(e:Event):void {
			e.stopImmediatePropagation();
			addChild(scrollerContainer);
			this.stage.addEventListener(Event.RESIZE, onResizeStage);
			onResizeStage(null);
			//this.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
		}
		private function load():void {
			if (userNameField.text.length > 0) {
				_userName = userNameField.text;
				userLoader.load(new URLRequest(USER_URL.split("<username>").join(_userName).split("<api_key>").join(WONDERFL_KEY)));
				this.addChild(preloader);
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
			this.stage.focus = userNameField;
		}
		private function onFocusIn(e:Event):void {
			warningText.visible = false;
		}
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER) {
				load();
			}
		}
		private function onSaveClick(e:Event):void {
			load();
		}
		private function onLoadUserComplete(e:Event):void {
			if (preloader.parent) {
				this.removeChild(preloader);
			}
			var obj:Object = JSON.decode(e.target.data);
			if (obj.stat == "fail" || !obj.codes || obj.codes.length == 0) {
				scrollerContainer.clearContainer();
				format.color = 0xff0000;
				forceKeyboardClose();
				warningText.defaultTextFormat = format;
				warningText.text = WARNING;
				warningText.visible = true;
				userNameField.text = "";
				return;
			}
			codes = obj.codes;
			createUserList();
			onResizeStage(null);
		}
		private function createUserList():void {
			var len:int = codes.length;
			scrollerContainer.clearContainer();
			var arr:Array = [];
			for (var i:int = 0; i < len; i++) {
				arr.push({ title: codes[i].title, thumbnail: codes[i].thumbnail, id: codes[i].id, date: codes[i].created_date });
			}
			scrollerContainer.setListData(arr);
		}
		private function onLoadError(e:Event):void {
			if (preloader.parent) {
				this.removeChild(preloader);
			}
			format.color = 0xff0000;
			forceKeyboardClose();
			warningText.defaultTextFormat = format;
			warningText.text = ERROR;
			warningText.visible = true;
			userNameField.text = "";
		}
		private function onLoadCodeComplete(e:Event):void {
			if (preloader.parent) {
				this.removeChild(preloader);
			}
			forceKeyboardClose();
			var obj:Object = JSON.decode(e.target.data);
			_codeString = obj.code.as3;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		private function onScrollerUnitSelected(e:Event):void {
			_codeId = scrollerContainer.selectedItem.data.id;
			_codeTitle = scrollerContainer.selectedItem.data.title;
			this.addChild(preloader);
			codeLoader.load(new URLRequest(CODE_URL.split("<codeid>").join(_codeId).split("<api_key>").join(WONDERFL_KEY)));
		}
		private function onRemove(e:Event):void {
			this.forceKeyboardClose();
			this.scrollerContainer.clearContainer();
			removeChild(scrollerContainer);
		}
		public function onResizeStage(e:Event):void {
			if (!this.stage) {
				return;
			}
			this.scrollerContainer.onResize(this.stage.stageWidth, this.stage.stageHeight - bottomOffset - this.stage.softKeyboardRect.height);
			userNameField.y = saveButton.y = this.stage.stageHeight - saveButton.height - 5 - this.stage.softKeyboardRect.height;
			warningText.y = userNameField.y + 10;
			saveButton.x = this.stage.stageWidth - 5 - saveButton.width - 5;
			userNameField.width = saveButton.x - 10;
			preloader.resize(this.stage.stageWidth - 140 - 10, this.stage.stageHeight - this.stage.softKeyboardRect.height);
			redrawContainerBg();
		}
		private function redrawContainerBg():void {
			this.graphics.clear();
			this.graphics.beginFill(0);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			this.graphics.endFill();
		}
	}
}

package com.ideas.gui {
	import com.ideas.data.DataHolder;
	import com.ideas.gui.buttons.GeneralButton;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	public class CreateFolderScreen extends Sprite {
		private static const WIDTH:int=250;
		private static const HEIGHT:int=230;
		public static const SAVE_CLICKED:String="save_clicked";
		public static const CANCEL_CLICKED:String="cancel_clicked";
		private var _wid:int=0;
		private var _hgt:int=0;
		private var saveButton:GeneralButton=new GeneralButton(WIDTH-20, 50, "Create");
		private var cancelButton:GeneralButton=new GeneralButton(WIDTH-20, 50, "Cancel");
		private var folderNameField:TextField=new TextField();
		private var label:TextField=new TextField();
		private var shp:Shape=new Shape();
		private var _killKeyboardManually:Boolean;
		public function CreateFolderScreen() {
			this.addChild(shp);
			this.addChild(saveButton);
			this.addChild(cancelButton);
			addChild(label);
			this.addChild(folderNameField);
			folderNameField.width=WIDTH-20;
			folderNameField.height=34;
			folderNameField.defaultTextFormat=new TextFormat("_sans", 30, 0x0, true, null, null, null, null, "center");
			folderNameField.text="New Folder";
			label.width=WIDTH-20;
			label.multiline=true;
			label.wordWrap=true;
			label.selectable=false;
			
			
			this.label.defaultTextFormat=new TextFormat("_sans", 24,0xffffff, true, null, null, null, null, "center");
			label.text="Create new folder:"
			folderNameField.type=TextFieldType.INPUT;
			folderNameField.addEventListener(KeyboardEvent.KEY_DOWN,onChange);
			folderNameField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyActive);
			folderNameField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyDeactive);
			this.saveButton.addEventListener(MouseEvent.CLICK, onSaveClick);
			this.cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		private function onAdd(e:Event):void {
			onResizeStage(null);
		}
		private function onRemove(e:Event):void {
			forceKeyboardClose();
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
			this.stage.focus = folderNameField;
		}
		public function onResizeStage(e:Event):void {
			if (!this.stage) {
				return;
			}
			_wid=this.stage.stageWidth;
			_hgt=this.stage.stageHeight-this.stage.softKeyboardRect.height
			redraw();
		}
		
		private function onChange(e:KeyboardEvent):void {
			if(e.keyCode==Keyboard.ENTER){
				this.stage.focus=null;
			}
		}
		private function onSaveClick(e:MouseEvent):void {
			if(folderNameField.text.length>0){
				this.dispatchEvent(new Event(SAVE_CLICKED));
			}
			
		}
		private function onCancelClick(e:MouseEvent):void {
			this.dispatchEvent(new Event(CANCEL_CLICKED));
		}
		public function getFolderName():String{
			return folderNameField.text;
		}
		private function redraw():void {
			DataHolder.drawBg(this,_wid,_hgt,WIDTH,HEIGHT);
			//
			shp.graphics.clear();
			shp.graphics.lineStyle(1, 0);
			shp.graphics.beginFill(0xeeeeee);
			shp.graphics.drawRect((_wid - WIDTH) / 2 + 10, (_hgt ) / 2 -50-30+ 10, WIDTH-20, 50);
			shp.graphics.endFill();
			
			//
			folderNameField.x=(_wid - WIDTH) / 2 + 10;
			//
			label.x=saveButton.x=cancelButton.x=(_wid - saveButton.width) / 2;
			label.y=(_hgt -HEIGHT) / 2 +5;
			saveButton.y=_hgt / 2 + HEIGHT / 2 - saveButton.height - 10;
			cancelButton.y=_hgt / 2 + HEIGHT / 2 - saveButton.height * 2 - 10 - 10;
			folderNameField.y=cancelButton.y-60;
		}
	}
}
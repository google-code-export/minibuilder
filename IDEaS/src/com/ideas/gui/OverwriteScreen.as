package com.ideas.gui {
	import com.ideas.data.DataHolder;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import com.ideas.gui.buttons.GeneralButton;

	public class OverwriteScreen extends Sprite {
		private static const WIDTH:int=200;
		private static const HEIGHT:int=50 * 3 + 10 * 4;
		public static const CANCEL_CLICKED:String="cancel_clicked";
		public static const CONFIRM_CLICKED:String="confirm_clicked";
		private var _wid:int=0;
		private var _hgt:int=0;
		private var saveAndExitButton:GeneralButton=new GeneralButton(180, 50, "Overwrite");
		private var cancelButton:GeneralButton=new GeneralButton(180, 50, "Cancel");
		private var label:TextField=new TextField();
		public function OverwriteScreen() {
			label.width=180;
			label.multiline=true;
			label.wordWrap=true;
			label.selectable=false;
			addChild(label);
			this.label.defaultTextFormat=new TextFormat("_sans", 18, 0xffffff, true, null, null, null, null, "center", null, null, null, -2);
			this.addChild(saveAndExitButton);
			this.addChild(cancelButton);
			this.cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			this.saveAndExitButton.addEventListener(MouseEvent.CLICK, onSaveAndExitClick);
		}
		public function setLabel(value:String):void {
			label.text="File " + value + " exists. Replace it?";
		}
		public function resize(wid:int, hgt:int):void {
			_wid=wid;
			_hgt=hgt;
			redraw()
		}
		private function onCancelClick(e:MouseEvent):void {
			this.dispatchEvent(new Event(CANCEL_CLICKED));
		}
		private function onSaveAndExitClick(e:MouseEvent):void {
			this.dispatchEvent(new Event(CONFIRM_CLICKED));
		}
		private function redraw():void {
			
			//
			label.x=saveAndExitButton.x=cancelButton.x=(_wid - cancelButton.width) / 2;
			label.y=(_hgt - cancelButton.height) / 2 - saveAndExitButton.height - 10 - 3;
			saveAndExitButton.y=(_hgt - cancelButton.height) / 2;
			cancelButton.y=(_hgt - cancelButton.height) / 2 + cancelButton.height + 10;
			//
			DataHolder.drawBg(this,_wid,_hgt,WIDTH,HEIGHT);
			//
		}
	}
}
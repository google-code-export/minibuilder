package com.ideas.gui {
	import com.ideas.data.DataHolder;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.ideas.gui.buttons.GeneralButton;

	public class ExitConfirm extends Sprite {
		private static const WIDTH:int=200;
		private static const HEIGHT:int=50*3+10*4;
		public static const EXIT_CLICKED:String="exit_clicked";
		public static const CANCEL_CLICKED:String="cancel_clicked";
		public static const SAVE_EXIT_CLICKED:String="save_exit_clicked";
		private var _wid:int=0;
		private var _hgt:int=0;
		private var exitButton:GeneralButton=new GeneralButton(180, 50, "Exit");
		private var saveAndExitButton:GeneralButton=new GeneralButton(180, 50, "Save and Exit");
		private var cancelButton:GeneralButton=new GeneralButton(180, 50, "Cancel");
		
		public function ExitConfirm() {
			this.addChild(exitButton);
			this.addChild(saveAndExitButton);
			this.addChild(cancelButton);
			this.exitButton.addEventListener(MouseEvent.CLICK,onExitClick);
			this.cancelButton.addEventListener(MouseEvent.CLICK,onCancelClick);
			this.saveAndExitButton.addEventListener(MouseEvent.CLICK,onSaveAndExitClick);
		}
		public function resize(wid:int,hgt:int):void {
			_wid=wid;
			_hgt=hgt;
			redraw()
		}
		private function onExitClick(e:MouseEvent):void{
			this.dispatchEvent(new Event(EXIT_CLICKED));
		}
		private function onCancelClick(e:MouseEvent):void{
			this.dispatchEvent(new Event(CANCEL_CLICKED));
		}
		private function onSaveAndExitClick(e:MouseEvent):void{
			this.dispatchEvent(new Event(SAVE_EXIT_CLICKED));
		}
		private function redraw():void{
			
			//
			exitButton.x=saveAndExitButton.x=cancelButton.x=(_wid-exitButton.width)/2;
			exitButton.y=(_hgt-exitButton.height)/2;
			saveAndExitButton.y=(_hgt-exitButton.height)/2-saveAndExitButton.height-10;
			cancelButton.y=(_hgt-exitButton.height)/2+cancelButton.height+10;
			DataHolder.drawBg(this,_wid,_hgt,WIDTH,HEIGHT);
			
		}
	}
}
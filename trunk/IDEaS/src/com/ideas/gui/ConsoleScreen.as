package com.ideas.gui {
	import com.ideas.data.DataHolder;
	import com.ideas.gui.buttons.GeneralButton;
	import com.ideas.text.DebugPanel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class ConsoleScreen extends Sprite {
		public static const CANCEL_CLICKED:String = "cancel_clicked";
		public static const CLEAR_CLICKED:String = "clear_clicked";
		private static const WIDTH:int = 430;
		private static const HEIGHT:int = 420;
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var labelBg:TextField = new TextField();
		private var debugTextField:DebugPanel = new DebugPanel();
		private var cancelButton:GeneralButton = new GeneralButton(100, 50, "Cancel");
		private var clearButton:GeneralButton = new GeneralButton(160, 50, "Clear Markup");
		public function ConsoleScreen() {
			addChild(labelBg);
			addChild(cancelButton);
			addChild(clearButton);
			addChild(debugTextField);
			labelBg.width = WIDTH;
			labelBg.selectable = false;
			this.labelBg.defaultTextFormat = new TextFormat("_sans", 30, 0xffffff, false, null, null, null, null, "center");
			labelBg.text = "Console";
			cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			clearButton.addEventListener(MouseEvent.CLICK, onClearClick);
		}
		public function setDebugger(log:String):void {
			debugTextField.text = log;
		}
		public function resize(wid:int, hgt:int):void {
			_wid = wid;
			_hgt = hgt;
			redraw();
			labelBg.x = (_wid - WIDTH) / 2;
			labelBg.y = (_hgt - HEIGHT) / 2;
			debugTextField.x = (_wid - WIDTH) / 2 + 10;
			debugTextField.y = (_hgt - HEIGHT) / 2 + 40;
			debugTextField.width = WIDTH - 20;
			debugTextField.height = HEIGHT - 50 - 60;
			cancelButton.x = (_wid - WIDTH) / 2 + WIDTH - 100 - 10;
			clearButton.y=cancelButton.y = (_hgt - HEIGHT) / 2 + HEIGHT - 50 - 10;
			clearButton.x=cancelButton.x-clearButton.width-10;
			
		}
		private function onCancelClick(e:Event):void {
			this.dispatchEvent(new Event(CANCEL_CLICKED));
		}
		private function onClearClick(e:Event):void {
			this.dispatchEvent(new Event(CLEAR_CLICKED));
		}
		private function redraw():void {
			DataHolder.drawBg(this, _wid, _hgt, WIDTH, HEIGHT);
			//
		}
	}
}

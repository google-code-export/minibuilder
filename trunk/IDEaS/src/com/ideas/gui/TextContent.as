package com.ideas.gui {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class TextContent extends Sprite {
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var fontSize:TextField=new TextField();
		public function TextContent(wid:int = 70, hgt:int = 50) {
			_wid = wid;
			_hgt = hgt;
			fontSize.width=_wid;
			fontSize.height=34;
			fontSize.defaultTextFormat=new TextFormat("_sans", 30, 0, true, null, null, null, null, "center");
			fontSize.selectable=false;
			fontSize.text="0";
			fontSize.y=(_hgt-fontSize.textHeight)/2-2;
			
			addChild(fontSize);
			redraw();
		}
		public function get text():String {
			return fontSize.text;
		}
		public function set text(value:String):void {
			fontSize.text=value;
		}
		private function redraw():void {
			this.graphics.clear();
			this.graphics.lineStyle(0, 0, 1, true);
			this.graphics.beginFill(0xcccccc);
			this.graphics.drawRoundRect(0, 0, _wid, _hgt, 10, 10);
			this.graphics.endFill();
		}
	}
}

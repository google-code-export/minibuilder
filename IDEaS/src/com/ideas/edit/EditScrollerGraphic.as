package com.ideas.edit {
	import com.ideas.gui.scroller.ScrollerGraphic;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class EditScrollerGraphic extends ScrollerGraphic {
		public static const WIDTH:int = 60;
		private var txt:TextField = new TextField();
		private var format:TextFormat = new TextFormat("_sans", 24, 0xffffff, false);
		public function EditScrollerGraphic() {
			addChild(txt);
			txt.height = 30;
			txt.y = 25 - 10;
			txt.width = WIDTH;
			txt.selectable = false;
			txt.defaultTextFormat = format;
			txt.alpha = 0.8;
		}
		override public function setData(value:Object):void {
			txt.text = value.toString();
		}
		override public function redraw(state:Boolean):void {
			this.graphics.clear();
			//this.graphics.lineStyle(0, 0xcccccc);
			this.graphics.beginFill(state ? 0x8c4600 : 0xff8000);
			this.graphics.drawRect(0, 0, WIDTH, _height);
			this.graphics.endFill();
			//this.cacheAsBitmap = true;
		}
	}
}

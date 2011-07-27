package com.ideas.menu {
	import com.ideas.gui.buttons.MotionText;
	import com.ideas.gui.scroller.ScrollerGraphic;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	public class MenuScrollerGraphic extends ScrollerGraphic {
		public static const HEIGHT:int = 60;
		private var txt:MotionText = new MotionText();
		private var format:TextFormat = new TextFormat("_sans", 24, 0xffffff, false);
		public function MenuScrollerGraphic() {
			addChild(txt);
			txt.height = 30;
			txt.y = 25 - 10;
			txt.selectable = false;
			txt.defaultTextFormat = format;
			txt.alpha = 0.8;
		}
		override public function setData(value:Object):void {
			txt.text = value.toString();
		}
		override public function redraw(state:Boolean):void {
			if (state) {
				txt.play();
			} else {
				txt.stop();
			}
			txt.width = _width;
			this.graphics.clear();
			//this.graphics.lineStyle(0, 0xcccccc);
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(HEIGHT, HEIGHT, Math.PI / 2, 0, 0);
			this.graphics.beginGradientFill("linear", state ? [ 0x8c4600, 0xff8000 ] : [ 0x333333, 0x0 ], [ 0.5, 0.5 ], [ 0, 0xff ], mtrx);
			this.graphics.drawRect(0, 0, _width, HEIGHT);
			this.graphics.endFill();
			//this.cacheAsBitmap = true;
		}
	}
}

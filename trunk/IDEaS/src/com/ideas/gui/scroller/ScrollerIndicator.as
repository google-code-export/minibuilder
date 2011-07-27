package com.ideas.gui.scroller {
	import flash.display.Shape;
	import flash.geom.Matrix;
	public class ScrollerIndicator extends Shape {
		public static const WIDTH:int = 6;
		private var _height:Number = 100;
		public function ScrollerIndicator() {
			redraw()
		}
		public function setHeight(value:Number):void {
			_height = value;
			if (!isNaN(_height) && _height > 0 && _height < 2880) {
				redraw();
			}
		}
		private function redraw():void {
			this.graphics.clear();
			var mtrx:Matrix = new Matrix;
			mtrx.createGradientBox(WIDTH, WIDTH);
			this.graphics.beginGradientFill("linear", [ 0xcccccc, 0x808080 ], [ 1, 1 ], [ 0, 0xff ], mtrx);
			this.graphics.drawRoundRect(0, 0, WIDTH, _height, WIDTH, WIDTH);
			this.graphics.endFill();
		}
	}
}

package com.ideas.gui.buttons {
	import flash.display.Shape;
	public class LineSeparator extends Shape {
		public function LineSeparator() {
		}
		public function draw(wid:int=0,hgt:int=0,color:uint=0x555555):void {
			this.graphics.lineStyle(3, color,1,false,"none");
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(wid, hgt);
		}
	}
}

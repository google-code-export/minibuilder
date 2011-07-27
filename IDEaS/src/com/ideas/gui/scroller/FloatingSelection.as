package com.ideas.gui.scroller {
	import flash.display.Shape;
	import flash.geom.Matrix;
	public class FloatingSelection extends Shape {
		protected var wid:Number=0;
		protected var hgt:Number=0;
		public function FloatingSelection() {
		}
		public function setSize(wid:Number, hgt:Number):void {
			if(isNaN(wid) || isNaN(hgt)){
				return;
			}
			if (this.wid != wid || this.hgt != hgt) {
				this.wid = wid;
				this.hgt = hgt;
				redraw()
			}
		}
		protected function redraw():void {
			
		}
	}
}

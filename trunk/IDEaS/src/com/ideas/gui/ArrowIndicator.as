package com.ideas.gui {
	import flash.display.Shape;
	public class ArrowIndicator extends Shape {
		private var _wid:int=0;
		private var _hgt:int=0;
		public function ArrowIndicator(wid:int=100, hgt:int=100) {
			_wid=wid;
			_hgt=hgt;
			this.graphics.clear();
			this.graphics.beginFill(0x808080,0.001);
			this.graphics.drawRect(0, 0, _wid, _hgt);
			this.graphics.endFill();
			this.graphics.beginFill(0xffffff,1);
			this.graphics.moveTo(_wid/2,_hgt/4);
			this.graphics.lineTo(_wid*3/4,_hgt/2);
			this.graphics.lineTo(_wid*3/4,_hgt*3/4);
			this.graphics.lineTo(_wid/2,_hgt/2);
			this.graphics.lineTo(_wid/4,_hgt*3/4);
			this.graphics.lineTo(_wid/4,_hgt/2);
			this.graphics.endFill();
			
		}
	}
}
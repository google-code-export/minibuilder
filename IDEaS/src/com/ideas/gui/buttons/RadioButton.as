package com.ideas.gui.buttons {
	import flash.display.Sprite;
	import flash.geom.Matrix;

	public class RadioButton extends Sprite {
		public static const SIZE:int=50;
		private var _enable:Boolean=false;
		private var mtrx:Matrix=new Matrix();
		public function RadioButton() {
			redraw();
		}
		private function redraw():void {
			this.graphics.clear();
			mtrx.identity();
			mtrx.createGradientBox(SIZE,SIZE,0,-SIZE/2,-SIZE/2);
			this.graphics.lineStyle(1,0x222222);
			this.graphics.beginGradientFill("radial",[0xcccccc,0x555555],[1,1],[0,0xff],mtrx)//.beginFill(0x808080);
			this.graphics.drawCircle(0,0,SIZE/2);
			this.graphics.endFill();
			this.graphics.lineStyle(1,0x222222);
			mtrx.identity();
			mtrx.createGradientBox(SIZE*2/3,SIZE*2/3,0,-SIZE/3,-SIZE/3);
			this.graphics.beginGradientFill("radial",_enable?[0xFFCC29,0xF58634]:[0xE6E7E8,0xA9ABAE],[1,1],[0,0xff],mtrx)//.beginFill(0x808080);
			//this.graphics.beginFill(_enable?0xff8000:0xcccccc);
			
			this.graphics.drawCircle(0,0,SIZE/3);
			this.graphics.endFill();
		}
		public function get enable():Boolean {
			return _enable;
		}
		public function set enable(value:Boolean):void {
			_enable=value;
			redraw();
		}
	}
}
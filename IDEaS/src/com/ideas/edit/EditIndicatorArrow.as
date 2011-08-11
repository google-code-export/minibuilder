package com.ideas.edit {
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import flash.geom.Matrix;

	public class EditIndicatorArrow extends Shape {
		public static const ARROW_BORDERS:int=12;
		public function EditIndicatorArrow(wid:Number=ARROW_BORDERS, hgt:Number=56) {
			
			//
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(hgt, hgt, Math.PI / 2, 0, 0);
			this.graphics.lineStyle(1, 0xcccccc, 1, true);
			this.graphics.beginGradientFill("linear",   [ 0x555555, 0x0 ], [ 1, 1 ], [ 0, 0xff ], mtrx);
			//
			this.graphics.drawRoundRect(0, 0, wid, hgt,8,8);
			this.graphics.endFill();
			this.graphics.lineStyle(3, 0xffffff,1,true,"normal",CapsStyle.SQUARE,JointStyle.MITER);
			this.graphics.moveTo(wid*3/4,hgt/2-wid/2);
			this.graphics.lineTo(wid*1/4,hgt/2);
			this.graphics.lineTo(wid*3/4,hgt/2+wid/2);
		}
	}
}

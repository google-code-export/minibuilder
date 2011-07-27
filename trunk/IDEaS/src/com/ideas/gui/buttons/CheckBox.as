package com.ideas.gui.buttons {
    import flash.display.Sprite;
    import flash.geom.Matrix;
    public class CheckBox extends Sprite {
        public static const SIZE:int = 50;
        private var _enable:Boolean = false;
        private var mtrx:Matrix = new Matrix();
        public function CheckBox() {
            redraw();
        }
        private function redraw():void {
            this.graphics.clear();
			mtrx.createGradientBox(SIZE,SIZE,Math.PI/2,0,0);
            this.graphics.lineStyle(2, 0x222222);
            this.graphics.beginGradientFill("linear", [ 0xcccccc, 0x808080 ], [ 1, 1 ], [ 0, 0xff ], mtrx) //.beginFill(0x808080);
            this.graphics.drawRoundRect(0, 0, SIZE ,SIZE,5,5);
            this.graphics.endFill();
			this.graphics.lineStyle(9,0);
			drawV();
			this.graphics.lineStyle(7,_enable ? 0xff8000 : 0xcccccc);
			drawV();
			/*
            this.graphics.lineStyle(2, 0x222222);
            this.graphics.beginFill(_enable ? 0xff8000 : 0xcccccc);
            this.graphics.drawCircle(SIZE/2, SIZE/2, SIZE / 4);
            this.graphics.endFill();
			*/
        }
		private function drawV():void {
			this.graphics.moveTo(SIZE/4,SIZE/2);
			this.graphics.lineTo(SIZE*2/5,SIZE*3/4);
			this.graphics.lineTo(SIZE*3/4,SIZE/4);
		}
        public function get enable():Boolean {
            return _enable;
        }
        public function set enable(value:Boolean):void {
            _enable = value;
            redraw();
        }
    }
}

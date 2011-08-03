package com.ideas.gui.buttons {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class PlusButton extends Sprite {
		private var _data:Object = null;
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var _size:int = 24;
		private var _sizeTwo:int = 8;
		private var _over:Boolean;
		public function PlusButton(wid:int = 50, hgt:int = 50) {
			_wid = wid;
			_hgt = hgt;
			redraw();
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		public function get data():Object {
			return _data;
		}
		public function set data(value:Object):void {
			_data = value;
		}
		private function onOver(e:Event):void {
			_over = true;
			redraw();
		}
		private function onOut(e:Event):void {
			_over = false;
			redraw();
		}
		private function redraw():void {
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xcccccc, 1, true);
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(_hgt, _hgt, Math.PI / 2, 0, 0);
			this.graphics.beginGradientFill("linear", _over ? [ 0x8c4600, 0xff8000 ] : [ 0x555555, 0x0 ], [ 1, 1 ], [ 0, 0xff ], mtrx);
			this.graphics.drawRoundRect(0, 0, _wid, _hgt, 8, 8);
			this.graphics.lineStyle(0, 0, 0);
			this.graphics.endFill();
			this.graphics.beginFill(_over ? 0 : 0xffffff);
			this.graphics.drawRect(_wid / 2 - _size / 2, _hgt / 2 - _sizeTwo / 2, _size, _sizeTwo);
			this.graphics.endFill();
			this.graphics.endFill();
			this.graphics.beginFill(_over ? 0 : 0xffffff);
			this.graphics.drawRect(_wid / 2 - _sizeTwo / 2, _hgt / 2 - _size / 2, _sizeTwo, _size);
			this.graphics.endFill();
			this.cacheAsBitmap = true;
		}
	}
}

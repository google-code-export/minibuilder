package com.ideas.gui.buttons {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class SwitchButton extends Sprite {
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var txt:TextField;
		private var _over:Boolean;
		private var _data:Array;
		private var _counter:int = 0;
		public function SwitchButton(wid:int = 120, hgt:int = 50, data:Array = null) {
			_wid = wid;
			_hgt = hgt;		
			txt = new TextField();
			addChild(txt);
			txt.height = _hgt - 10;
			txt.width = _wid;
			txt.y = 10;
			txt.selectable = false;
			txt.mouseEnabled = false;
			txt.defaultTextFormat = new TextFormat("_sans", 24, 0xffffff, false, null, null, null, null, "center");
			this.data = data;
			redraw();
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		public function getValue():Object {
			return _data[_counter];
		}
		public function get data():Array {
			return _data;
		}
		public function set data(value:Array):void {
			_data = value;
			if(_data){
				_counter=0;
				setText(_data[_counter].label);
			}
		}
		public function get counter():int {
			return _counter;
		}
		public function set counter(value:int):void {
			_counter = value;
			if(_counter<0){
				_counter=0;
			}else if(_counter>=this._data.length){
				_counter=0;
			}
			if(_data){
				setText(_data[_counter].label);
			}
		}
		private function onOver(e:Event):void {
			_over = true;
			redraw();
		}
		private function onOut(e:Event):void {
			_over = false;
			redraw();
		}
		public function setText(value:String):void {
			txt.text = value;
		}
		public function setWidth(value:Number):void {
			_wid = value;
			txt.width = _wid;
			redraw();
		}
		private function redraw():void {
			var format:TextFormat = txt.getTextFormat(0, txt.length);
			format.color = _over ? 0x000000 : 0xffffff;
			txt.setTextFormat(format, 0, txt.length);
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xcccccc, 1, true);
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(_hgt, _hgt, Math.PI / 2, 0, 0);
			this.graphics.beginGradientFill("linear", _over ? [ 0x8c4600, 0xff8000 ] : [ 0x555555, 0x0 ], [ 1, 1 ], [ 0, 0xff ], mtrx);
			this.graphics.drawRoundRect(0, 0, _wid, _hgt, 8, 8);
			this.graphics.endFill();
			this.cacheAsBitmap = true;
		}
	}
}

package com.ideas.gui.buttons {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	public class IconToggleButton extends Sprite {
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var _size:int = 24;
		private var _sizeTwo:int = 8;
		private var _over:Boolean;
		private var _enableIcon:DisplayObject;
		private var _disableIcon:DisplayObject;
		private var _enable:Boolean = false;
		public function IconToggleButton(wid:int = 50, hgt:int = 50) {
			_wid = wid;
			_hgt = hgt;
			redraw();
			this.mouseChildren=false;
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		public function setEnableImage(obj:DisplayObject):void {
			
			if (obj) {
				if(_enableIcon){
					removeChild(_enableIcon);
				}
				_enableIcon = obj;
				setImage(_enableIcon);
				redraw();
			}
		}
		public function setDisableImage(obj:DisplayObject):void {
			
			if (obj) {
				if(_disableIcon){
					removeChild(_disableIcon);
				}
				_disableIcon = obj;
				setImage(_disableIcon);
				redraw();
			}
		}
		private function setImage(img:DisplayObject):void {
			addChild(img);
			img.width = _wid - 4;
			img.height = _hgt - 4;
			img.x = 2;
			img.y = 2;
			if (img is Bitmap) {
				img["smoothing"] = true;
			}
		}
		public function get enable():Boolean {
			return _enable;
		}
		public function set enable(value:Boolean):void {
			_enable = value;
			redraw();
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
			//
			trace(_enable);
			if (this._enableIcon) {
				this._enableIcon.visible =this._disableIcon? _enable:true;
			}
			if (this._disableIcon) {
				this._disableIcon.visible = !_enable;
			}
			//
			this.cacheAsBitmap = true;
		}
	}
}

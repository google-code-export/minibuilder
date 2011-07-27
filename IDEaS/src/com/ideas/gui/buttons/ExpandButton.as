package com.ideas.gui.buttons {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ExpandButton extends Sprite {
		private var _wid:int=0;
		private var _hgt:int=0;
		private var _size:int=24;
		private var _sizeTwo:int=8;
		private var _over:Boolean;
		public function ExpandButton(wid:int=50, hgt:int=50) {
			_wid=wid;
			_hgt=hgt;
			
			redraw();
			this.addEventListener(MouseEvent.MOUSE_OVER,onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,onOut);
		}
		private function onOver(e:Event):void {
			_over=true;
			redraw();
		}
		private function onOut(e:Event):void {
			_over=false;
			redraw();
		}
		
		private function redraw():void {
			this.graphics.clear();
			this.graphics.lineStyle(0,0xcccccc,1,true);
			var mtrx:Matrix=new Matrix();
			mtrx.createGradientBox(_hgt,_hgt,Math.PI/2,0,0);
			this.graphics.beginGradientFill("linear",_over?[0x8c4600,0xff8000]:[0x555555,0x0],[1,1],[0,0xff],mtrx);
			this.graphics.drawRoundRect(0,0,_wid,_hgt,5,5);
			this.graphics.lineStyle(0,0,0);
			this.graphics.endFill();
			//
			this.graphics.beginFill(_over?0:0xffffff);
			this.graphics.moveTo(_wid/4,_hgt/2);
			this.graphics.lineTo(_wid/2,_hgt*3/4);
			this.graphics.lineTo(_wid*3/4,_hgt*3/4);
			this.graphics.lineTo(_wid/2,_hgt/2);
			this.graphics.lineTo(_wid*3/4,_hgt/4);
			this.graphics.lineTo(_wid/2,_hgt/4);
			this.graphics.endFill();
			//
			this.cacheAsBitmap = true;
		}
	}
}
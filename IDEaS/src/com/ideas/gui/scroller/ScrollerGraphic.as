package com.ideas.gui.scroller {
	import flash.display.Sprite;
	public class ScrollerGraphic extends Sprite {
		protected var _width:Number = 100;
		protected var _height:Number = 100;
		public function ScrollerGraphic() {
			super();
		}
		public function setData(value:Object):void {
		}
		public function setWidth(value:Number):void {
			_width = value;
		}
		public function setHeight(value:Number):void {
			_height = value;
		}
		public function redraw(state:Boolean):void {
		}
		public function clear():void {
		}
	}
}

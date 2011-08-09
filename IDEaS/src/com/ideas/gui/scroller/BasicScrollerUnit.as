package com.ideas.gui.scroller {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	public class BasicScrollerUnit extends Sprite {
		protected var _over:Boolean;
		protected var _data:Object={};
		protected var graphicUnit:ScrollerGraphic;
		public function BasicScrollerUnit() {
			this.mouseChildren = false;
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		public function onRemoved(e:Event):void {
			if (graphicUnit) {
				graphicUnit.clear();
			}
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		public function get data():Object {
			return _data;
		}
		public function set data(value:Object):void {
			if (!value) {
				return;
			}
			_data = value;
			if (graphicUnit) {
				graphicUnit.setData(value);
			}
			redraw();
		}
		public function setGraphicUnit(value:ScrollerGraphic):void {
			graphicUnit = value;
			if (graphicUnit) {
				addChild(graphicUnit);
			}
			redraw();
		}
		public function set over(value:Boolean):void {
			_over = value;
			redraw();
		}
		public function get over():Boolean {
			return _over;
		}
		public function setWidth(value:Number):void {
			if (graphicUnit) {
				graphicUnit.setWidth(value);
			}
			redraw();
		}
		public function setHeight(value:Number):void {
			if (graphicUnit) {
				graphicUnit.setHeight(value);
			}
			redraw();
		}
		protected function redraw():void {
			if (graphicUnit) {
				graphicUnit.redraw(_over);
			}
		}
	}
}

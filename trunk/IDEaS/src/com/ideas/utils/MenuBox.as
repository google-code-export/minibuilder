package com.ideas.utils {
	import com.ideas.gui.scroller.BasicScrollerUnit;
	import com.ideas.gui.scroller.FloatingSelection;
	import com.ideas.gui.scroller.ScrollerContainer;
	import com.ideas.gui.scroller.ScrollerEvent;
	import com.ideas.menu.MenuScrollerGraphic;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	public class MenuBox extends EventDispatcher {
		private var scrollerContainer:ScrollerContainer = new ScrollerContainer();
		public static const KEYBOARD_REFOCUS:String = "KEYBOARD_REFOCUS"
		private var _xOffset:Number = 0;
		private var _isShowing:Boolean = false;
		public function MenuBox() {
			scrollerContainer.addEventListener(ScrollerEvent.LEAVE_STAGE_DOWN, onEmptyStageDown);
			scrollerContainer.addEventListener(ScrollerEvent.UNIT_SELECTED, onUnitSelected);
			for (var i:int = 0; i < 20; i++) {
				var unit:BasicScrollerUnit = new BasicScrollerUnit();
				unit.setGraphicUnit(new MenuScrollerGraphic());
				scrollerContainer.addUnit(unit);
			}
		}
		public function get isShowing():Boolean {
			return _isShowing;
		}
		private function onEmptyStageDown(e:Event):void {
			dispose();
			onKeyboardRefocus(e);
		}
		private function onKeyboardRefocus(e:Event):void {
			this.dispatchEvent(new Event(KEYBOARD_REFOCUS));
		}
		private function onUnitSelected(e:Event):void {
			this.dispatchEvent(new Event(ScrollerEvent.UNIT_SELECTED));
		}
		public function setListData(ld:Array):void {
			scrollerContainer.clearContainer();
			scrollerContainer.setListData(ld);
		}
		public function dispose():void {
			_isShowing = false;
			if (scrollerContainer.parent) {
				scrollerContainer.parent.removeChild(scrollerContainer);
			}
		}
		public function resize():void {
			if (scrollerContainer.stage) {
				var hgt:Number = this.scrollerContainer.stage.stageHeight - this.scrollerContainer.stage.softKeyboardRect.height - 20;
				scrollerContainer.onResize(-10 + this.scrollerContainer.stage.stageWidth / 2, hgt);
				if (_xOffset > this.scrollerContainer.stage.stageWidth / 2) {
					scrollerContainer.x = 0;
				} else {
					scrollerContainer.x = this.scrollerContainer.stage.stageWidth / 2;
				}
				scrollerContainer.y = 10;
			}
		}
		public function show(stage:Stage, xx:Number, yy:Number):void {
			_isShowing = true;
			_xOffset = xx;
			stage.addChild(scrollerContainer);
			resize();
		}
		public function setSelectedValueToFloating():void {
			var unit:BasicScrollerUnit = scrollerContainer.getFirstItem();
			if (unit) {
				scrollerContainer.selectedItem = unit;
			}
		}
		public function getSelectedValue():String {
			return scrollerContainer.selectedItem.data.toString();
		}
	}
}

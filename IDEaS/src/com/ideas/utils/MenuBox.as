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
		private var _yOffset:Number = 0;
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
				scrollerContainer.graphics.clear();
				var hgt:Number = this.scrollerContainer.stage.stageHeight - this.scrollerContainer.stage.softKeyboardRect.height - 20;
				var maxWidth:int = Math.min(this.scrollerContainer.stage.stageWidth / 2, 300);
				scrollerContainer.onResize(maxWidth - 30, hgt);
				var flip:Boolean = false;
				if (_xOffset > (this.scrollerContainer.stage.stageWidth - maxWidth)) {
					scrollerContainer.x = _xOffset - maxWidth;
					flip = true;
				} else {
					scrollerContainer.x = _xOffset + 30;
				}
				if (scrollerContainer.containerHeight + _yOffset < hgt) {
					scrollerContainer.y = _yOffset;
					drawFrame(hgt, maxWidth, false, flip)
				} else {
					scrollerContainer.y = 10;
					drawFrame(hgt, maxWidth, true, flip)
				}
			}
		}
		private function drawFrame(hgt:Number, wid:Number, indicator:Boolean, flip:Boolean):void {
			
			var scrollHeight:Number = Math.min(hgt, scrollerContainer.containerHeight);
			scrollerContainer.graphics.lineStyle(2, 0x808080);
			scrollerContainer.graphics.beginFill(0,0.2)
			var vi:Vector.<int> = new Vector.<int>();
			var vn:Vector.<Number> = new Vector.<Number>();
			vi[0] = 1;
			vn[0] = 0;
			vn[1] = 0;
			//
			vi[1] = 2;
			vn[2] = wid - 30;
			vn[3] = 0;
			//
			if (indicator && flip) {
				vi[2] = 2;
				vn[4] = wid - 30;
				vn[5] = _yOffset - 15 - 10;
				//
				vi[3] = 2;
				vn[6] = wid - 30 + 10;
				vn[7] = _yOffset - 15;
				//
				vi[4] = 2;
				vn[8] = wid - 30;
				vn[9] = _yOffset - 15 + 10;
			}
			vi[vi.length] = 2;
			vn[vn.length] = wid - 30;
			vn[vn.length] = scrollHeight;
			//
			vi[vi.length] = 2;
			vn[vn.length] = 0;
			vn[vn.length] = scrollHeight;
			//
			if (indicator && !flip) {
				vi[4] = 2;
				vn[8] = 0;
				vn[9] = _yOffset - 15 + 10;
				//
				vi[5] = 2;
				vn[10] = -10;
				vn[11] = _yOffset - 15;
				//
				vi[6] = 2;
				vn[12] = 0;
				vn[13] = _yOffset - 15 - 10;
			}
			vi[vi.length] = 2;
			vn[vn.length] = 0;
			vn[vn.length] = 0;
			scrollerContainer.graphics.drawPath(vi, vn);
			scrollerContainer.graphics.endFill();
		}
		public function show(stage:Stage, xx:Number, yy:Number):void {
			_isShowing = true;
			_xOffset = xx;
			_yOffset = yy;
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

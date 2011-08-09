package com.ideas.text {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.getTimer;
	public class DebugPanel extends TextField {
		public static const INIT_SCROLLING:String = "init_scrolling";
		private var scrollDiffernce:Number = 0;
		private var _scrollV:Number = 0;
		private var mouseDown:Boolean;
		private var scrollDelta:int = 0;
		private var _percent:Number = 0;
		private var scrollTimerDelta:int = 0;
		public function DebugPanel() {
			this.border = true;
			this.selectable = false;
			this.wordWrap = true;
			this.multiline = true;
			this.background = true;
			this.backgroundColor = 0xcccccc;
			this.addEventListener(Event.SCROLL, scrollHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, onWriteTextUp);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onWriteTextDown);
		}
		private function onWriteTextDown(e:MouseEvent):void {
			scrollDiffernce = 0;
			mouseDown = true;
			this.removeEventListener(Event.ENTER_FRAME, onKineticScroll);
		}
		private function onWriteTextUp(e:MouseEvent):void {
			mouseDown = false;
			if (Math.abs(scrollDiffernce) > 0) {
				_scrollV = this.scrollV;
				this.addEventListener(Event.ENTER_FRAME, onKineticScroll);
			}
		}
		private function onKineticScroll(e:Event):void {
			scrollDiffernce *= 0.95;
			_scrollV -= scrollDiffernce / 2;
			this.scrollV = _scrollV
			var scrollIndex:int = this.getLineOffset(this.scrollV)
			this.setSelection(scrollIndex, scrollIndex);
			if (Math.abs(scrollDiffernce) <= 0.1) {
				scrollDiffernce = 0;
				this.removeEventListener(Event.ENTER_FRAME, onKineticScroll);
			}
		}
		private function scrollHandler(e:Event):void {
			if (mouseDown) {
				var dif:Number = scrollDelta - this.scrollV;
				if (getTimer() - scrollTimerDelta < 40) { 
					scrollDiffernce += dif
				} else {
					scrollDiffernce = 0;
				}
				scrollTimerDelta = getTimer();
				scrollDelta = this.scrollV
			}
			_percent = (this.scrollV - 1) / (this.maxScrollV - 1);
			this.dispatchEvent(new Event(INIT_SCROLLING));
		}
	}
}

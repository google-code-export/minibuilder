package com.ideas.text {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	public class DebugPanel extends TextField {
		private var _debugExtended:Boolean = false;
		public static const DEBUG_RESIZE:String = "debug_resize";
		public function DebugPanel() {
			this.border = true;
			this.selectable = false;
			this.wordWrap = true;
			this.multiline = true;
			this.background = true;
			this.backgroundColor = 0xcccccc;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMessageDown);
		}
		public function getDebugOffset():int {
			return int(_debugExtended) * 200;
		}
		private function onMessageDown(e:Event):void {
			if (!_debugExtended) {
				_debugExtended = true;
				this.dispatchEvent(new Event(DEBUG_RESIZE));
				return;
			}
			highlightError(false);
			if (this.scrollV >= this.maxScrollV) {
				this.scrollV = -1;
				if (_debugExtended) {
					_debugExtended = false;
					this.dispatchEvent(new Event(DEBUG_RESIZE));
				}
			} else {
				this.scrollV++;
			}
		}
		public function highlightError(value:Boolean = true):void {
			if (value) {
				this.filters = [ new GlowFilter(0xff0000, 1, 8, 8, 1, 3, true), new GlowFilter()]
			} else {
				this.filters = [];
			}
		}
	}
}

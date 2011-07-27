package com.ideas.gui.scroller {
	import flash.events.Event;
	public class ScrollerEvent extends Event {
		public static const UNIT_SELECTED:String = "unitSelected"
		public static const LEAVE_STAGE_DOWN:String = "leaveStageDown"
		public function ScrollerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}

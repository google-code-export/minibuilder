package com.ideas.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;

	public class PseudoThread extends EventDispatcher {
		public var RENDER_DEDUCTION:int=10;
		private var fn:Function;
		private var obj:Object;
		private var thread:Sprite;
		private var start:Number;
		private var due:Number;
		private var sm:Sprite;
		private var mouseEvent:Boolean;
		private var keyEvent:Boolean;
		public function PseudoThread(da:Sprite, threadFunction:Function, threadObject:Object=null) {
			fn=threadFunction;
			sm=da;
			if (obj == null) {
				obj=threadObject;
			} else {
				obj=new Object();
			}
			// add high priority listener for ENTER_FRAME
			sm.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 200, true);
			sm.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			sm.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
			thread=new Sprite();
			sm.addChild(thread);
			thread.addEventListener(Event.RENDER, renderHandler);
		}
		// number of milliseconds we think it takes to render the screen
		private function enterFrameHandler(event:Event):void {
			start=getTimer();
			var fr:Number=Math.floor(1000 / thread.stage.frameRate);
			due=start + fr;
			thread.stage.invalidate();
			thread.graphics.clear();
			thread.graphics.moveTo(0, 0);
			thread.graphics.lineTo(0, 0);
		}
		private function renderHandler(event:Event):void {
			if (mouseEvent || keyEvent) {
				due-=RENDER_DEDUCTION;
			}
			while (getTimer() < due) {
				if (obj == null) {
					if (!fn()) {
						if (!thread.parent) {
							return;
						}
						sm.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
						sm.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
						sm.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
						sm.removeChild(thread);
						thread.removeEventListener(Event.RENDER, renderHandler);
						thread=null;
						thread=new Sprite();
						dispatchEvent(new Event("threadComplete"));
					}
				} else {
					if (!fn(obj)) {
						if (!thread.parent) {
							return;
						}
						sm.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
						sm.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
						sm.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
						sm.removeChild(thread);
						thread=null;
						thread=new Sprite();
						thread.removeEventListener(Event.RENDER, renderHandler);
						dispatchEvent(new Event("threadComplete"));
					}
				}
			}
			mouseEvent=false;
			keyEvent=false;
		}
		private function mouseMoveHandler(event:Event):void {
			mouseEvent=true;
		}
		private function keyDownHandler(event:Event):void {
			keyEvent=true;
		}
	}
}
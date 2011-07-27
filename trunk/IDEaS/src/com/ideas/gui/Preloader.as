package com.ideas.gui {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Preloader extends Shape {
		
		private static const RADIUS:int=10;
		private var timer:Timer;
		
		public function Preloader() {
			for (var i:Number=0; i < Math.PI * 2; i+=Math.PI / 5) {
				this.graphics.beginFill(0x0, (i + (Math.PI / 5)) / ((Math.PI * 2) + (Math.PI / 5)));
				this.graphics.drawCircle(RADIUS * Math.cos(i), RADIUS * Math.sin(i), 2);
				this.graphics.endFill();
			}
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		private function onAdded(e:Event):void {
			
			timer=new Timer(1000 / 24, 0);
			timer.addEventListener(TimerEvent.TIMER, onTick);
			timer.start();
		}
		public function resize(xx:int,yy:int):void {
			this.x=xx-RADIUS-10;
			this.y=yy-RADIUS-10;
		}
		private function onRemoved(e:Event):void {
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTick);
		}
		private function onTick(e:TimerEvent):void {
			this.rotation+=180/5;
		}
	}
}
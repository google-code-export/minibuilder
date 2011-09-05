package com.ideas.gui {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flashx.textLayout.formats.TextAlign;
	public class Preloader extends Sprite {
		private static const RADIUS:int = 10;
		private var timer:Timer;
		private var counter:TextField = new TextField();
		private var shp:Shape = new Shape();
		public function Preloader() {
			for (var i:Number = 0; i < Math.PI * 2; i += Math.PI / 5) {
				shp.graphics.beginFill(0xff0000, (i + (Math.PI / 5)) / ((Math.PI * 2) + (Math.PI / 5)));
				shp.graphics.drawCircle(RADIUS * Math.cos(i), RADIUS * Math.sin(i), 2);
				shp.graphics.endFill();
			}
			this.addChild(shp);
			this.addChild(counter);
			counter.x = -RADIUS-2;
			counter.y = -8;
			counter.width = RADIUS * 2+4;
			//counter.background = true;
			counter.height=16;
			
			counter.defaultTextFormat = new TextFormat("_sans", 10, 0xff0000, null, null, null, null, null, TextAlign.CENTER);
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}
		public function setPercent(value:int):void {
			
			counter.text = value.toString();
		}
		private function onAdded(e:Event):void {
			timer = new Timer(1000 / 24, 0);
			timer.addEventListener(TimerEvent.TIMER, onTick);
			timer.start();
		}
		public function resize(xx:int, yy:int):void {
			this.x = xx - RADIUS - 10;
			this.y = yy - RADIUS - 10;
		}
		private function onRemoved(e:Event):void {
			timer.stop();
			counter.text="";
			timer.removeEventListener(TimerEvent.TIMER, onTick);
		}
		private function onTick(e:TimerEvent):void {
			shp.rotation += 180 / 5;
		}
	}
}

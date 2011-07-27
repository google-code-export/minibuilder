package com.ideas.gui.buttons
{
	import flash.events.Event;
	import flash.text.TextField;
	
	public class MotionText extends TextField
	{
		private var postTimer:int=0;
		private var preTimer:int=0;
		public function MotionText()
		{
			postTimer=0;
			preTimer=0;
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		public function play():void{
			if(this.maxScrollH>0){
				this.addEventListener(Event.ENTER_FRAME,onTick,false,0,true);
			}
		}
		public function stop():void{
			this.scrollH=0;
			this.removeEventListener(Event.ENTER_FRAME,onTick);
		}
		private function onRemoved(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			this.removeEventListener(Event.ENTER_FRAME,onTick);
		}
		private function onTick(e:Event):void {
			preTimer++;
			if(preTimer>12){
				this.scrollH++;
			}
			if(this.scrollH>=this.maxScrollH){
				postTimer++;
				if(postTimer>12){
					this.scrollH=0;
					preTimer=0;
				}
			}else{
				postTimer=0
			}
			if(this.maxScrollH<=0){
				this.removeEventListener(Event.ENTER_FRAME,onTick);
			}
		}
	}
}
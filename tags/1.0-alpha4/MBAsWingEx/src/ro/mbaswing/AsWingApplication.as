package ro.mbaswing
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.AsWingManager;
	import org.aswing.Container;
	import org.aswing.JWindow;
	
	public class AsWingApplication extends Sprite
	{
		protected var frame:JWindow;
		
		public function AsWingApplication()
		{
			AsWingManager.initAsStandard(this);
			frame = new JWindow(this);
			
			if (stage)
				onAdded(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function getContentPane():Container
		{
			return frame.getContentPane();
		}
		
		public function setContentPane(cp:Container):void
		{
			frame.setContentPane(cp);
		}
		
		private function onAdded(e:Event):void
		{
			stage.align = 'TL';
			stage.scaleMode = 'noScale';
			
			frame.show();
			AsWingManager.setRoot(this);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize(null);
		}
		
		private function onResize(e:Event):void
		{
			frame.setSizeWH(stage.stageWidth, stage.stageHeight);
			drawBackground();
		}
		
		protected function drawBackground():void
		{
			
		}
	}
}
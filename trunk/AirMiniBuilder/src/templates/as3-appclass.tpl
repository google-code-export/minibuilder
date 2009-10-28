package ${PACKAGE}
{
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.display.Sprite;
	import com.victordramba.console.*;
	
	/**
	 * Application entry-point
	 */
	public class Application extends Sprite
	{
		public function Application()
		{
		
			//uncomment to enable debugger console
			//Debugger.setParent(this, true);
			//debug('started in ' + this);
			
			
			//This is a simple animation example. Replace with your own code
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;
			
			x = y = 170;
			var a:Array = [];
			for (var i:uint = 0; i < 30; i++)
			{
				var s:Shape = new Shape;
				s.graphics.clear();
				s.graphics.beginFill(i * 0x90000 + i * 0x10, .07);
				s.graphics.drawRoundRect(10+i, 10+i, 100, 100, 30);
				s.graphics.endFill();
				addChild(s);
				a.push(s);
			}
			addEventListener('enterFrame', function(e:Event):void
			{
				var i:uint;
				for each(s in a)
					s.rotation += i++/3;

				rotation += .6;
				rotationY += .4;
			});
		}
	}
}
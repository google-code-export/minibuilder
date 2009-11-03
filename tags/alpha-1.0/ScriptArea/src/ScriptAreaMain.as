package {
	
	import com.victordramba.console.Debugger;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	import ro.victordramba.scriptarea.ScriptAreaEvents;

	[SWF(backgroundColor="#ffffff")]
	public class ScriptAreaMain extends Sprite
	{
		public function ScriptAreaMain()
		{
			stage.align = 'TL';
			stage.scaleMode = 'noScale';
			
			Debugger.setParent(stage);
			
			var ta:ScriptAreaEvents = new ScriptAreaEvents;
			ta.x = 20;
			ta.y = 20;
			addChild(ta);
			//stage.focus = ta;
			stage.addEventListener(Event.RESIZE, function(e:Event):void {
				ta.width = stage.stageWidth - 40;
				ta.height = stage.stageHeight-40;
			});
			ta.width = stage.stageWidth-40;
			ta.height = stage.stageHeight-40;
			for (var i:int=0; i<30; i++)
				ta.appendText('This is line number '+i+'.\n');
			ta.appendText('end');
			
			ta.scrollY = ta.maxscroll;
			
			ta.addFormatRun(10, 20, true, true, 'ff0000');
			ta.addFormatRun(30, 40, true, true, '00ff00');
			ta.addFormatRun(70, 1000, true, false, '0000ff');
			ta.applyFormatRuns();
		}
	}
}

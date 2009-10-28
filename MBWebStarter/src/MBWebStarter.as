package
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class MBWebStarter extends Sprite
	{
		private var ld:Loader;
		private var air:Object;
		private var pubID:String = '9AFB026107D8A1DC803F66D0B1251CFF9EC1990E.1';
		private var appID:String = 'ro.minibuilder.AirMiniBuilder';
		
		[Embed(source="banner.png")]
		private var bgAsset:Class;
		
		public function MBWebStarter()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addChild( (new bgAsset) as DisplayObject);
			
			ld = new Loader;
			ld.load(new URLRequest('http://airdownload.adobe.com/air/browserapi/air.swf'));
			ld.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void {
				air = ld.content;
				air.getApplicationVersion(appID, pubID, onVersionReady);
			});
		}
		
		private function onVersionReady(version:String):void
		{
			var btn:Sprite = new Sprite;
			btn.graphics.beginFill(0xcc0000, 0);
			btn.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			/*var txt:TextField = new TextField;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.defaultTextFormat = new TextFormat('_sans', 14, 0xffffff);
			txt.text = 'MiniBuilder: ' + loaderInfo.parameters.name;*/
			
			btn.mouseChildren = false;
			//btn.addChild(txt);
			
			
			
			btn.buttonMode = true;
			addChild(btn);
			
			btn.addEventListener(MouseEvent.CLICK, version ? onClickLaunch : onClickInstall);
		}
		
		private function onClickInstall(e:MouseEvent):void
		{
			air.installApplication('http://minibuilder.googlecode.com/files/AirMiniBuilder.air', '1.5'
				/*, [loaderInfo.parameters.zipurl]*/);
		}
		
		private function onClickLaunch(e:MouseEvent):void
		{
			air.launchApplication(appID, pubID/*, [loaderInfo.parameters.zipurl]*/);
		}
	}
}
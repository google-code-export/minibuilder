package ${PACKAGE}
{
	import mx.controls.Label;
	import mx.controls.TabBar;
	import mx.core.Application;
	import mx.events.FlexEvent;

	public class Application extends mx.core.Application
	{
		override public function initialize() : void
		{
			super.initialize();

			layout = 'vertical';
			setStyle('paddingTop', 10);

			var data:Array = ['aaa','bbb','ccc']

			var tabs:TabBar = new TabBar;
			tabs.dataProvider = data;
			addChild(tabs);

			var label:Label = new Label;
			addChild(label);

			tabs.addEventListener(FlexEvent.VALUE_COMMIT, function(e:FlexEvent):void {
				label.text = 'Selected tab: '+data[tabs.selectedIndex];
			});
		}
	}
}
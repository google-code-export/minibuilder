package
{
	public class Starter
	{
		private static var inited:Boolean = false;
		
		public static function init():void
		{
			if (inited) return;
			inited = true;
			new ${APP_NAME}();
		}
	}
	
	Starter.init();
}
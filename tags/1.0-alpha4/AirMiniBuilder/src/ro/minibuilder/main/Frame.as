package ro.minibuilder.main
{
	import flash.filters.DropShadowFilter;
	
	import org.aswing.AsWingUtils;
	import org.aswing.JFrame;
	
	public class Frame extends JFrame
	{
		public function Frame(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			filters = [new DropShadowFilter(2, 45, 0, .3, 6, 6)];	
		}
		
		protected function setSizeAndCenter(w:int, h:int):void
		{
			setSizeWH(w, h);
			AsWingUtils.centerLocate(this);
		}
	}
}
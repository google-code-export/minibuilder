package ro.minibuilder.main
{
	import org.aswing.Insets;
	import org.aswing.border.EmptyBorder;
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
			getContentPane().setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));			
			setSizeWH(w, h);
			AsWingUtils.centerLocate(this);
		}
	}
}
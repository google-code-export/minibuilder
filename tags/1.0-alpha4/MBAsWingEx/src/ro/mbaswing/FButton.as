package ro.mbaswing
{
	import org.aswing.Icon;
	
	public class FButton extends org.aswing.JButton
	{
		public function FButton(text:String="", icon:Icon=null)
		{
			super(text, icon);
			setPreferredWidth(90);
		}
	}
}
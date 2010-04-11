package ro.minibuilder.main
{
	import flash.events.Event;
	import ro.mbaswing.TablePane;
	import flash.system.Capabilities;
	import ro.mbaswing.FButton;
	import org.aswing.JPanel;
	import org.aswing.Insets;
	import org.aswing.border.EmptyBorder;
	import flash.filters.DropShadowFilter;
	
	import org.aswing.AsWingUtils;
	import org.aswing.JFrame;
	import org.aswing.Container;
	
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
		
		protected var okBtn:FButton;
		protected var cancelBtn:FButton;
		
		public function addOKCancel(pane:TablePane, okLabel:String='OK', cancelLabel:String='Cancel', colspan:int=2):void
		{
			pane.addSeparatorRow();
			
			okBtn = new FButton(okLabel);
			cancelBtn = new FButton(cancelLabel);
			
			var box:Container;
			if (Capabilities.os.toLowerCase().indexOf('linux') != -1)
				box = TablePane.hBox(5, cancelBtn, okBtn);
			else
				box = TablePane.hBox(5, okBtn, cancelBtn);
			
			pane.addCell(box, TablePane.ALIGN_RIGHT, colspan);
			
			cancelBtn.addActionListener(cancelClick);
			okBtn.addActionListener(okClick);
		}
		
		protected function okClick(e:Event=null):void
		{
			dispose();
		}
		
		protected function cancelClick(e:Event = null):void
		{
			dispose();
		}
	}
}
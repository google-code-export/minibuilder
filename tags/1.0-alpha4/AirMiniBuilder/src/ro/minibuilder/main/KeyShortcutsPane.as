package ro.minibuilder.main
{
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.Constants;
	import ro.victordramba.util.StringEx;

	public class KeyShortcutsPane extends Frame
	{
		public function KeyShortcutsPane()
		{
			super(null, 'Key Shortcuts', false);
			
			var pane:TablePane = new TablePane(1);
			setContentPane(pane);
			
			var map:Object = {};
			var xml:XML = Constants.SHORTCUTS;
			for each (var n:XML in xml.key)
			{
				if (!map[n.@action]) map[n.@action] = [];
				var k:String = (n.@ctrl==1 ? 'CTRL+' : '') + (n.@shift==1 ? 'SHIFT+':'') + (n.@alt==1 ? 'ALT+':'') + n.@key;
				map[n.@action].push(k);
			}
			var a:Array = [];
			for (var act:String in map)
				a.push(act);
			a.sort();
					
			for each (act in a)
			{
				pane.newRow();
				pane.addCell(new JLabel(StringEx.ucFirst(act)), TablePane.ALIGN_LEFT);
				pane.addCell(new JLabel(map[act].join(', ')), TablePane.ALIGN_LEFT);
			}
			pane.newRow(true);
			pane.addCell(null);
			
			pane.addSeparatorRow();
			
			var btn:FButton;
			pane.addCell(TablePane.hBox(5, btn=new FButton('Close')), TablePane.ALIGN_RIGHT, 2);
			btn.addActionListener(function(e:*):void {
				dispose();
			});
			
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			setSizeAndCenter(550, 350);
		}
	}
}
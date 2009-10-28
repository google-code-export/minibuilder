package ro.minibuilder.main
{
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.describeType;
	
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JScrollPane;
	import org.aswing.SoftBox;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	
	public class Customize extends JFrame
	{
		private var addBtn:JButton;
		private var removeBtn:JButton;
		private var lst1:JList;
		private var lst2:JList;
		
		private var closeBtn:JButton;
		
		
		public function Customize()
		{
			super(null, 'Customize', true);
			
			var names:Array = [];
			var xml:XML = describeType(ActionManager);
			for each (var n:XML in xml.factory.method)
			{
				if (/^do[A-Z]/.test(n.@name))
					names.push(n.@name.substr(2));
			}
			
			names.sort();
			
			var pane:TablePane = new TablePane;
			pane.setColWidths(150, 90, 150, '*');
			setContentPane(pane);
			pane.setBorder(new EmptyBorder(null, new Insets(10,10,10,10)));
			
			pane.newRow();
			pane.addLabel('Available Actions');
			pane.addCell(null);
			pane.addLabel('Added Buttons');
			
			pane.newRow(true);
			pane.addCell(new JScrollPane(lst1 = new JList(names)));
			
			var box:SoftBox = SoftBox.createVerticalBox(5);
			box.append(addBtn = new JButton('Add'));
			box.append(removeBtn = new JButton('Remove'));
			
			pane.addCell(box, TablePane.ALIGN_TOP | TablePane.EXPAND_H);
			pane.addCell(new JScrollPane(lst2 = new JList));
			pane.addCell(null);
			
			pane.addSeparatorRow();
			
			pane.addCell(closeBtn = new FButton('Close'), TablePane.ALIGN_RIGHT, 4);
			closeBtn.addActionListener(function(e:Event):void {
				dispose();
			});
			
			setSizeWH(450, 400);
			
			AsWingUtils.centerLocate(this);
			
			var buttons:Array = load();
			lst2.setListData(buttons);
			
			addBtn.addActionListener(function(e:Event):void
			{
				if (lst1.getSelectedIndex() < 0) return;
				for each (var v:String in lst1.getSelectedValues())
					buttons.push(v);
				save(buttons);
			});
				
			removeBtn.addActionListener(function(e:Event):void {
				if (lst2.getSelectedIndex() < 0) return;
				buttons.splice(lst2.getSelectedIndex(), 1);
				lst2.setListData(buttons);
				save(buttons);
			});
		}
		
		private function load():Array
		{
			var so:SharedObject = SharedObject.getLocal('buttons');
			return so.data.buttons ? so.data.buttons : [];
		}
		
		private function save(lst:Array):void
		{
			lst2.setListData(lst);
			var so:SharedObject = SharedObject.getLocal('buttons');
			so.data.buttons = lst;
			so.flush();
			
			ActionManager.inst.do_refreshButtonBar();
		}
	}
}
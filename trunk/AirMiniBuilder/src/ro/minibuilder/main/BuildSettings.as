package ro.minibuilder.main
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JFrame;
	import org.aswing.JSpacer;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	import org.aswing.geom.IntDimension;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.IProjectPlug;
	
	public class BuildSettings extends JFrame
	{
		
		private var cbList:Vector.<JCheckBox>;
		private var destTxt:JTextField;
		private var project:IProjectPlug;
		
		public function BuildSettings(project:IProjectPlug)
		{
			super(null, 'Build settings', true);
			
			this.project = project;
			
			var pane:TablePane = new TablePane(1);
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			setContentPane(pane);
			
			pane.newRow();
			pane.addLabel('Copy output files', 136, 2);
			pane.newRow();
			pane.addCell(null);
			pane.addLabel('Select files to copy:');
			
			cbList = new Vector.<JCheckBox>;
			
			for each (var f:File in new File(project.path).resolvePath('bin-debug').getDirectoryListing())
			{
				pane.newRow();
				pane.addCell(null);
				cbList.push(new JCheckBox(f.name));
				pane.addCell(cbList[cbList.length-1], TablePane.ALIGN_LEFT);
			}
			
			pane.newRow();
			pane.addCell(new JSpacer(new IntDimension(1,10)));
			
			pane.newRow();
			pane.addLabel('Destination:');
			pane.addCell(destTxt = new JTextField);
			
			pane.newRow(true);
			pane.addCell(null);
			
			pane.addSeparatorRow();
			
			pane.newRow();
			var okBtn:JButton;
			var cancelBtn:JButton;
			pane.addCell(TablePane.hBox(5, okBtn=new FButton('OK'), cancelBtn=new FButton('Cancel')), TablePane.ALIGN_RIGHT, 2);
			
			setSizeWH(500, 350);
			AsWingUtils.centerLocate(this);
			
			load();
			okBtn.addActionListener(function(e:Event):void {
				save();
				dispose();
			});
			cancelBtn.addActionListener(function(e:Event):void {
				dispose();
			});
		}
		
		
		private function save():void
		{
			var so:SharedObject = SharedObject.getLocal('build');
			
			if (!so.data.copyFiles) so.data.copyFiles = {};
			
			var o:Object = {};
			so.data.copyFiles[project.path] = o;
			
			for each (var cb:JCheckBox in cbList)
				if (cb.isSelected())
					o[cb.getText()] = destTxt.getText();
			so.flush();
		}
		
		
		private function load():void
		{
			var so:SharedObject = SharedObject.getLocal('build');
			
			if (!so.data.copyFiles) so.data.copyFiles = {};
			
			var o:Object = so.data.copyFiles[project.path];
			if (!o) return;
			
			
			for (var n:String in o)
			{
				for each (var cb:JCheckBox in cbList)
				{
					if (cb.getText() == n)
						cb.setSelected(true);
				}
			}
			if (n)
				destTxt.setText(o[n]);
		}
	}
}
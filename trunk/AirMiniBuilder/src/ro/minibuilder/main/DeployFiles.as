/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main
{
	import __AS3__.vec.Vector;
	
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
	
	public class DeployFiles extends Frame
	{
		
		private var cbList:Vector.<JCheckBox>;
		private var destTxt:JTextField;
		private var project:IProjectPlug;
		
		public function DeployFiles(project:IProjectPlug)
		{
			super(null, 'Build settings', true);
			
			this.project = project;
			
			var pane:TablePane = new TablePane(1);
			setContentPane(pane);
			
			pane.newRow();
			pane.addLabel('Deploy (copy) output files after compilation.', 136, 2);
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

			addOKCancel(pane);
			
			setSizeAndCenter(500, 350);
			
			load();
		}
		
		
		override protected function okClick(e:Event=null):void
		{
			var so:SharedObject = SharedObject.getLocal('build');
			
			if (!so.data.copyFiles) so.data.copyFiles = {};
			
			var o:Object = {};
			so.data.copyFiles[project.path] = o;
			
			for each (var cb:JCheckBox in cbList)
				if (cb.isSelected())
					o[cb.getText()] = destTxt.getText();
			so.flush();
			
			super.okClick();
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
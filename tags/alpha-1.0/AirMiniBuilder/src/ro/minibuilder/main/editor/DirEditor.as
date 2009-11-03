/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.main.editor
{
	import flash.events.Event;
	import flash.system.Capabilities;
	
	import org.aswing.AsWingConstants;
	import org.aswing.FlowLayout;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.ext.Form;
	
	import ro.mbaswing.FButton;
	import ro.minibuilder.main.ActionManager;
	import ro.minibuilder.main.Skins;
	
	public class DirEditor extends JPanel implements IEditor
	{
		private var path:String;
		
		
		public function get filePath():String
		{
			return path;
		}
		
		public function set filePath(path:String):void
		{
			this.path = path;
		}
		
		public function openDir(rootPath:String):void
		{
			removeAll();
			setLayout(new FlowLayout);
			setAlignmentY(AsWingConstants.TOP);
			getParent().setAlignmentY(AsWingConstants.TOP);
			getParent().getParent().setAlignmentY(AsWingConstants.TOP);
			
			var form:Form = new Form;
			form.setAlignmentY(AsWingConstants.TOP);
			
			
			var lbl:JLabel;
			var fullpath:String = rootPath + path;
			if (/desktop/i.test(Capabilities.playerType) && /windows/i.test(Capabilities.os))
				fullpath = fullpath.split('/').join('\\');
			
			form.addRow(form.createLeftLabel('Location:'), lbl = new JLabel(fullpath));
			lbl.setSelectable(true);
			
			var pan:JPanel;
			var btn:JButton;
			
			pan = new JPanel(new FlowLayout);
			pan.append(btn = new FButton('Open'));
			btn.setToolTipText('Open in system file explorer');
			btn.addActionListener(function():void {
				ActionManager.inst.doNativeOpen();
			});
			form.addRow(form.createLeftLabel('Open:'), pan);
			
			pan = new JPanel(new FlowLayout);
			pan.append(btn = new FButton('Refresh'));
			btn.addActionListener(function():void {
				ActionManager.inst.doRefreshProject();
			});
			form.addRow(form.createLeftLabel('Refresh:'), pan);
			
			pan = new JPanel(new FlowLayout);
			pan.append(btn = new FButton('Package', Skins.icnFolder()));
			btn.setToolTipText('New package or directory');
			btn.addActionListener(function(e:Event):void {
				ActionManager.inst.doAddPackage();
			});
			
			pan.append(btn = new FButton('Class', Skins.icnAS()));
			btn.setToolTipText('New flass in this package');
			btn.addActionListener(function(e:Event):void {
				ActionManager.inst.doAddClass();
			});
			
			pan.append(btn = new FButton('Function', Skins.icnAS()));
			btn.setToolTipText('New function in this package');
			form.addRow(form.createLeftLabel('New:'), pan);
			btn.addActionListener(function(e:Event):void {
				ActionManager.inst.doAddFunction();
			});
			
			append(form);
		}
		
		public function get status():String
		{
			return 'directory';
		}
		
		public function get percentReady():Number
		{
			return 1;
		}
		
		public function get changed():Boolean
		{
			return false;
		}
	}
}
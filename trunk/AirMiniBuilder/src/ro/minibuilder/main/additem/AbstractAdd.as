/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main.additem
{
	import flash.events.Event;
	
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.IProjectPlug;
	import ro.minibuilder.main.ActionManager;
	
	public class AbstractAdd extends JFrame
	{
		public var nameTxt:JTextField;
		private var okBtn:JButton;
		private var cancelBtn:JButton;
		private var duplicateLbl:JLabel;
		private var filterLbl:JLabel;
		private var locationLbl:JLabel;
				
		protected var project:IProjectPlug;
		protected var path:String;
		
		protected var label:JLabel;
		protected var template:String;
		protected var regex:RegExp;
		
		public function AbstractAdd()
		{
			super(null, 'Add Class', true);
			
			var pane:TablePane = new TablePane;
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			setContentPane(pane);
			setSizeWH(400, 250);
			AsWingUtils.centerLocate(this);
			
			pane.setColWidths(0, '*');
			
			pane.newRow();
			label = pane.addLabel('Class Name');
			pane.addCell(nameTxt = new JTextField);
			
			pane.newRow();
			pane.addLabel('Filter');
			filterLbl = pane.addLabel('');
			
			pane.newRow();
			pane.addLabel('File');
			locationLbl = pane.addLabel('');
			
			pane.newRow();
			pane.addCell(null);
			duplicateLbl = pane.addLabel('duplicate');
			duplicateLbl.visible = false;
			
			pane.newRow(true);
			pane.addCell(null);
			
			pane.addSeparatorRow();
			
			pane.newRow();
			pane.addCell(TablePane.hBox(5, okBtn=new FButton('OK'), cancelBtn=new FButton('Cancel')), TablePane.ALIGN_RIGHT, 2);
			
			setDefaultButton(okBtn);
			
			//-----------------------------------
			okBtn.setEnabled(false);
			
			nameTxt.addEventListener(Event.CHANGE, onChange);
			
			cancelBtn.addActionListener(function(e:Event):void {
				dispose();
			});
			
			okBtn.addActionListener(_doAction);
		}
		
		internal function init(project:IProjectPlug, path:String):void
		{
			if (!project.isDirectory(path))
				path = path.substr(0, path.lastIndexOf('/'));

			this.project = project;
			this.path = path;
			
			show();
			nameTxt.selectAll();
			stage.focus = nameTxt.getTextField();
			filterLbl.setText(regex.source);
		}
		
		private function onChange(e:Event):void
		{
			locationLbl.setText(getFilePath());
			var duplicate:Boolean = project.listFiles().indexOf(getFilePath()) != -1;
			duplicateLbl.visible = duplicate;
			okBtn.setEnabled(regex.test(nameTxt.getText()) && !duplicate);
		}
		
		private function _doAction(e:Event=null):void
		{
			doAction();
			dispose();
		}
		
		protected function getFilePath():String
		{
			return path + '/' + nameTxt.getText() + '.as';
		}
		
		protected function doAction(e:Event=null):void
		{
			var file:String = getFilePath();
			var pack:String = path.substr(path.indexOf('/')+1).replace(/\//g, '.');
			var data:String = template
				.replace(/<name>/g, nameTxt.getText())
				.replace(/<package>/, pack);
			project.saveFile(file, data,
				function ():void {
					ActionManager.inst.doRefreshProject();
					ActionManager.inst.do_openFile(file);
				});
		}
	}
}
package ro.minibuilder.main.air.startupscreen
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import org.aswing.ButtonGroup;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JLabel;
	import org.aswing.JRadioButton;
	import org.aswing.JSpacer;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	import org.aswing.event.AWEvent;
	import org.aswing.geom.IntDimension;
	
	import ro.mbaswing.OptionPane;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.fileBased.wizzard.NewProjectWiz;
	import ro.minibuilder.main.air.MainWindow;
	
	public class NewProject extends TablePane
	{
		private static const description:Object = {
			player: 'SWF file that runs in Flash Player',
			air: 'Adobe AIR based application',
			avm: 'Executable based on Tamarin AVM2 (Tamarin)',
			server: 'Abc file to serve active web pages from a FastCGI/AVM capable WEB Server'
		};
		
		private var nameTxt:JTextField;
		private var packTxt:JTextField;
		private var parentTxt:JTextField;
		private var createBtn:JButton;
		
		private var descriptionLbl:JLabel;
		
		private var group:ButtonGroup;
		
		private var flexCb:JCheckBox;
		private var aswCb:JCheckBox;
		
		private var main:MainWindow;
		
		public function NewProject(main:MainWindow)
		{
			
			this.main = main;
			
			setColWidths(0, '*');
			
			
			//type
			group = new ButtonGroup;
			addOption('Flash Player AS3', 'player');
			addOption('Flash AIR AS3', 'air');
			addOption('Tamarin AVM2', 'avm');
			addOption('Server-side AS3 (experimental)', 'server');
			
			newRow();
			addLabel('Description:');
			descriptionLbl = addLabel(description['player'], 136, 2);
			
			newRow();
			addCell(new JSpacer(new IntDimension(1,5)));
			
			newRow();
			addCell(null);
			addCell(flexCb = new JCheckBox('Add (some) Flex Support'), TablePane.ALIGN_LEFT);
			
			newRow();
			addCell(null);
			addCell(aswCb = new JCheckBox('Add AsWing Support'), TablePane.ALIGN_LEFT);
			addCell(null);
			
			newRow();
			addCell(new JSpacer(new IntDimension(1,5)));
			
			
			//name
			nameTxt = new JTextField;
			newRow();
			addLabel('Project Name:');
			addCell(nameTxt);
			nameTxt.addEventListener(Event.CHANGE, function(e:Event):void {
				createBtn.setEnabled(/^[a-z]\w*$/i.test(nameTxt.getText()) > 0);
				if (createBtn.isEnabled())
					packTxt.setText('com.'+nameTxt.getText().toLowerCase());
			});
			
			//package
			packTxt = new JTextField;
			newRow();
			addLabel('Project package:');
			addCell(packTxt);
			
			//parent
			parentTxt = new JTextField;
			parentTxt.setPreferredWidth(200);
			
			var so:SharedObject = SharedObject.getLocal('newproject');
			parentTxt.setText(so.data.path ? so.data.path : File.userDirectory.resolvePath('minibuilder').nativePath);
			var btn:JButton = new JButton('Browse');
			btn.addActionListener(function():void {
				var file:File = new File(parentTxt.getText());
				file.browseForDirectory('New project parent folder');
				file.addEventListener(Event.SELECT, function(e:Event):void {
					parentTxt.setText(file.nativePath);
				})
			});
			
			newRow();
			addLabel('Parent Folder:');
			addCell(parentTxt)
			addCell(btn);
			
			newRow();
			addCell(null);
			var exampleCb:JCheckBox;
			addCell(exampleCb = new JCheckBox('Include example code'), TablePane.ALIGN_LEFT);
			exampleCb.setSelected(true);
			exampleCb.setEnabled(false);
			
			//empty space
			newRow(true);
			addCell(null);
			
			addSeparatorRow();
			
			//pane.addRow(pane.addSpacer());
			createBtn = new JButton('Create Project');
			createBtn.setEnabled(false);
			newRow();
			addCell(createBtn, TablePane.ALIGN_RIGHT, 3);
			
			createBtn.addActionListener(onOK);
			
			setBorder(new EmptyBorder(null, new Insets(20, 20, 20, 20)));
		}
		
		private function addOption(text:String, name:String):void
		{
			var rb:JRadioButton = new JRadioButton(text);
			group.append(rb);
			rb.setName(name);
			newRow();
			if (group.getButtonCount() == 1)
			{
				addLabel('Project Target:');
				rb.setSelected(true);//default first
			}
			else
				addCell(null);
			addCell(rb, TablePane.ALIGN_LEFT);
			rb.addActionListener(onAct);
		}
		
		private function onAct(e:AWEvent):void
		{
			var name:String = (e.target as JRadioButton).getName();
			descriptionLbl.setText(description[name]);
			var isFlash:Boolean = name == 'player' || name == 'air';
			if (!isFlash)
			{
				aswCb.setSelected(false);
				flexCb.setSelected(false);
			}
			aswCb.setEnabled(isFlash)
			flexCb.setEnabled(isFlash);
		}
		
		private function onOK(e:Event):void
		{
			var path:String = parentTxt.getText()+File.separator+nameTxt.getText();
			var wizz:NewProjectWiz = new NewProjectWiz(path, packTxt.getText());
			
			try {
				wizz.doCommon();
			} catch (e:Error) {
				OptionPane.showMessageDialog('Alert', 'Destination directory exists');
				return;
			}
			
			var name:String = group.getSelectedButton().getName();
			
			if (flexCb.isSelected())
				wizz.doFlex(name == 'air', aswCb.isSelected());
			else if (aswCb.isSelected())
				wizz.doAsWing(name == 'air');
			else if (name == 'player' || name =='air')
				wizz.doAS3(name == 'air')
			else if (name == 'server')
				wizz.doServer();
			else if (name == 'avm')
				wizz.doAVM();
			else
				throw new Error('unknown combination');
			
			nameTxt.setText('');
			packTxt.setText('');
			
			//save parent path
			var so:SharedObject = SharedObject.getLocal('newproject');
			so.data.path = parentTxt.getText();
			so.flush();
			
			main.newProjectWindow(path);
		}
		
	}
}
package ro.minibuilder.main
{
	import com.victordramba.console.debug;
	
	import flash.events.Event;
	
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JScrollPane;
	import org.aswing.JTextArea;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.Constants;
	import ro.minibuilder.data.IProjectPlug;
	
	public class AddLicense extends Frame
	{
		private var cancelBtn:JButton;
		private var okBtn:JButton;
		private var filterTxt:JTextField;
		private var titleTxt:JTextField;
		private var authorTxt:JTextField;
		private var yearTxt:JTextField;
		private var textTxt:JTextArea;
		
		private var project:IProjectPlug;
		private var text:String;
		
		private static var inst:AddLicense;
		
		public static function show(project:IProjectPlug):void
		{
			if (!inst) inst = new AddLicense();
			inst.project = project;
			inst.show();
		}
		
		public function AddLicense()
		{
			super(null, 'Add License Block', true);
			
			this.project = project;
			
			var pane:TablePane = new TablePane();
			pane.setColWidths(0, 200, '*');
			
			pane.newRow();
			pane.addCell(new JLabel('Add license block comment at the biginning of ' +
				'all source files in the project', null, JLabel.LEFT), 136, 3);
			
			pane.newRow();
			pane.addCell(new JLabel('File path filter:', null, JLabel.LEFT));
			pane.addCell(filterTxt = new JTextField('\\.(as|mxml)$'));
			pane.addCell(new JLabel('(regexp)', null, JLabel.LEFT));
			
			pane.newRow();
			pane.addCell(new JLabel('Application Title:', null, JLabel.LEFT));
			pane.addCell(titleTxt = new JTextField);
			pane.addCell(new JLabel('<appname>', null, JLabel.LEFT));
			
			pane.newRow();
			pane.addCell(new JLabel('Author:', null, JLabel.LEFT));
			pane.addCell(authorTxt = new JTextField);
			pane.addCell(new JLabel('<author>', null, JLabel.LEFT));
			
			pane.newRow();
			pane.addCell(new JLabel('Year:', null, JLabel.LEFT));
			pane.addCell(yearTxt = new JTextField(String(new Date().getFullYear())));
			pane.addCell(new JLabel('<year>', null, JLabel.LEFT));
			
			
			pane.newRow(true);
			pane.addCell(new JLabel('License text:', null, JLabel.LEFT), TablePane.ALIGN_TOP);
			textTxt = new JTextArea(Constants.GPL);
			textTxt.setWordWrap(true);
			pane.addCell(new JScrollPane(textTxt), 136, 2);

			pane.addSeparatorRow();
			
			pane.newRow();
			pane.addCell(TablePane.hBox(5, okBtn=new FButton('Procede'), cancelBtn=new FButton('Cancel')), 136, 3);
			
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			setContentPane(pane);
			
			setSizeAndCenter(550, 400);
			
			cancelBtn.addActionListener(function():void {
				dispose();
			});
			
			okBtn.addActionListener(procede);
		}
		
		private function procede(e:Event):void
		{
			var reg:RegExp = new RegExp(filterTxt.getText(), 'i');
			text = textTxt.getText()
				.replace(/<author>/g, authorTxt.getText())
				.replace(/<appname>/g, titleTxt.getText())
				.replace(/<year>/g, yearTxt.getText());
			
			for each (var fileName:String in project.listFiles())
			{
				if (reg.test(fileName))
				{
					debug(fileName);
					if (/xml$/i.test(fileName))
						doXMLFile(fileName);
					else
						doCodeFile(fileName);
				}
			}
				
			dispose();
		}
		
		private function doCodeFile(fileName:String):void
		{
			project.readTextFile(fileName, function(src:String):void {
				if (src.indexOf('/* license section') != 0)
				{
					project.saveFile(fileName, 
						'/* license section\n\n' + text + '*'+'/\n\n' + src);
				}
			});
		}
		
		private function doXMLFile(fileName:String):void
		{
			project.readTextFile(fileName, function(src:String):void 
			{
				src = src.replace(/\r\n?/g, '\n');
				var begin:int = src.indexOf('<?') == 0 ? src.indexOf('>')+2 : 0;
				var str0:String = '<!-- license section';
				if (src.indexOf(str0) != begin)
				{
					project.saveFile(fileName, 
						src.substr(0, begin) +
						str0 + '\n\n' + text + '-->\n' + src.substr(begin));
				}
			});
		}
	}
}
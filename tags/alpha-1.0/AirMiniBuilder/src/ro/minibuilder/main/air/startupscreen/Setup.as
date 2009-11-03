package ro.minibuilder.main.air.startupscreen
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JSpacer;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	import org.aswing.border.LineBorder;
	import org.aswing.ext.MultilineLabel;
	import org.aswing.geom.IntDimension;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.OptionPane;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.fileBased.SDKCompiler;
	
	public class Setup extends TablePane
	{
		private var checkPingPane:TablePane;
		
		public function Setup()
		{
			super(0);
			
			var msg:File = File.userDirectory.resolvePath('.mbcompiler/msg');
			if (!msg.exists)
				msg.createDirectory();
			
			var file:File = File.userDirectory.resolvePath('.mbcompiler/sdkpath');
			if (file.exists)
			{
				var str:FileStream = new FileStream;
				str.open(file, FileMode.READ);
				var path:String = str.readUTFBytes(str.bytesAvailable);
				str.close();
			}
			else path = '';
			
			
			
			newRow();
			
			var mlbl:MultilineLabel;
			
			mlbl = new MultilineLabel;
			mlbl.setWidth(400);
			mlbl.setHtmlText(
				'Thank you for choosing Flash MiniBilder!\n\n' +
				'In order to use the compiler, ' +
				'you need Flex SDK (3.*) and Java (6+)\n' +
				'There are limitations with Flex SDK 4 ' +
				'<a href="http://code.google.com/p/minibuilder/wiki/Installation"><u>more info</u></a>');
			newRow();
			addCell(mlbl);
			
			var pane1:JPanel;
			pane1 = new JPanel(new BorderLayout(5));
			pane1.append(new JLabel('SDK Path:'), BorderLayout.WEST);
			var pathTxt:JTextField = new JTextField(path);
			pane1.append(pathTxt, BorderLayout.CENTER);
			newRow();
			addCell(pane1); 
			
			newRow();
			var btn:JButton;
			addCell(btn = new FButton('Save'), TablePane.ALIGN_RIGHT);
			btn.addActionListener(function():void {
				
				if (new File(pathTxt.getText()).resolvePath('frameworks').isDirectory)
				{
					var str:FileStream = new FileStream;
					str.open(file, FileMode.WRITE);
					str.writeUTFBytes(pathTxt.getText());
					str.close();
				}
				else
				{
					OptionPane.showMessageDialog('Alert', 'No Flex SDK seems to be at this path\nPath not saved.');
				}
			});
			
			newRow();
			addCell(new JSpacer(new IntDimension(1, 20)));
			
			checkPingPane = new TablePane(0);
			var lbl:JLabel = new JLabel('MBCompiler does not seem to be running.', null, JLabel.LEFT);
			lbl.setBorder(new LineBorder(null, new ASColor(0xff0000, 1)));
			checkPingPane.addCell(lbl);
			
			checkPingPane.newRow();
			checkPingPane.addCell(btn = new FButton('Check again'), TablePane.ALIGN_RIGHT);
			btn.addActionListener(checkPing);
			
			newRow();
			addCell(checkPingPane);
			
			
			var startName:String = 'start'+(Capabilities.os.indexOf('Windows')==0 ? '.bat' : '');
			
			
			mlbl = new MultilineLabel();
			mlbl.setHtmlText(
				'\n\n(!)You need to have <b>MBCompiler</b> running when you use MiniBuilder. ' +
				'<u><a href="http://code.google.com/p/minibuilder/wiki/MBCompiler">more info</a></u>\n\n' + 
				File.applicationDirectory.resolvePath('MBCompiler/'+startName).nativePath+'\n');
			mlbl.setPreferredHeight(200);
			
			newRow();
			addCell(mlbl);
			
			setBorder(new EmptyBorder(null, new Insets(20, 20, 20, 20)));
		}
		
		public function checkPing(e:*=null):void
		{
			new SDKCompiler().pingCompiler(function(ok:Boolean):void {
				if (!ok) dispatchEvent(new Event('noPing'));
				checkPingPane.visible = !ok;
				//debug('ping '+ok);
			});
		}
		
	}
}
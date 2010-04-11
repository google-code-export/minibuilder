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

package ro.minibuilder.main.air
{
	import ro.minibuilder.main.ActionManager;
	import com.victordramba.console.debugReference;
	import flash.utils.setTimeout;
	import flash.net.navigateToURL;
	import org.aswing.JLabel;
	import org.aswing.JLabelButton;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import ro.minibuilder.data.Constants;
	import org.aswing.ext.MultilineLabel;
	import org.aswing.BorderLayout;
	import ro.minibuilder.data.fileBased.SDKCompiler;
	import ro.minibuilder.main.air.startupscreen.BriefSearch;
	import com.victordramba.console.debug;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
	import org.aswing.AsWingManager;
	import org.aswing.AssetBackground;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.JTabbedPane;
	import org.aswing.JTextField;
	import org.aswing.JWindow;
	import org.aswing.UIManager;
	import org.aswing.border.EmptyBorder;
	import org.aswing.skinbuilder.orange.OrangeLookAndFeel;
	
	import ro.mbaswing.*;
	import ro.minibuilder.main.Skins;
	import ro.minibuilder.main.air.startupscreen.NewProject;

	public class StartupScreen extends JWindow
	{
		
		private var main:MainWindow;
		private var tabbedPane:JTabbedPane;
		
		private var briefPane:BriefSearch;
		
		static public function start(main:MainWindow):void
		{
			AsWingManager.initAsStandard(main);
			UIManager.setLookAndFeel(new OrangeLookAndFeel);
			
			var w:StartupScreen = new StartupScreen;
			w.main = main;
			
			var stage:Stage = main.stage;
			
			w.init();
			stage.addEventListener(Event.RESIZE, function(e:Event):void {
				w.setSizeWH(stage.stageWidth, stage.stageHeight);
			});
			w.setSizeWH(stage.stageWidth, stage.stageHeight);
		}
		
		private function init():void
		{
			debug('init stage='+stage);
			debug(Capabilities.version);
			debugReference('action', ActionManager);
			
			getContentPane().setBorder(new EmptyBorder(null, new Insets(80, 20, 20, 20)));
			
			setBackgroundDecorator(new AssetBackground(Skins.topbar()));
			
			var rPane:JPanel = new JPanel(new BorderLayout);
			getContentPane().append(rPane);
			
			var pane:JTabbedPane = new JTabbedPane;
			tabbedPane = pane;
			rPane.append(pane);
			
			var notes:TablePane = new TablePane(1);
			notes.setPreferredHeight(50);
			var verLbl:JLabel = notes.addLabel("Latest version: loading...");
			var lnk:JLabelButton;
			notes.addCell(lnk = new JLabelButton("Project Page", Skins.icnAS(), JLabel.LEFT));
			lnk.addActionListener(function():void {
				navigateToURL(new URLRequest('http://minibuilder.googlecode.com/'));
			});
			notes.newRow();
			notes.addLabel("Installed version: " + Constants.VERSION);
			notes.addCell(noCompilerLnk = new JLabelButton("Compiler server not found! See how to install.", 
				Skins.icnDeny(), JLabel.LEFT));
			noCompilerLnk.visible = false;
			
			noCompilerLnk.addActionListener(function():void {
				navigateToURL(new URLRequest('http://code.google.com/p/minibuilder/wiki/JetMBCompiler'));
			});
			
			rPane.append(notes, BorderLayout.NORTH);
			
			var ld:URLLoader = new URLLoader;
			ld.addEventListener(Event.COMPLETE, function(e:Event):void {
				var xml:XML = XML(ld.data);
				verLbl.setText("Latest version: " + xml.version + " " + xml.version.@type);
			});
			ld.load(new URLRequest("http://minibuilder.googlecode.com/svn/trunk/AirMiniBuilder/version.xml"));
			
			//debugReference('screen', this);
			
			
			pane.appendTab(new NewProject(main), 'Create New Project');
			pane.appendTab(briefPane = new BriefSearch(main), 'Brief Search');
			pane.appendTab(makeBrowsePane(), 'Browse for Project');
			pane.appendTab(makeRecentPane(), 'Recent projects');
			//pane.appendTab(setupPane = new Setup, 'Setup');
			
			pane.addStateListener(function():void {
				var i:int = pane.getSelectedIndex();
				if (i == 1)
					briefPane.briefLookup();
				else if (i == 3)
					refreshRecent();
			});
			
			checkPing();
			
			show();
		}
		
		private var noCompilerLnk:JLabelButton;
		
		public function checkPing():void
		{
			SDKCompiler.pingCompiler(function(ok:*):void {
				noCompilerLnk.visible = !ok;
				if (!ok) setTimeout(checkPing, 1000);
			});
		}
		
		private function makeRecentPane():JPanel
		{
			var btn:JButton;
			var pane:TablePane = new TablePane(0);
			
			pane.newRow();
			pane.addLabel('Recently open projects');
			
			pane.newRow(true);
			pane.addCell(new JScrollPane(recentList = new JList));
			
			pane.addSeparatorRow();
			
			pane.newRow();
			pane.addCell(btn = new JButton('Delete history'), TablePane.ALIGN_LEFT);
			
			
			btn.addActionListener(function(e:Event):void {
				var so:SharedObject = SharedObject.getLocal('recent');
				for (var n:String in so.data) delete so.data[n];
				so.flush();
				recentList.setListData([]);
			});
			
			recentList.addSelectionListener(function(e:Event):void {
				if (recentList.getSelectedValue())
				{
					setTimeout(function():void {
						main.newProjectWindow(recentList.getSelectedValue());
						stage.nativeWindow.visible = false;
						recentList.setSelectedIndex(-1);
					}, 10);
				}
			});
			
			
			pane.setBorder(new EmptyBorder(null, new Insets(20, 20, 20, 20)));
			return pane;
		}
		private var recentList:JList;
		
		private function refreshRecent():void
		{
			var a:Array = [];
			var so:SharedObject = SharedObject.getLocal('recent');
			for (var n:String in so.data)
				a.push(n);
			a.sort();
			recentList.setListData(a);
		}
		
		
		
		private function makeBrowsePane():JPanel 
		{
			var btn:JButton;
			var btn2:JButton;
			var txt:JTextField;
			var pane:TablePane = new TablePane(1);
			
			pane.newRow();
			pane.addLabel('Open an existing project', 136, 3);
			
			pane.newRow();
			pane.addLabel('Path:');
			pane.addCell(txt = new JTextField);
			pane.addCell(btn = new FButton('Browse'));
			btn.addActionListener(function(e:Event):void {
				var file:File = File.userDirectory;
				file.browseForDirectory('Open Project');
				file.addEventListener(Event.SELECT, function(e:Event):void {
					txt.setText(file.nativePath);
					btn2.setEnabled(file.resolvePath('.actionScriptProperties').exists);
				});
			});
			
			pane.newRow(true);
			pane.addCell(null);
			
			pane.addSeparatorRow();
			pane.addCell(btn2 = new FButton('Open Project'), TablePane.ALIGN_RIGHT, 3);
			btn2.addActionListener(function(e:Event):void {
				main.newProjectWindow(txt.getText());
				stage.nativeWindow.visible = false;
			});
			btn2.setEnabled(false);
			
			pane.setBorder(new EmptyBorder(null, new Insets(20, 20, 20, 20)));
			return pane;
		}
		
		
	}
}
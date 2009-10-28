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
	import com.victordramba.console.debug;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
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
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.main.Skins;
	import ro.minibuilder.main.air.startupscreen.BriefSearch;
	import ro.minibuilder.main.air.startupscreen.NewProject;
	import ro.minibuilder.main.air.startupscreen.Setup;

	public class StartupScreen extends JWindow
	{
		
		private var main:MainWindow;
		private var tabbedPane:JTabbedPane;
		private var setupPane:Setup;
		
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
			
			getContentPane().setBorder(new EmptyBorder(null, new Insets(80, 20, 20, 20)));
			
			setBackgroundDecorator(new AssetBackground(Skins.topbar()));
			
			var pane:JTabbedPane = new JTabbedPane;
			tabbedPane = pane;
			getContentPane().append(pane);
			
			//debugReference('screen', this);
			
			pane.appendTab(new NewProject(main), 'Create New Project');
			pane.appendTab(briefPane = new BriefSearch(main), 'Brief Search');
			pane.appendTab(makeBrowsePane(), 'Browse for Project');
			pane.appendTab(makeRecentPane(), 'Recent projects');
			pane.appendTab(setupPane = new Setup, 'Setup');
			
			pane.addStateListener(function():void {
				var i:int = pane.getSelectedIndex();
				if (i == 1)
					briefPane.briefLookup();
				else if (i == 4)
					setupPane.checkPing();
				else if (i == 3)
					refreshRecent();
			});
			
			if (!File.userDirectory.resolvePath('.mbcompiler/sdkpath').exists)
				pane.setSelectedIndex(4);
			
			setupPane.checkPing();
			
			setupPane.addEventListener('noPing', function(e:Event):void {
				pane.setSelectedIndex(4, true);
			});
			
			show();
		}
		
		private function makeRecentPane():JPanel
		{
			var btn:JButton;
			var pane:TablePane = new TablePane(0);
			
			pane.newRow();
			pane.addLabel('Recently open projects');
			
			pane.newRow(true);
			pane.addCell(new JScrollPane(recentList = new JList));
			
			pane.newRow();
			pane.addCell(btn = new JButton('Delete history'), TablePane.ALIGN_LEFT);
			btn.addActionListener(function(e:Event):void {
				var so:SharedObject = SharedObject.getLocal('recent');
				for (var n:String in so.data) delete so.data[n];
				so.flush();
				recentList.setListData([]);
			});
			
			pane.addSeparatorRow();
			pane.addCell(btn = new FButton('Open Project'), TablePane.ALIGN_RIGHT);
			btn.addActionListener(function(e:Event):void {
				if (recentList.getSelectedValue())
					main.newProjectWindow(recentList.getSelectedValue());
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
			});
			btn2.setEnabled(false);
			
			pane.setBorder(new EmptyBorder(null, new Insets(20, 20, 20, 20)));
			return pane;
		}
		

		
		
		
	}
}
package ro.minibuilder.main.air.startupscreen
{
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JScrollPane;
	import org.aswing.JTextField;
	import org.aswing.MutableListModel;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.TablePane;
	import ro.minibuilder.main.Skins;
	import ro.minibuilder.main.air.MainWindow;
	
	public class BriefSearch extends TablePane
	{
		private var briefList:JList;
		private var briefListData:Array;
		private var briefLabel:JLabel;
		private var filterTxt:JTextField;
		
		public function BriefSearch(main:MainWindow)
		{
			setColWidths(0, '*');
			
			
			newRow();
			briefLabel = new JLabel('MiniBuilder is briefly inspecting your folders...', Skins.icnLoading(), JLabel.LEFT);
			addCell(briefLabel, 136, 2);
			
			newRow();
			addCell(new JLabel('These are the compatible projects found:', null, JLabel.LEFT), 136, 2);
			
			//list and filter
			newRow(true);
			addCell(new JScrollPane(briefList=new JList()), 136, 2);
			
			/*briefList.addEventListener(ListItemEvent.ITEM_DOUBLE_CLICK, function(e:ListItemEvent):void {
			debug('dbl click:'+e.getValue());
			main.newProjectWindow(e.getValue());
			});*/
			
			newRow();
			addCell(new JLabel('Filter'));
			filterTxt = new JTextField;
			filterTxt.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):void {
				if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN)
				{
					if (briefList.getSelectedIndex() == -1)
						briefList.setSelectedIndex(0);
					briefList.setSelectedIndex(
						Math.max(0, briefList.getSelectedIndex()+(e.keyCode==Keyboard.UP ? -1 : 1)));
					e.preventDefault();
				}
				if (e.keyCode == Keyboard.ENTER && briefList.getSelectedIndex() >= 0) {
					main.newProjectWindow(briefList.getSelectedValue());
				}
			});
			filterTxt.addEventListener(KeyboardEvent.KEY_UP, function (e:KeyboardEvent):void {
				var a:Array = briefListData.filter(filter);
				briefList.setListData(a);
			});
			addCell(filterTxt);
			
			var btn:JButton = new JButton('Open Project');
			newRow();
			addCell(btn, TablePane.ALIGN_RIGHT, 2);
			btn.addActionListener(function():void {
				if (briefList.getSelectedIndex() >= 0)
					main.newProjectWindow(briefList.getSelectedValue());
			});
			
			setBorder(new EmptyBorder(null, new Insets(20, 20, 20, 20)));
		}
		
		private function filter(item:*, ...rest):Boolean
		{
			return new RegExp(filterTxt.getText().replace(/\\/g,'\\\\'), 'i').test(item);
		}
		
		private function briefReady():void
		{
			briefLabel.setText('MiniBuilder has briefly inspected your folders.');
			briefLabel.setIcon(null);
		}
		
		
		public function briefLookup():void
		{
			if (briefListData) return;
			briefListData = [];
			briefQueue = [];
			briefQueue.push({dir:File.userDirectory, depth:3});
			recSearch();
		}
		
		private var briefQueue:Array;
		
		private function recSearch():void
		{
			if (briefQueue.length == 0)
			{
				briefReady();
				return;
			}
			var o:Object = briefQueue.pop();
			var dir:File = o.dir;
			var depth:int = o.depth;
			
			if (dir.resolvePath('.actionScriptProperties').exists)
			{
				if (filter(dir.nativePath))
					(briefList.getModel() as MutableListModel).insertElementAt(dir.nativePath, 0);
				briefListData.push(dir.nativePath);
			}
			
			//debug('search '+dir.nativePath);
			var max:int = 50;
			for each (var d:File in dir.getDirectoryListing())
			{
				if (d.name == 'AppData' || d.name=='.svn' || d.name.indexOf('.')==0 || d.isHidden) continue;
				if (dir.nativePath == File.userDirectory.nativePath && d.name == 'Music') continue;
				if (max-- > 0 && d.isDirectory && depth > 0)
				{
					briefQueue.push({dir:d, depth:depth-1});
				}
			}
			setTimeout(recSearch, 2);
		}
	}
}
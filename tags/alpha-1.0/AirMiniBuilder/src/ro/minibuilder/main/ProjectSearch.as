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

package ro.minibuilder.main
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.aswing.ASColor;
	import org.aswing.AsWingUtils;
	import org.aswing.BorderLayout;
	import org.aswing.Container;
	import org.aswing.Insets;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JScrollPane;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	
	public class ProjectSearch extends JFrame
	{
		private var list:JList;
		private static var history:Array = [];
				
		public function ProjectSearch(paths:Vector.<String>)
		{
			super(null, "In-Project Search", true);
			
			var pane:Container = getContentPane();
			
			pane.setLayout(new BorderLayout(0, 10));
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			
			var txt:JTextField = new JTextField;
			
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				stage.focus = txt;
			});
			
			var listData:Array;
			
			txt.addEventListener('change', function(e:Event):void {
				listData = [];
				for each (var path:String in paths)
					if ((new RegExp(txt.getText(), 'i').test(path)) && path.indexOf('.svn')==-1)
						listData.push(path);
				list.setListData(listData);
				if (listData.length)
					list.setSelectedIndex(0);
			});
			
			txt.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.keyCode == Keyboard.ESCAPE)
				{
					dispose();
				}
				else if (e.keyCode == Keyboard.ENTER)
				{
					var i:int = history.indexOf(list.getSelectedValue());
					if (i == -1)
						history.push(list.getSelectedValue());
					
					dispatchEvent(new Event('submit'));
					dispose();
				}
				else if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN)
				{
					e.preventDefault();
					var step:int = e.keyCode == Keyboard.UP ? -1 : 1;
					list.setSelectedIndex(Math.min(listData.length, Math.max(0, list.getSelectedIndex() + step)));
				}
			}, false, 100);
			
			pane.append(txt, BorderLayout.NORTH);
			list = new JList();
			list.setSelectionMode(JList.SINGLE_SELECTION);
			listData = history;
			list.setListData(history);
			if (history.length) list.setSelectedIndex(0);
			list.setBackground(new ASColor(0xffffff));
			pane.append(new JScrollPane(list), BorderLayout.CENTER);
			
			setSizeWH(400, 350);
			
			AsWingUtils.centerLocate(this);
		}
		
		public function get value():String
		{
			return list.getSelectedValue();
		}
	}
}
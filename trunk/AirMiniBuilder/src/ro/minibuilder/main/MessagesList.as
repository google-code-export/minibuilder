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
	import __AS3__.vec.Vector;
	
	import org.aswing.JList;
	import org.aswing.ListCellFactory;
	
	import ro.minibuilder.data.CompilerMessage;
	
	public class MessagesList extends JList
	{
		private var _messages:Vector.<CompilerMessage>;
		
		public function MessagesList(listData:*=null, cellFactory:ListCellFactory=null)
		{
			super(listData, cellFactory);
		}
		
		public function set messages(list:Vector.<CompilerMessage>):void
		{
			if (!list)
			{
				_messages = new Vector.<CompilerMessage>;
				setListData([]);
				return;
			}
			_messages = list;
			var a:Array = [];
			for each (var msg:CompilerMessage in list)
			{
				if (msg.level == 'info') continue;
				a.push(msg);
			}
			setListData(a);
		}
		
		public function get messages():Vector.<CompilerMessage>
		{
			return _messages;
		}
		
		public function get selectedMessage():CompilerMessage
		{
			return getSelectedValue();
		}
	}
}
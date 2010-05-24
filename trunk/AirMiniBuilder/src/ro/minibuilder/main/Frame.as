/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main
{
	import flash.events.Event;
	import ro.mbaswing.TablePane;
	import flash.system.Capabilities;
	import ro.mbaswing.FButton;
	import org.aswing.JPanel;
	import org.aswing.Insets;
	import org.aswing.border.EmptyBorder;
	import flash.filters.DropShadowFilter;
	
	import org.aswing.AsWingUtils;
	import org.aswing.JFrame;
	import org.aswing.Container;
	
	public class Frame extends JFrame
	{
		public function Frame(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			filters = [new DropShadowFilter(2, 45, 0, .3, 6, 6)];	
		}
		
		
		protected function setSizeAndCenter(w:int, h:int):void
		{
			getContentPane().setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));			
			setSizeWH(w, h);
			AsWingUtils.centerLocate(this);
		}
		
		protected var okBtn:FButton;
		protected var cancelBtn:FButton;
		
		public function addOKCancel(pane:TablePane, okLabel:String='OK', cancelLabel:String='Cancel', colspan:int=2):void
		{
			pane.addSeparatorRow();
			
			okBtn = new FButton(okLabel);
			cancelBtn = new FButton(cancelLabel);
			
			var box:Container;
			if (Capabilities.os.toLowerCase().indexOf('linux') != -1)
				box = TablePane.hBox(5, cancelBtn, okBtn);
			else
				box = TablePane.hBox(5, okBtn, cancelBtn);
			
			pane.addCell(box, TablePane.ALIGN_RIGHT, colspan);
			
			cancelBtn.addActionListener(cancelClick);
			okBtn.addActionListener(okClick);
		}
		
		protected function okClick(e:Event=null):void
		{
			dispose();
		}
		
		protected function cancelClick(e:Event = null):void
		{
			dispose();
		}
	}
}
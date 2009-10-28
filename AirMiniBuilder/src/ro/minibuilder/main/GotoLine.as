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
	import flash.utils.setTimeout;
	
	import org.aswing.AsWingUtils;
	import org.aswing.Box;
	import org.aswing.BoxLayout;
	import org.aswing.Insets;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JTextField;
	import org.aswing.border.EmptyBorder;
	
	public class GotoLine extends JFrame
	{
		private var txt:JTextField;
		public function GotoLine()
		{
			super(null, 'Goto Line', true);
			
			setResizable(false);
			
			var pane:Box = new Box(BoxLayout.Y_AXIS);
			getContentPane().append(pane);
			
			pane.append(new JLabel('Goto line number'));
			pane.append(txt = new JTextField);
			txt.setWidth(150);
			
			//pane.append(Box.createVerticalGlue());
			
			txt.addEventListener(KeyboardEvent.KEY_UP, function (e:KeyboardEvent):void {
				if (e.keyCode == Keyboard.ESCAPE)
					dispose();
				else if (e.keyCode == Keyboard.ENTER)
				{
					setTimeout(dispatchEvent, 10, new Event('submit'));
					dispose();
				}
			});
			
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			pack();
			
			AsWingUtils.centerLocate(this);
		}
		
		public function get value():int
		{
			return int(txt.getText());
		}
	}
}
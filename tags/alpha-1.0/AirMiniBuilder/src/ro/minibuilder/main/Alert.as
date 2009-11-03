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
	import org.aswing.AsWingConstants;
	import org.aswing.AsWingUtils;
	import org.aswing.BorderLayout;
	import org.aswing.Container;
	import org.aswing.FlowLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JPanel;
	import org.aswing.ext.MultilineLabel;
	
	public class Alert extends JFrame
	{
		public function Alert(text:String, onOK:Function=null, onCancel:Function=null)
		{
			super(null, 'Alert', true);
			
			var pane:Container = getContentPane();
			
			pane.setLayout(new BorderLayout(0, 10));
			var lbl:MultilineLabel = new MultilineLabel('', 3, 40);
			lbl.setHtmlText('<p align="center">'+text);
			pane.append(lbl, BorderLayout.CENTER);
			
			var fl:JPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
			var ok:JButton = new JButton('OK');
			ok.addActionListener(function():void {
				if (onOK != null) onOK();
				dispose();
			});
			var cancel:JButton = new JButton('Cancel');
			cancel.addActionListener(function():void {
				if (onCancel !=  null) onCancel();
				dispose();
			}); 
			fl.appendAll(ok, cancel);
			pane.append(fl, BorderLayout.SOUTH);
			
			pack();
			AsWingUtils.centerLocate(this);
			
		}
	}
}
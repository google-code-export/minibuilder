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
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JLabelButton;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;

	public class AboutDialog extends Frame
	{
		public function AboutDialog()
		{
			super(null, 'About MiniBuilder', true);
			
			var pane:TablePane = new TablePane(1);
			
			pane.newRow();
			pane.addLabel('Version:');
			pane.addLabel('1.0-alpha-4');
			
			pane.newRow();
			pane.addLabel('License and details:');
			
			var btn1:JLabelButton;
			pane.addCell(btn1 = new JLabelButton('open link'), TablePane.ALIGN_LEFT);
			btn1.addActionListener(function(e:Event):void {
				navigateToURL(new URLRequest('http://code.google.com/p/minibuilder/wiki/AboutMiniBuilder'));
			});
			
			pane.newRow(true);
			pane.addCell(null);
			
			pane.addSeparatorRow();
			
			pane.newRow();
			var btn:JButton;
			pane.addCell(btn = new FButton('Close'), TablePane.ALIGN_RIGHT, 2);
			btn.addActionListener(function(e:Event):void {
				dispose();
			});
			
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			
			setContentPane(pane);
			
			setSizeAndCenter(400, 200);
		}
	}
}
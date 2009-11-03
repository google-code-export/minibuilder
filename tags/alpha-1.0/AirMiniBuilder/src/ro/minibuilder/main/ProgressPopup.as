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
	import org.aswing.Container;
	import org.aswing.GridLayout;
	import org.aswing.Insets;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JProgressBar;
	import org.aswing.border.EmptyBorder;
	import org.aswing.geom.IntDimension;
	
	public class ProgressPopup extends JFrame
	{
		private var bar:JProgressBar;
		private var lbl:JLabel;
		
		public function ProgressPopup(title:String)
		{
			super();
			setTitle(title);
			//setLayout(new BorderLayout());
			var pane:Container = getContentPane();
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			pane.setLayout(new GridLayout(2, 1, 0, 10));
			pane.append(lbl = new JLabel(''));
			lbl.setHorizontalAlignment(AsWingConstants.LEFT);
			
			pane.append(bar = new JProgressBar);
			bar.setPreferredSize(new IntDimension(350, 12));
			//bar.setBorder(new EmptyBorder(null, new Insets(10)));
			pack();
			
			setClosable(false);
			setResizable(false);
			
			AsWingUtils.centerLocate(this);
		}
	
		public function update(progress:int, label:String):void
		{
			bar.setValue(progress);
			lbl.setText(label);
		}
	}
}
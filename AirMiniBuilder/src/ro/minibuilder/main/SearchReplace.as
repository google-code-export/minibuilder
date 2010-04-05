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
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import org.aswing.AsWingUtils;
	import org.aswing.BorderLayout;
	import org.aswing.Container;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JFrame;
	import org.aswing.JPanel;
	import org.aswing.JTextField;
	import org.aswing.SoftBoxLayout;
	import org.aswing.border.EmptyBorder;
	import org.aswing.ext.Form;
	
	public class SearchReplace extends Frame
	{
		private var replTxt:JTextField;
		private var srcTxt:JTextField;
		private var regexCk:JCheckBox;
		private var caseCk:JCheckBox;
		
		private static var inst:SearchReplace;
		public var action:String;
		private static var _replace:*;
		
		public var submit:Function;
		
		public static function getInst():SearchReplace
		{
			if (!inst) inst = new SearchReplace;
			return inst;
		}
		
		public function set search(val:*):void
		{
			if (val is String)
				srcTxt.setText(val);
			else if (val is RegExp)
			{
				srcTxt.setText((val as RegExp).source);
				regexCk.setSelected(true);
			}
			srcTxt.setSelection(0, srcTxt.getLength());
		}
		
		public function SearchReplace()
		{
			super(null, 'Search Replace', true);
			setResizable(false);
			
			var btn:JButton;
			
			var pane:Container = getContentPane();
			pane.setLayout(new BorderLayout(0, 0));
			pane.setBorder(new EmptyBorder(null, new Insets(10, 10, 10, 10)));
			
			var form:Form = new Form;
			srcTxt = new JTextField;
			form.addRow(form.createLeftLabel('Search:'), srcTxt);
			
			replTxt = new JTextField;
			if (_replace != null) this.replTxt.setText(_replace);
			form.addRow(form.createLeftLabel('Replace:'), replTxt);
			
			// form.addSeparator();
			
			form.addRow(null, form.flowLeftHold(0, regexCk = new JCheckBox('Use Regular Expressions')));
			form.addRow(null, form.flowLeftHold(0, caseCk = new JCheckBox('Case sensitive')));
			
			pane.append(form, BorderLayout.CENTER);
			
			var pan:JPanel;
			pan = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS, 3));

			pan.append(btn = new JButton('Search Next'));
			btn.addActionListener(function():void {
				dispatch('search');
			});
			setDefaultButton(btn);
			
			pan.append(btn = new JButton('Replace Next'));
			btn.addActionListener(function():void {
				dispatch('replace');
			});
			
			pan.append(btn = new JButton('Replace All'));
			btn.addActionListener(function():void {
				dispatch('replaceAll');
			});
			
			pan.append(btn = new JButton('Close'));
			btn.addActionListener(function():void {
				dispose();
			});

			
			pane.append(pan, BorderLayout.EAST);
			
			pack();
			setWidth(350);
			
			AsWingUtils.centerLocate(this);
			
			addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.keyCode == Keyboard.ESCAPE)
					dispose();
			});
		}
		
		
		private function dispatch(act:String):void
		{
			action = act;
			setTimeout(submit, 10);
			dispose();
		}
		
		public function get search():*
		{
			return this.regexCk.isSelected() ? new RegExp(srcTxt.getText(), 'g') : srcTxt.getText();
		}
		
		public function get replace():String
		{
			_replace = replTxt.getText();
			return _replace;
		}
		
		public function get ignoreCase():Boolean
		{
			return caseCk.isSelected();
		}
		
	}
}
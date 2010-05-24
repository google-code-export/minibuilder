/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main
{
	import com.victordramba.console.debug;
	import ro.minibuilder.main.air.Preferences;
	import flash.events.Event;
	import org.aswing.JButton;
	import org.aswing.JTextField;
	import org.aswing.AsWingUtils;
	import org.aswing.Insets;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.border.EmptyBorder;
	
	import ro.mbaswing.FButton;
	import ro.mbaswing.TablePane;
	import ro.minibuilder.data.Constants;
	import ro.victordramba.util.StringEx;

	public class KeyShortcutsPane extends Frame
	{
		public function KeyShortcutsPane()
		{
			super(null, 'Key Shortcuts', false);
			
			var pane:TablePane = new TablePane(1);
			setContentPane(pane);
			
			var map:Object = {};
			var xml:XML = Preferences.config.data['shortcuts'] as XML;
			if (!xml) xml = Constants.SHORTCUTS;
			
			
			for each (var n:XML in xml.key)
			{
				if (!map[n.@action]) map[n.@action] = [];
				var k:String = (n.@ctrl==1 ? 'CTRL+' : '') + (n.@shift==1 ? 'SHIFT+':'') + (n.@alt==1 ? 'ALT+':'') + n.@key;
				map[n.@action].push(k);
			}
			var a:Array = [];
			for (var act:String in map)
				a.push(act);
			a.sort();
					
			for each (act in a)
			{
				pane.newRow();
				pane.addCell(new JLabel(StringEx.ucFirst(act)), TablePane.ALIGN_LEFT);
				var txt:JTextField = new JTextField(map[act].join(', '));
				fields.push({txt:txt, act:act});
				pane.addCell(txt);
			}
			
			pane.newRow();
			var btn:FButton;
			pane.addCell(btn = new FButton('Reset all'), TablePane.ALIGN_RIGHT, 2);
			btn.addActionListener(function():void {
				delete Preferences.config.data['shortcuts'];
				dispose();
			});
			
			pane.newRow(true);
			pane.addCell(null);
			
			addOKCancel(pane, 'Save');
			
			setSizeAndCenter(500, 500);
		}
		
		private var fields:Array = [];
		
		override protected function okClick(e:Event=null):void
		{
			var xml:XML = <keys/>;
			for each (var o:Object in fields)
			{
				var txt:JTextField = o.txt;
				var str:String = txt.getText().toLowerCase();
				
				for each (var part:String in str.split(/ *, */g))
				{
					if (part.length == 0) continue;
					var n:XML = <key action={o.act}/>;
					var a:Array = part.split(/ *\+ */);
					for each(var s:String in a)
					{
						if ({shift:true, alt:true, ctrl:true}[s])
							n['@' + s.toLowerCase()] = '1';
						else
							n.@key = s.toUpperCase();
					}
					
					xml.appendChild(n);
				}
			}
			XML.prettyPrinting = true;
			debug(xml.toXMLString());
			
			Preferences.config.data['shortcuts'] = xml;
			KeyBindings.resetKeys();
			
			dispose();
		}
	}
}
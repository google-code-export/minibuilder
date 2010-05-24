/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main.air
{
	import ro.mbaswing.FButton;
	import org.aswing.JTextField;
	import flash.net.SharedObject;
	import flash.utils.clearTimeout;
	import flash.events.Event;
	import ro.minibuilder.main.Frame;
	import ro.minibuilder.data.fileBased.SDKCompiler;
	import flash.utils.setTimeout;
	import org.aswing.JLabel;
	import ro.mbaswing.TablePane;
	
	public class Preferences extends Frame
	{
		private var lbl1:JLabel;
		private var lbl2:JLabel;
		private var txt1:JTextField;
		
		private static var so:SharedObject;
		static public function get config():SharedObject
		{
			if (!so) 
				so = SharedObject.getLocal('configuration');
			return so;
		}
		
		public function Preferences()
		{
			setTitle('Preferences');
			var pane:TablePane = new TablePane(1);
			setContentPane(pane);
			
			pane.addLabel('Compilation Server:');
			lbl1 = pane.addLabel('detecting...');
			pane.newRow();
			pane.addLabel('Flex SDK location:');
			lbl2 = pane.addLabel('');
			
			pane.addSeparatorRow();
			
			pane.newRow();
			
			pane.addLabel('In order to work with AIR projects you need the Adobe AIR SDK', 
				TablePane.ALIGN_LEFT, 2);
			pane.newRow();
			pane.addLabel('AIR SDK path:');
			pane.addCell(txt1 = new JTextField(String(config.data.airsdk)));
			
			pane.addSeparatorRow();
			pane.newRow(true);
			pane.addCell(null);
			
			addOKCancel(pane);
			
			
			checkServer();
			var TID:int = setTimeout(checkServer, 500);
			
			addEventListener(Event.REMOVED_FROM_STAGE, function():void {
				clearTimeout(TID);
			});
			
			setSizeAndCenter(600, 400);
		}
		
		override protected function okClick(e:Event=null):void
		{
			config.data.airsdk = txt1.getText();
			config.flush();
			super.okClick();
		}
		
		private function checkServer():void
		{
			SDKCompiler.pingCompiler(function(path:String):void {
				lbl1.setText(path ? 'running ok' : 'not running!');
				lbl2.setText(path ? path : '?');
			});
		}
	}
}

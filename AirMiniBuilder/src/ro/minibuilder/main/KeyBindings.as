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
	import ro.minibuilder.main.air.Preferences;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import ro.minibuilder.data.Constants;
	import ro.victordramba.util.StringEx;

	public class KeyBindings
	{
		private static var keys:Object;
		
		public static function init(stage:Stage):void
		{
			resetKeys();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true, 100);
		}
		
		public static function resetKeys():void
		{
			var keysXML:XML = Preferences.config.data['shortcuts'] as XML;
			if (!keysXML) keysXML = Constants.SHORTCUTS;
			keys = {};
			for each (var n:XML in keysXML.key)
				keys[n.@key.toLowerCase()+(n.@ctrl==1?'1':'0')+(n.@shift==1?'1':'0')+(n.@alt==1?'1':'0')] = n.@action;
		}
		
		private static function onKeyDown(e:KeyboardEvent):void
		{
			var key:String;
			if (e.keyCode > 111 && e.keyCode < 124) //F1-F12
				key = 'f'+(e.keyCode-111);
			else
				key = String.fromCharCode(e.charCode).toLowerCase();
			
			var o:* = keys[key+(e.ctrlKey?'1':'0')+(e.shiftKey?'1':'0')+(e.altKey?'1':'0')];
			if (o)
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				ActionManager.inst['do'+StringEx.ucFirst(o)]();
			}
		}
	}
}
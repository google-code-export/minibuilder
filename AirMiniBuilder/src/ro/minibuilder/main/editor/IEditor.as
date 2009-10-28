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

package ro.minibuilder.main.editor
{
	public interface IEditor
	{
		function get filePath():String;
		function set filePath(path:String):void;
		function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeekReference:Boolean=false):void;
		
		function get status():String;
		function get percentReady():Number;
		function get changed():Boolean;
	}
}
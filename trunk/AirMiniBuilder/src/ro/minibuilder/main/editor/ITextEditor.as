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
	public interface ITextEditor extends IEditor
	{
		function gotoLine(line:int):void;
		function loadSource(source:String, fileName:String):void;
		function markLines(lines:Array/*of int*/, tips:Array/*of String*/):void;
		function saved():void;
		function search(pattern:*, backwards:Boolean=false):Boolean;
		function get text():String;
		function get selection():String;
		function setSelection(beginIndex:int, endIndex:int):void
	}
}
/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.swcparser.abc
{
	internal class TypeName extends Multiname_
	{
		public var types:Array;
		function TypeName(name:Multiname_, types:Array)
		{
			super(name.nsset, name.name);
			this.types = types;
		}
		
		override public function toString():String
		{
			var s : String = super.toString();
			s += ".<"
			for( var i:int = 0; i < types.length; ++i )
				s += types[i] != null ? types[i].toString() : "*" + " ";
			s += ">"
			return s;
		}
	}
}
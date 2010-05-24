/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.swcparser.abc
{
	import ro.minibuilder.asparser.Multiname;
	import ro.victordramba.util.HashMap;

	internal class Multiname_
	{
		public var nsset:Array/* of Namespace_*/
		public var name:String
		function Multiname_(nsset:Array, name:String)
		{
			this.nsset = nsset
			this.name = name
		}
		
		public function toString():String
		{
			/*if (nsset && nsset.length == 1)
			{
			var ns:Namespace_ = nsset[0];
			if (ns.type == 'private') return 'private ' + name;
			if (ns.type == 'protected') return 'protected ' + name;
			if (ns.name == '') return 'public ' + name;
			//else return '';
			}*/
			return '{' + nsset + '}::' + name
		}
		
		public function toMultiname():Multiname
		{
			var h:HashMap = new HashMap;
			if (nsset && nsset.length)
			{
				var ns:Namespace_;
				for each (ns in nsset)
				h.setValue(ns.name+'.*', ns.name+'.*');
			}
			return new Multiname(name, h);
		}
	}
}
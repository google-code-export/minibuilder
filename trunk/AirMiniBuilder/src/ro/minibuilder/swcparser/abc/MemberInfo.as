/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.swcparser.abc
{
	import ro.minibuilder.asparser.Field;
	import ro.minibuilder.asparser.TypeDB;

	internal class MemberInfo extends AbcConstants
	{
		public var id:int
		public var kind:int
		public var type:Multiname_ //var type or method return type
		public var name:Multiname_
		public var metadata:Array
		//abstract
		public function dump(abc:Abc, attr:String, typeDB:TypeDB):void { }    
		//abstract
		public function dbDump(typeDB:TypeDB):void { }
		
		//"var", "function", "function get", "function set", "class", "function", "const"
		public static var fieldKinds:Array = ["var", "function", "get", "set", "class", "function", "var"];
		//abstract
		public function createField():Field
		{
			var f:Field = new Field(null);
			f.fieldType = fieldKinds[kind];
			f.name = name.name;
			f.access = (name.nsset[0] as Namespace_).type;
			f.type = type.toMultiname();
			return f;
		}
	}
}
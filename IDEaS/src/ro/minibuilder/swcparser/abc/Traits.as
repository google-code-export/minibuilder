/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.swcparser.abc
{
	import __AS3__.vec.Vector;
	import ro.minibuilder.asparser.TypeDB;

	internal class Traits
	{
		public var name:Multiname_
		public var init:MethodInfo
		public var itraits:Traits
		public var base:Multiname_
		public var flags:int
		public var protectedNs:String
		public const interfaces:Array = []
		//public const names:Object = {}
		//public const slots:Array = []
		//public const methods:Array = []
		public const members:Vector.<MemberInfo> = new Vector.<MemberInfo>;
		
		public function toString():String
		{
			return String(name)
		}
		
		public function dump(abc:Abc, attr:String, typeDB:TypeDB):void
		{
			var i:int=0;
			for each (var m:MemberInfo in members)
			{
				//m.dump(abc, attr, typeDB)
				m.dbDump(typeDB);
			}
		}
	}
}
/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.swcparser.abc
{
	import ro.minibuilder.asparser.Field;
	import ro.minibuilder.asparser.TypeDB;

	internal class MethodInfo extends MemberInfo
	{
		public var method_id:int
		public var dumped:Boolean
		public var flags:int
		public var debugName:String
		public var paramTypes:Array
		public var paramNames:Array
		public var optionalValues:Array
		public var local_count:int
		public var max_scope:int
		public var max_stack:int
		public var code_length:uint
		//public var code:ByteArray
		public var activation:Traits
		
		public function toString():String
		{
			return format()
		}
		
		public function format():String
		{
			//var name:String = this.name ? this.name : "function"
			
			return name + "(" + paramTypes + "):" + type// + "\t/* disp_id=" + id + " method_id=" + method_id + " */"
		}
		
		override public function dump(abc:Abc, attr:String, typeDB:TypeDB):void
		{
			dumped = true
			//dumpPrint("")
			
			/*if (metadata) {
			for each (var md:MetaData in metadata)
			Abc.log(md)
			}*/
			
			var s:String = ""
			if (flags & NATIVE)
				s = "native "
			s += traitKinds[kind] + " "
			
			Abc.log(attr+s+' '+format())
			
			//if (code) ... dump ză code
		}
		
		override public function dbDump(typeDB:TypeDB):void
		{
			//we only do package level methods here
			var f:Field = createField();
			typeDB.addDefinition(name.nsset[0].name, f);
			//Abc.log('0 ' + name.nsset[0].name + f);
		}
		
		override public function createField():Field
		{
			var f:Field = super.createField();
			for (var i:int=0; i < paramTypes.length; i++)
			{
				var mn:Multiname_ = paramTypes[i];
				var name:String = paramNames[i];
				var param:Field = new Field('var', 0, name);
				param.type = mn.toMultiname();
				if (optionalValues && (i in optionalValues))
					param.defaultValue = optionalValues[i];
				f.params.setValue(param.name, param);
			}
			
			//has ...rest params
			if (flags & 0x04)
			{
				param = new Field('var', 0, 'rest');
				f.params.setValue(param.name, param);
				f.hasRestParams = true;
			}

			return f;
		}
	}
}
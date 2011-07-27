/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.data.fileBased.wizzard
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	public class AVM2Projector
	{
		public static function create(out:File, abc:ByteArray):void
		{
			var avm:File = File.applicationDirectory.resolvePath('templates/bin/' +
					(/windows/i.test(Capabilities.os) ? 'avmplus.exe' : 'avmplus_s'));
			
			var str:FileStream = new FileStream;
			str.open(avm, FileMode.READ);
			var avmb:ByteArray = new ByteArray;
			str.readBytes(avmb, 0, str.bytesAvailable);
			str.close();
			
			str.open(out, FileMode.WRITE);
			str.writeBytes(avmb, 0, avmb.length);
			str.writeBytes(abc, 0, abc.length);
			
			str.writeByte(0x56);
			str.writeByte(0x34);
			str.writeByte(0x12);
			str.writeByte(0xFA);
			str.writeByte(abc.length & 0xFF);
			str.writeByte((abc.length>>8) & 0xFF);
			str.writeByte((abc.length>>16) & 0xFF);
			str.writeByte((abc.length>>24) & 0xFF);
			
			str.close();
		}
	}
}

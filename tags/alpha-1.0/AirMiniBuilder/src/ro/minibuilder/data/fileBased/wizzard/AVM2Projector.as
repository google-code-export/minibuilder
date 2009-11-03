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

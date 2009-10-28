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

package ro.minibuilder.data.fileBased
{
	import com.victordramba.console.debug;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import ro.minibuilder.data.CompilerMessage;
	import ro.minibuilder.data.Constants;
	import ro.minibuilder.data.IProjectPlug;
	import ro.minibuilder.data.ProjectConfig;
	import ro.minibuilder.data.fileBased.wizzard.AVM2Projector;
	import ro.minibuilder.swcparser.SWFParser;
	
	[Event(name="complete",type="flash.events.Event")]

	public class SDKCompiler extends EventDispatcher
	{
		
		static public const MBC_DIR:File = File.userDirectory.resolvePath('.mbcompiler');

		private static var _sdkPath:String;
		private var targetConf:String;

		private var project:IProjectPlug;
		
		public function pingCompiler(onReady:Function):void
		{
			var file:File = File.createTempFile();
			doCmd(<command name="ping" log={file.nativePath}/>);
			
			var count:int = 3;
			var tid:int = setInterval(function():void {
				if (!file.exists || --count == 0)
				{
					clearInterval(tid);
					if (count == 0)
						file.deleteFileAsync();
					onReady(count != 0);//notify true on success
				}
			}, 50);
		}
		
		
		public function nativeOpenDir(path:String):void
		{
			var xml:XML = <command name="exec"/>;
			path = path.replace(/\//g, File.separator); 
			
			xml.@command = /windows/i.test(Capabilities.os) ?
				('explorer "' + path + '"') : 
				('nautilus file:' + path.replace(/ /g, '\\ '));
			doCmd(xml);
		}
		
		private function doCmd(cmd:XML, onReady:Function=null):void
		{
			writeFile(MBC_DIR.resolvePath('msg/command-' + (new Date().getTime()) + '.xml'), cmd.toXMLString(), onReady);
		}
		
		public static function get sdkPath():String
		{
			if (!_sdkPath)
			{
				var str:FileStream = new FileStream;
				str.open(MBC_DIR.resolvePath('sdkpath'), FileMode.READ);
				_sdkPath = str.readUTFBytes(str.bytesAvailable);
				str.close();
			}
			return _sdkPath;
		}
		
		
		public function compile(project:IProjectPlug):void
		{
			this.project = project;
			
			t0 = new Date().getTime();
			debug('Target:'+project.config.target);
			writeConfig();
		}
		
		private var t0:Number;
		public var duration:int;
		
		private function writeConfig():void
		{
			var config:XML = Constants.FLASH_CONFIG.copy();
			var path:String;
			for each (path in project.config.sourcePaths)
				config.compiler['source-path'].appendChild(<path-element>{absPath(path)}</path-element>);
			for each (path in project.config.libs)
				config.compiler['library-path'].appendChild(<path-element>{absPath(path)}</path-element>);
			for each (path in project.config.libsExtern)
				config.compiler['external-library-path'].appendChild(<path-element>{absPath(path)}</path-element>);
				
			var frameworkLibs:String = new File(sdkPath).resolvePath('frameworks/libs').nativePath.replace(/\\/g, '/');
			if (project.config.useFlex)
			{
				config.compiler['library-path'].appendChild(<path-element>{frameworkLibs}</path-element>);
				config.compiler['library-path'].appendChild(<path-element>{frameworkLibs}/../locale/en_US</path-element>);
			}
			
			//TARGET
			if (project.config.target == ProjectConfig.TARGET_AIR)
			{
				config.compiler['external-library-path'].appendChild(
					<path-element>{frameworkLibs}/air/airglobal.swc</path-element>);
			}
			else if(project.config.target == ProjectConfig.TARGET_PLAYER)
			{
				config.compiler['external-library-path'].appendChild(
					<path-element>{frameworkLibs}/player/10/playerglobal.swc</path-element>);
			}
				
			debug(config.toXMLString());
			//debug('app='+absPath(sourcePath[0] + File.separator + mainApp));
			//debug('sdk='+sdkPath);
			
			
			if (!configFile)
				configFile = File.createTempFile();
			
			var cstr:String = config.toXMLString();
			if (cstr == lastConfigStr)
				sendCompileCmd();
			else
			{
				//we keep old config if no changes
				lastConfigStr = cstr;
				writeFile(configFile, cstr, sendCompileCmd);
			}
		}
		
		private function sendCompileCmd():void 
		{
			var xml:XML = <command name="compile"/>;
			xml.@mainApplication = absPath(project.config.sourcePaths[0] + File.separator + project.config.mainApp);
			xml.@configFile = configFile.nativePath.replace(/\\/g, '/');
			xml.@log = logFile = File.createTempFile().nativePath;
			
			xml.@out = absPath('bin-debug');
			//debug(xml.toXMLString());
			doCmd(xml, pollProgress);
		}
		
		private static var logFile:String;
		private static var configFile:File;
		private static var lastConfigStr:String;
		
		private function absPath(path:String):String
		{
			path = path.replace('${DOCUMENTS}', '..');
			return new File(project.path).resolvePath(path).nativePath.replace(/\\/g, '/');
		}
		
		public var progress:int;
		private var lastPollSize:int = 0;
		
		private function pollProgress():void
		{
			var file:File = new File(logFile);
			if (!file.exists)
			{
				debug('file not here '+file.name);
				setTimeout(pollProgress, 100);
				return;
			}
			
			var str:FileStream = new FileStream;
			str.open(file, FileMode.READ);
			var text:String = str.readUTFBytes(str.bytesAvailable);
			
			if (text.indexOf('end-') == 0)
			{
				messages = new Vector.<CompilerMessage>;
				
				debug('end poll');
				debug('-----------------------------------');
				for each (var line:String in text.replace(/\r?\n/g, '\r').split('\r'))
				{
					if (/^-?\d+/.test(line))
					{
						var a:Array = line.split('|');
						var msg:CompilerMessage = new CompilerMessage;
						var i:int = 0;
						msg.code = a[i++];
						msg.line = a[i++];
						msg.col = a[i++];
						msg.level = a[i++];
						msg.path = a[i++];
						msg.message = a[i++];
						messages.push(msg);
					}
				}
				statusOK = text.indexOf('end-ok') == 0;
				if (statusOK)
					afterCompile();
				duration = new Date().getTime() - t0;
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			var mat:Array;
			var np:int;
			if (text.length < lastPollSize || !(mat=text.match(/^\d+/)) || (np=mat[0])<progress)
			{
				debug('<<<');
				debug(text);
			}
			else
			{
				lastPollSize = text.length;
				progress = np;
				dispatchEvent(new Event('progress'));
			}
			
			debug('progress='+progress);
			setTimeout(pollProgress, 100);
		}
		
		//TODO this should be moved in a configurable builders list
		private function afterCompile():void
		{
			if (project.config.extractAbc || project.config.createProjector)
			{
				var str:FileStream = new FileStream;
				str.open(new File(project.path).resolvePath('bin-debug/'+project.config.appName+'.swf'), FileMode.READ);
				var ba:ByteArray = new ByteArray;
				str.readBytes(ba, 0, str.bytesAvailable);
				str.close();
				SWFParser.parse(ba, true);
				str.open(new File(project.path).resolvePath('bin-debug/'+project.config.appName+'.abc'), FileMode.WRITE);
				str.writeBytes(SWFParser.abcs[0], 0, SWFParser.abcs[0].length);
				str.close();
			}
			if (project.config.createProjector)
			{
				AVM2Projector.create(new File(project.path).resolvePath('bin-debug/'+project.config.appName+'.exe'),
					SWFParser.abcs[0]);
			}
			
			//copy output files
			var so:SharedObject = SharedObject.getLocal('build');
			if (!so.data.copyFiles) so.data.copyFiles = {};
			var o:Object = so.data.copyFiles[project.path];
			if (o)
			{
				for (var n:String in o)
				{
					if (!o[n]) continue;
					var src:File = new File(project.path).resolvePath('bin-debug/'+n);
					var dest:File = new File(o[n]);
					if (dest.isDirectory)
						src.copyTo(dest.resolvePath(src.name), true);
					else
						src.copyTo(dest, true);
				}
			}
			
		}
		
		public var statusOK:Boolean;
		
		public var messages:Vector.<CompilerMessage>;
		
		private function writeFile(file:File, data:String, onReady:Function=null):void
		{
			var str:FileStream = new FileStream;
			str.open(file, FileMode.WRITE);
			str.writeUTFBytes(data);
			str.close();
			if (onReady!=null) onReady();
		}
	}
}

/*
1. read project config: source paths, libs, main app
2. write config file
3. start compilation
4. show progress
5. show results
*/
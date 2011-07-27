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
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import __AS3__.vec.Vector;
	
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
		static private const MBC_URL:String = 'http://localhost:8564/JetMBCompiler/';
		
		private static var logFile:String;
		private static var lastConfigStr:String;
		private static var _sdkPath:String;

		public var statusOK:Boolean;
		public var messages:Vector.<CompilerMessage>;
		public var duration:int;
		public var progress:int;
		
		private var lastPollSize:int = 0;
		private var t0:Number;
		private var targetConf:String;
		private var project:IProjectPlug;
		
		/** function onReady(isRunning:String):void */
		public static function pingCompiler(onReady:Function):void
		{
			var ld:URLLoader = new URLLoader;
			ld.addEventListener(Event.COMPLETE, function():void {
				onReady(ld.data);
			});
			ld.addEventListener(IOErrorEvent.IO_ERROR, function():void {
				onReady(null);
			});
			ld.load(new URLRequest(MBC_URL+"?path=1"));
		}
		
		
		public function nativeOpenDir(path:String):void
		{
			executeNative(
				/windows/i.test(Capabilities.os) ? 'explorer' : 'nautilus',
				[path.replace(/\//g, File.separator)]);
		}
		
		public function executeNative(cmd:String, args:Array, onReady:Function=null):void
		{
			var xml:XML = <command name="exec"/>;
			xml.@command = cmd;
			for each (var arg:String in args)
				xml.appendChild(<arg>{arg}</arg>);
			doCmd(xml, onReady);
		}
		
		/**
		 * function onProgress(percentReady:Number):void
		 * function onReady(data:String):void
		 */
		private function doCmd(cmd:XML, onReady:Function=null, onProgress:Function=null):void
		{
			cmd.@id = generateUID();
			var ld:URLLoader = new URLLoader;
			if (onReady != null) 
			{
				ld.addEventListener(Event.COMPLETE, function(e:Event):void {
					getLog(cmd.@id, onReady);
				});
			}
			if (onProgress != null)
			{
				ld.addEventListener(ProgressEvent.PROGRESS, function (e:Event):void {
					onProgress(ld.bytesLoaded / ld.bytesTotal);
				});
			}
			var rq:URLRequest = new URLRequest(MBC_URL);
			rq.method = 'post';
			rq.contentType = 'application/xml';
			rq.data = cmd.toXMLString();
			ld.load(rq);
		}
		
		private function getLog(id:String, onReady:Function):void
		{
			var ld:URLLoader = new URLLoader;
			ld.addEventListener(Event.COMPLETE, function(e:Event):void {
				onReady(ld.data);
			});
			ld.load(new URLRequest(MBC_URL + '?log=' + id));
		}
		
		
		//generate world-unique ID
		public function generateUID():String
		{
			var d:Date = new Date;
			var s:String = d.getTime()+''+d.getMilliseconds();
			s = Number(s.substr(0,8)).toString(36) + Number(s.substr(8)).toString(36);
			return s + Math.ceil(Math.random()*60466176).toString(36);
		}		
		
		public static function getSDKFile(url:String, onReady:Function):void
		{
			debug('get sdk file: '+url);
			var ld:URLLoader = new URLLoader;
			var rq:URLRequest = new URLRequest(MBC_URL);
			rq.data = new URLVariables;
			rq.data.file = url.substr('sdk://'.length);
			ld.dataFormat = URLLoaderDataFormat.BINARY;
			ld.addEventListener(Event.COMPLETE, function(e:Event):void {
				debug(ld.data.length);
				onReady(ld.data);
			});
			ld.load(rq);
		}
		
		private function createConfig():XML
		{
			var config:XML = Constants.FLASH_CONFIG.copy();
			
			config['target-player'] = project.config.targetPlayerVersion;
			
			var path:String;
			for each (path in project.config.sourcePaths)
				config.compiler['source-path'].appendChild(<path-element>{absPath(path)}</path-element>);
			for each (path in project.config.libs)
				config.compiler['library-path'].appendChild(<path-element>{absPath(path)}</path-element>);
			for each (path in project.config.libsExtern)
				config.compiler['external-library-path'].appendChild(<path-element>{absPath(path)}</path-element>);
				
			if (project.config.useFlex)
			{
				config.compiler['library-path'].appendChild(<path-element>$sdk/frameworks/libs</path-element>);
				config.compiler['library-path'].appendChild(<path-element>$sdk/frameworks/locale/en_US</path-element>);
			}
			else
				config.compiler['library-path'].appendChild(<path-element>$sdk/frameworks/libs/flex.swc</path-element>);
			
			//TARGET
			if (project.config.target == ProjectConfig.TARGET_AIR)
			{
				config.compiler['external-library-path'].appendChild(
					<path-element>$sdk/frameworks/libs/air/airglobal.swc</path-element>);
			}
			else if(project.config.target == ProjectConfig.TARGET_PLAYER)
			{
				config.compiler['external-library-path'].appendChild(
					<path-element>$sdk/frameworks/libs/player/10/playerglobal.swc</path-element>);
			}
				
			//debug(config.toXMLString());
			//debug('app='+absPath(sourcePath[0] + File.separator + mainApp));
			//debug('sdk='+sdkPath);
			return config;
		}
		
		
		public function compile(project:IProjectPlug):void
		{
			this.project = project;
			
			t0 = new Date().getTime();
			debug('Target:'+project.config.target);
			
			//create command
			var xml:XML = <command name="compile"/>;
			xml.@mainApplication = absPath(project.config.sourcePaths[0] + File.separator + project.config.mainApp);
			xml.config = createConfig().toXMLString();
			xml.@log = logFile = File.createTempFile().nativePath;
			
			xml.@out = absPath('bin-debug');
			//debug(xml.toXMLString());
			doCmd(xml, 
				function(compileLog:String):void {
					decodeMessages(compileLog);
					duration = new Date().getTime() - t0;
					dispatchEvent(new Event(Event.COMPLETE));
					
					//TODO check if we have errors
					afterCompile();
				},
				function(percent:Number):void {
					progress = percent * 100;
					dispatchEvent(new Event('progress'));
				});
		}
		
		
		private function absPath(path:String):String
		{
			path = path.replace('${DOCUMENTS}', '..');
			return new File(project.path).resolvePath(path).nativePath.replace(/\\/g, '/');
		}
		
		private function decodeMessages(text:String):void
		{
			statusOK = false;
			messages = new Vector.<CompilerMessage>;
			for each (var line:String in text.replace(/\r?\n/g, '\r').split('\r'))
			{
				if (line.indexOf('compile-ok') == 0) statusOK = true;
				var a:Array = line.split('|');
				if (a.length < 5) continue;
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

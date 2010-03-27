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

package ro.minibuilder.data.fileBased.wizzard
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import ro.minibuilder.data.ProjectConfig;

	public class NewProjectWiz
	{
		private var pathDir:File;
		private var name:String;
		private var pack:String;
		private var packDir:File;
		
		private var config:ProjectConfig;
		
		public function NewProjectWiz(path:String, pack:String)
		{
			pathDir = new File(path);
			name = pathDir.name;
			this.pack = pack;
		}
		
		public function doCommon():void
		{
			if (pathDir.exists)
				throw new Error('Target directory exists');
			
			pathDir.createDirectory();
			pathDir.resolvePath('src').createDirectory();
			pathDir.resolvePath('libs').createDirectory();
			pathDir.resolvePath('libs-extern').createDirectory();
			pathDir.resolvePath('bin-debug').createDirectory();
			packDir = pathDir.resolvePath('src/' + pack.split('.').join('/'));
			packDir.createDirectory();
			
			config = new ProjectConfig;
		}
		
		private function fileFromTemplate(tplName:String, params:Object, dest:File):void
		{
			var tpl:File = File.applicationDirectory.resolvePath('templates/' + tplName);
			var str:FileStream = new FileStream;
			str.open(tpl, FileMode.READ);
			var source:String = str.readUTFBytes(str.bytesAvailable);
			for (var name:String in params)
			{
				var re:RegExp = new RegExp('\\$\\{'+name+'\\}', 'g');
				source = source.replace(re, params[name]);
			}
			str.close();
			str.open(dest, FileMode.WRITE);
			str.writeUTFBytes(source);
			str.close();
		}
		
		private function doASProps():void
		{
			var str:FileStream = new FileStream;
			str.open(File.applicationDirectory.resolvePath('templates/asprops.tpl'), FileMode.READ);
			var xml:XML = XML(str.readUTFBytes(str.bytesAvailable));
			str.close();
			config.doTemplate(xml);
			str.open(pathDir.resolvePath('.actionScriptProperties'), FileMode.WRITE);
			str.writeUTFBytes(xml.toXMLString());
			str.close();
		}
		
		//flex player, air
		public function doFlex(isAir:Boolean, addAswing:Boolean):void
		{
			fileFromTemplate('flex-appclass.tpl', {PACKAGE:pack}, packDir.resolvePath('Application.as'));
			fileFromTemplate('flex-startfile.tpl', {PACKAGE:pack}, pathDir.resolvePath('src/'+name+'.mxml'));
			
			config.target = isAir ? ProjectConfig.TARGET_AIR : ProjectConfig.TARGET_PLAYER;
			if (isAir) doAIRApp();
			config.useFlex = true;
			config.mainApp = name + '.mxml';
			
			if(addAswing)
			{
				addLib('AsWing', false);
				addLib('OrangeLAF', false);
			}
			addLib('DebuggerConsole', false);
			
			doFinal();
		}
		
		
		//as3 player, air
		public function doAS3(isAir:Boolean):void
		{
			fileFromTemplate('as3-appclass.tpl', {PACKAGE:pack}, packDir.resolvePath('Application.as'));
			fileFromTemplate('as3-startfile.tpl', {PACKAGE:pack, APP_NAME:name}, pathDir.resolvePath('src/'+name+'.as'));
			
			config.target = isAir ? ProjectConfig.TARGET_AIR : ProjectConfig.TARGET_PLAYER;
			if (isAir) doAIRApp();
			config.mainApp = name + '.as';
			addLib('DebuggerConsole', false);
			doFinal();
		}
		
		public function doServer():void
		{
			fileFromTemplate('modas/FileUpload.as.tpl', {PACKAGE:pack}, packDir.resolvePath('FileUpload.as'));
			fileFromTemplate('modas/Form.as.tpl', {PACKAGE:pack}, packDir.resolvePath('Form.as'));
			fileFromTemplate('modas/Helo.as.tpl', {PACKAGE:pack}, packDir.resolvePath('Helo.as'));
			fileFromTemplate('modas/Home.as.tpl', {PACKAGE:pack}, packDir.resolvePath('Home.as'));
			fileFromTemplate('modas/Tal.as.tpl', {PACKAGE:pack}, packDir.resolvePath('Tal.as'));
			fileFromTemplate('modas/Main.as.tpl', {PACKAGE:pack}, pathDir.resolvePath('src/Main.as'));
			
			//addLib('modas/builtin', true, 'builtin');
			addLib('modas/ModASNative', true, 'ModASNative');
			addLib('modas/ModASLib', false, 'ModASLib');
			
			config.target = ProjectConfig.TARGET_OTHER;
			config.extractAbc = true;
			config.mainApp = 'Main.as';
			doFinal();
		}
		
		public function doAVM():void
		{
			fileFromTemplate('avm-appclass.tpl', {PACKAGE:pack}, packDir.resolvePath('Application.as'));
			fileFromTemplate('avm-startfile.tpl', {PACKAGE:pack, APP_NAME:name}, pathDir.resolvePath('src/'+name+'.as'));
			fileFromTemplate('avm-helper.tpl', {APP_NAME:name}, pathDir.resolvePath('src/Starter.as'));
			config.target = ProjectConfig.TARGET_OTHER;
			config.mainApp = name + '.as';
			config.createProjector = true;
			
			addLib('shell_toplevel', true);
			doFinal();
		}
		
		public function doAsWing(isAir:Boolean):void
		{
			fileFromTemplate('as3-startfile.tpl', {PACKAGE:pack, APP_NAME:name}, pathDir.resolvePath('src/'+name+'.as'));
			fileFromTemplate('aswing-appclass.tpl', {PACKAGE:pack}, packDir.resolvePath('Application.as'));
			
			if (isAir) doAIRApp();
			
			config.target = isAir ? ProjectConfig.TARGET_AIR : ProjectConfig.TARGET_PLAYER;
			config.mainApp = name + '.as';
			
			addLib('AsWing', false);
			addLib('OrangeLAF', false);
			addLib('MBAsWingEx', false);
			addLib('DebuggerConsole', false);
			doFinal();
		}
		
		private function doAIRApp():void
		{
			fileFromTemplate('air-app-xml.tpl', {APP_NAME:name}, pathDir.resolvePath('bin-debug/'+name+'-app.xml'));
		}
		
		private function addLib(lib:String, extern:Boolean, destName:String=null):void
		{
			File.applicationDirectory.resolvePath('templates/libs/'+lib+'.swc.tpl')
				.copyTo(pathDir.resolvePath('libs'+(extern?'-extern/':'/')+(destName ? destName : lib)+'.swc'));
		}
		
		private function doFinal():void
		{
			fileFromTemplate('eclipse-project.tpl', {
				APP_NAME:name, 
				FLEX: config.useFlex ? '<nature>com.adobe.flexbuilder.project.flexnature</nature>' : ''
			}, pathDir.resolvePath('.project'));
			
			doASProps();
		}
	}
}
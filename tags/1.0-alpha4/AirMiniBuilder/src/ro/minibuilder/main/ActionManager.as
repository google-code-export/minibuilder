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

package ro.minibuilder.main
{
	import com.victordramba.console.debug;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import ro.minibuilder.data.fileBased.SDKCompiler;
	import ro.minibuilder.main.additem.AddClass;
	import ro.minibuilder.main.additem.AddFunction;
	import ro.minibuilder.main.additem.AddPackage;
	import ro.minibuilder.main.air.MainWindow;

	/**
	 * We need to split this class to prepare it to work web-based
	 * for now, to be quick, we keep it simple
	 */
	public class ActionManager
	{
		private var win:ProjectWindow;
		private var main:MainWindow;
		
		public static var inst:ActionManager;
		
		public function ActionManager(main:MainWindow)
		{
			this.main = main;
			win = main.pwin;
			inst = this;
		}
		
		public function doShowStartup():void
		{
			for each (var nw:NativeWindow in NativeApplication.nativeApplication.openedWindows)
				if (nw.stage.getChildAt(0)['windowID'] == 'main')
				{
					nw.stage.getChildAt(0)['showStartupScreen']();
					break;
				}
		}
		
		public function doCloseProject():void
		{
			main.closeWindow();
		}
		
		public function doSave():void
		{
			win.saveCrtFile();
		}
		
		public function doSaveAll():void
		{
			win.saveAll();
		}
		
		public function doCompile():void
		{
			win.compile();
		}
		
		public function doSearchNext():void
		{
			win.searchNext();
		}
		public function doSearchPrev():void
		{
			win.searchPrev();
		}
		
		public function doNativeOpen():void
		{
			var compiler:SDKCompiler = new SDKCompiler;
			debug(win.project.path + win.crtEditor.filePath);
			compiler.nativeOpenDir(win.project.path + win.crtEditor.filePath);
		}
		
		public function doProjectSearch():void
		{
			win.projectSearch();
		}
		
		public function doGotoLine():void
		{
			win.gotoLine();
		}
		
		public function doRefreshProject():void
		{
			win.refreshProject();
		}
		
		public function doSearchReplace():void
		{
			win.searchReplace();
		}
		
		public function doAddLicense():void
		{
			AddLicense.show(win.project);
		}
		
		public function doAddClass():void
		{
			AddClass.show(win.project, win.crtEditor.filePath);
		}
		
		public function doAddFunction():void
		{
			AddFunction.show(win.project, win.crtEditor.filePath);
		}
		
		public function doAddPackage():void
		{
			AddPackage.show(win.project, win.crtEditor.filePath);
		}
		
		public function do_openFile(path:String, line:int=-1):void
		{
			win.openFile(path, line);
		}
		
		public function doCloseEditor():void
		{
			win.closeEditor();
		}
		
		public function doShortcuts():void
		{
			new KeyShortcutsPane().show();
		}
		
		public function doCompileAndRun():void
		{
			win.compile(function():void {
				doTestSWF();
			});
		}
		
		public function doTestSWF():void
		{
			//main.swfPopup(win.project.path + '/bin-debug/' + win.project.config.appName + '.swf');
			navigateToURL(new URLRequest('file://'+win.project.path + '/bin-debug/' + win.project.config.appName + '.swf'));
		}
		
		public function doCustomize():void
		{
			new Customize().show();
		}
		
		public function do_refreshButtonBar():void
		{
			win.refreshButtons();
		}
		
		public function doAbout():void
		{
			//main.htmlPopup('http://code.google.com/p/minibuilder/wiki/AboutMiniBuilder', 870, 500);
			new AboutDialog().show();
		}
		
		public function doBuildSettings():void
		{
			new BuildSettings(win.project).show();
		}
		
		public function doHelpContents():void
		{
			navigateToURL(new URLRequest('http://code.google.com/p/minibuilder/wiki/Contents'));
		}
	}
}
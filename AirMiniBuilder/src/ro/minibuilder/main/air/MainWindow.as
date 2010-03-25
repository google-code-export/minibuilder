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

package ro.minibuilder.main.air
{
	import com.victordramba.console.*;
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NotificationType;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.aswing.*;
	import org.aswing.tree.*;
	
	import ro.mbaswing.OptionPane;
	import ro.minibuilder.data.Constants;
	import ro.minibuilder.data.IProjectPlug;
	import ro.minibuilder.main.ActionManager;
	import ro.minibuilder.main.AppPanel;
	import ro.minibuilder.main.ProjectWindow;
	import ro.victordramba.util.StringEx;

	public class MainWindow extends Sprite
	{
		public var windowID:String;
		private var project:IProjectPlug;
		private var panel:AppPanel;
		private var tid:int;
		
		function MainWindow()
		{
			if (!stage) return;
			Debugger.setParent(stage, Capabilities.isDebugger);
			
			stage.align = 'TL';
			stage.scaleMode = 'noScale';
			
			//associate files
			NativeApplication.nativeApplication.setAsDefaultApplication('actionScriptProperties');
			//prepare startup
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			
			tid = setTimeout(showStartupScreen, 10);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
			
			windowID = 'main';
			
			stage.nativeWindow.addEventListener(Event.CLOSING, onClosing);
			
			
			root.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, function(e:NativeDragEvent):void {
				NativeDragManager.acceptDragDrop(root as MainWindow);
			});
			
			root.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, function(e:NativeDragEvent):void {
				NativeDragManager.dropAction = NativeDragActions.COPY;
				var list:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				if (list && list.length == 1)
					newProjectWindow(getProjectDir(list[0]));
			});
		}
		
		private function onClosing(e:Event):void
		{
			//if it's the last win, exit
			if (NativeApplication.nativeApplication.openedWindows.length > 1)
			{
				e.preventDefault();
				stage.nativeWindow.visible = false;
			}
		}
		
		private function onMouseClick(e:Event):void
		{
			stage.nativeWindow.activate();
		}
		
		private var inited:Boolean = false;
		
		public function showStartupScreen():void
		{
			stage.nativeWindow.visible = true;
			stage.nativeWindow.activate();
			stage.nativeWindow.notifyUser(NotificationType.INFORMATIONAL);
			if (!inited)
			{
				inited = true;
				stage.nativeWindow.title = 'Flash MiniBuilder';
				StartupScreen.start(this);
			}
		}
		
		private function onInvoke(e:InvokeEvent):void
		{
			clearTimeout(tid);
			if (e.arguments.length == 0)
				showStartupScreen();
			else
				newProjectWindow(getProjectDir(new File(e.arguments[0])));
		}
		
		private function getProjectDir(file:File):String
		{
			if (!file.isDirectory) file = file.parent;
			var path:String = file.nativePath;
			if (path.lastIndexOf(File.separator) == path.length-1)
				path = path.substr(0, -1);
			return path;
		}
		
		public function newProjectWindow(path:String):void
		{
			debug('Project: '+path);
			
			var so:SharedObject = SharedObject.getLocal('recent');
			so.data[path] = true;
			so.flush();
			
			if (!new File(path).resolvePath('.actionScriptProperties').exists)
			{
				OptionPane.showMessageDialog('Alert', 'No compatible project at this path\n'+path);
				delete so.data[path];
				so.flush();
				return;
			}
			
			//first lookup if we don't have it open
			for each (var nw:NativeWindow in NativeApplication.nativeApplication.openedWindows)
			{
				if (nw.stage.getChildAt(0).hasOwnProperty('windowID') && nw.stage.getChildAt(0)['windowID'] == path)
				{
					NativeApplication.nativeApplication.menu = nw.menu;
					nw.activate();
					return;
				}
			}
			
			var win:NativeWindow = new NativeWindow(new NativeWindowInitOptions());
			win.width = 900;
			win.height = 600;
			win.title = 'Flash MiniBuilder - ' + new File(path).name;
			win.visible = true;
			win.stage.align = 'TL';
			win.stage.scaleMode = 'noScale';
			var ld:Loader = new Loader;
			
			win.addEventListener(Event.CLOSE, function(e:Event):void {
				for each(var win:NativeWindow in NativeApplication.nativeApplication.openedWindows)
					if (win.visible) return;
					NativeApplication.nativeApplication.exit();
			});
			win.addEventListener(Event.ACTIVATE, function(e:Event):void {
				if (win.menu)
					NativeApplication.nativeApplication.menu = win.menu;
			});
			
			var context:LoaderContext = new LoaderContext(false, new ApplicationDomain);
			context.allowLoadBytesCodeExecution = true;
			debug('url='+stage.loaderInfo.url);
			ld.loadBytes(loaderInfo.bytes, context);
			ld.contentLoaderInfo.addEventListener(Event.INIT, function (e:Event):void
			{
				win.stage.addChild(ld.content);
				ld.content['startProject'](path);
			});
		}
		
		public var pwin:ProjectWindow;
		/*
		The remote ApplicationDomain
		---------------------------------------------------------------------------------------
		*/
		
		private var fileDropHandler:FileDropHandler;
		
		public function startProject(path:String):void
		{
			stage.align = 'TL';
			stage.scaleMode = 'noScale';
			windowID = path;
			
			pwin = new ProjectWindow;
			fileDropHandler = new FileDropHandler(pwin);
			
			new ActionManager(this);
			stage.addChild(pwin);
			pwin.start(path);
			
			
			var mXml:XML = Constants.MAIN_MENU;
			
			var menu:NativeMenu = new NativeMenu;
			createMenu(mXml, menu);
			menu.addEventListener(Event.SELECT, function(e:Event):void
			{
				ActionManager.inst['do'+StringEx.ucFirst(e.target.data.@action)]();
			});
			
			function createMenu(xml:XML, menu:NativeMenu):void
			{
				for each (var n:XML in xml.n)
				{
					if (n.@separator == 'yes')
						menu.addItem(new NativeMenuItem('', true));
					else if (n.n.length() == 0)
					{
						var item:NativeMenuItem = new NativeMenuItem(n.@label);
						item.data = n;
						menu.addItem(item);
					}
					else
					{
						var m:NativeMenu = new NativeMenu;
						createMenu(n, m);
						menu.addSubmenu(m, n.@label);
					}
				}
			}
			pwin.stage.nativeWindow.menu = menu;
			NativeApplication.nativeApplication.menu = menu;
			
			pwin.stage.nativeWindow.addEventListener(Event.CLOSING, pwin.onClosing);
			pwin.addEventListener('requestClose', function(e:Event):void {
				pwin.stage.nativeWindow.close();
			});
		}
		
		public function browseOpenProject():void
		{
			var file:File = new File;
			file.browseForDirectory('Open Project');
			file.addEventListener(Event.SELECT, function(e:Event):void {
				newProjectWindow(file.nativePath);
			});
		}
		
		public function closeWindow():void
		{
			pwin.stage.nativeWindow.close();
		}
		
		public function swfPopup(swfPath:String):void
		{
			htmlPopup(new File(swfPath).url, 600, 400);
		}
		
		public function htmlPopup(url:String, w:int, h:int):void
		{
			var opt:NativeWindowInitOptions = new NativeWindowInitOptions;
			opt.type = NativeWindowType.UTILITY;
			
			var ld:HTMLLoader = HTMLLoader.createRootWindow(true, opt, true, new Rectangle(0, 0, w, h));
			ld.load(new URLRequest(url));
			
			ld.stage.nativeWindow.addEventListener(Event.CLOSE, function(e:Event):void {
				for each(var win:NativeWindow in NativeApplication.nativeApplication.openedWindows)
				if (win.visible) return;
				NativeApplication.nativeApplication.exit();
			});
		}
	}
}
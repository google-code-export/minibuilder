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
	import flash.display.StageScaleMode;
	import flash.display.Shape;
	import __AS3__.vec.Vector;
	import com.victordramba.console.*;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import org.aswing.*;
	import org.aswing.event.ListItemEvent;
	import org.aswing.skinbuilder.orange.OrangeLookAndFeel;
	import org.aswing.tree.*;
	
	import ro.mbaswing.AsWingApplication;
	import ro.mbaswing.OptionPane;
	import ro.minibuilder.asparser.TypeDB;
	import ro.minibuilder.data.BatchLoader;
	import ro.minibuilder.data.CompilerMessage;
	import ro.minibuilder.data.IProjectPlug;
	import ro.minibuilder.data.ProjectConfig;
	import ro.minibuilder.data.fileBased.FileProject;
	import ro.minibuilder.data.fileBased.SDKCompiler;
	import ro.minibuilder.main.editor.DirEditor;
	import ro.minibuilder.main.editor.EditorMap;
	import ro.minibuilder.main.editor.IBinEditor;
	import ro.minibuilder.main.editor.IEditor;
	import ro.minibuilder.main.editor.ITextEditor;
	import ro.minibuilder.main.editor.ScriptAreaComponent;
	import ro.minibuilder.swcparser.SWCParser;

	public class ProjectWindow extends AsWingApplication
	{
		public var project:IProjectPlug;
		private var panel:ProjectWindowPanel;
		public var crtEditor:IEditor;
		private var batchLoader:BatchLoader;
		
		//ignore tree change event
		private var treeNoEvent:Boolean;
		private var config:ProjectConfig;
		
		
		private var t0:Number;
		//private var fileList:Vector.<String>;
		private var progressPopup:ProgressPopup;
		
		private var lastSerchResult:String;
		private var searchPattern:*;
		
		override protected function drawBackground():void
		{
			var g:Graphics = graphics;
			var m:Matrix = new Matrix;
			m.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/4);
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [0xF2F2F2,0xe6e6e6], [1,1], [0,255], m);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			g.endFill();
		}
		
		public function start(projectPath:String):void
		{
			//workaround for the stage size bug
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			visible = false;
			setTimeout(function():void {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				visible = true;
			}, 1000);
			
			Debugger.setParent(this, Capabilities.isDebugger);
			debugReference('win', this);
			KeyBindings.init(stage);
			
			UIManager.setLookAndFeel(new OrangeLookAndFeel);
			//UIManager.setLookAndFeel(new PPZhaoLAF);

			panel = new ProjectWindowPanel;
			setContentPane(panel);
			
			project = new FileProject;
			
			panel.tree.addSelectionListener(function():void {
				if (treeNoEvent) return;
				var fileName:String = panel.tree.getSelectedFilePath();
				//is file of known type?
				openFile(fileName);
			});
			
			panel.addEventListener('selectedEditor', function(e:Event):void {
				crtEditor = panel.crtEditor;
				updateTitle();
			});
			
			panel.messages.addEventListener(ListItemEvent.ITEM_CLICK, function():void {
				openFile(panel.messages.selectedMessage.path, panel.messages.selectedMessage.line);
			});
			
			panel.tree.filter = /^\./;
			batchLoader = new BatchLoader(project);
			
			project.open(projectPath, init1);
			CompilerMessage.pathPrefix = project.path;
		}
		
		public function onClosing(e:Event):void
		{
			var unsaved:Vector.<String> = panel.listUnsaved();
			if (unsaved.length)
			{
				e.preventDefault();
				stage.nativeWindow.activate();
				OptionPane.showMessageDialog('Unsaved files', 'The folowing files are unsaved:\n\n'+unsaved.join('\n')+
					'\n\nDo you want to save all before closing project?',
				function(opt:Number):void {
					if (opt & OptionPane.CANCEL) return;
					if (opt & OptionPane.YES) saveAll();
					dispatchEvent(new Event('requestClose'));
				}, null, true, null, OptionPane.YES | OptionPane.NO | OptionPane.CANCEL);
			}
		}
		
		public function saveAll():void
		{
			for each (var path:String in panel.listUnsaved())
				saveEditor(panel.getEditor(path) as ITextEditor);
		}
		
		private function updateTitle():void
		{
			//TODO change to remove dependency on AIR
			stage.nativeWindow.title = 'MiniBuilder - ' + (crtEditor ? (project.path + crtEditor.filePath) : '');
		}
		
		public function compile(onReady:Function=null):void
		{
			var unsaved:Vector.<String> = panel.listUnsaved();
			if (unsaved.length)
			{
				OptionPane.showMessageDialog('Unsaved files', 
					'The folowing files are not saved:\n'+unsaved.join('\n')+'\n'+
					'Save all and continue?',
					function(res:int):void {
						if (res & OptionPane.OK)
						{
							ActionManager.inst.doSaveAll();
							compile(onReady);
						}
					}, null, true, null, OptionPane.OK | OptionPane.CANCEL
				);
				return;
			}
			
			
			resetMarkers();
			panel.status = 'Compiling...';
			
			var compiler:SDKCompiler = new SDKCompiler;
			compiler.addEventListener(Event.COMPLETE, function(e:Event):void {
				panel.messages.messages = compiler.messages;
				prp.dispose();
				panel.status = 'Compile '+(compiler.statusOK?'success':'failed')+' '+(compiler.duration/1000).toFixed(2)+'s';
				if (onReady != null && compiler.statusOK)
					onReady();
				setTimeout(function():void {
					initTextEditor();
				}, 1);
			});
			
			panel.messages.messages = null;
			compiler.compile(project);
			var prp:ProgressPopup = new ProgressPopup('Compile');
			prp.show();
			compiler.addEventListener('progress', function(e:Event):void {
				prp.update(compiler.progress, Math.max(0, compiler.progress) + '%');
				if (compiler.progress == 100)
					compiler.removeEventListener('progress', arguments.callee);
			});
		}
		
		
		public function openFile(fileName:String, line:int=-1, pos:int=-1):void
		{
			debug('open:'+fileName);
			
			if (!fileName) return;
			
			if (fileName.indexOf(project.path) == 0)
				fileName = fileName.substr(project.path.length);
			
			//debug('2open:'+fileName);

			//special case directory
			if (project.isDirectory(fileName))
			{
				if (!panel.getEditor(fileName))
				{
					crtEditor = panel.newEditor(nameOfFile(fileName), DirEditor, fileName, true);
					(crtEditor as DirEditor).openDir(project.path);
				}
			}
			else if (!EditorMap.getEditorClass(fileName))
				return;
			else
			{
					
				treeNoEvent = true;
				panel.tree.setSelectedPath(fileName);
				treeNoEvent = false;
				
				if ((crtEditor = panel.getEditor(fileName)))
				{
					initTextEditor(line, pos);
				}
				else
				{
					var editor:IEditor = panel.newEditor(nameOfFile(fileName), 
						EditorMap.getEditorClass(fileName), fileName, false) as IEditor;
					if (editor is ITextEditor)
					{
						crtEditor = editor;
						if (line == -1) line = 0;
						project.readTextFile(fileName, function(src:String):void {
							(editor as ITextEditor).loadSource(src, fileName);
							initTextEditor(line, pos);
						});
					}
					else if (editor is IBinEditor)
					{
						project.readBinFile(fileName, function(data:ByteArray):void {
							(editor as IBinEditor).loadData(data);
						});
					}
				}
			}
			updateTitle();
		}
		
		private function initTextEditor(line:int=-1, pos:int=-1):void
		{
			var editor:ITextEditor = crtEditor as ITextEditor;
			if (!editor) return;
			//debug('open file: '+fileName);
			if (panel.messages.getModel().getSize() > 0)
			{
				var lines:Array = [];
				var tips:Array = [];
				for each(var msg:CompilerMessage in panel.messages.messages)
				{
					if (msg.path.substr(project.path.length) != editor.filePath) continue;
					lines.push(msg.line);
					tips.push('['+msg.level+'] '+msg.message);
				}
				editor.markLines(lines, tips);
			}
			
			if (pos > 0)
				editor.setSelection(pos, pos);
			else if (line >= 0)
				editor.gotoLine(line);
			
				
			//set focus to Editor
			stage.focus = crtEditor as InteractiveObject;
		}
		
		private function nameOfFile(path:String):String
		{
			path = path.replace(/\\/g, '/');
			return path.substr(path.lastIndexOf('/')+1);
		}
		
		public function saveCrtFile():void
		{
			saveEditor(crtEditor as ITextEditor);
		}
		
		private function saveEditor(editor:ITextEditor):void
		{
			if (!editor) return;
			//TODO system's endline?
			project.saveFile(editor.filePath, editor.text.replace(/\r/g, '\n'));
			editor.saved();
		}
		
		private function init1():void
		{
			t0 = new Date().getTime();
			progressPopup = new ProgressPopup('Opening project...');
			progressPopup.show();
			
			config = new ProjectConfig;
			project.readTextFile('.actionScriptProperties', init2);
		}
		
		private function init2(str:String):void
		{
			debug('init2');
			
			config.load(XML(str));
			var fileList:Vector.<String> = project.listFiles();
			addSdkLibs();			
			
			panel.tree.loadPlainList(fileList);
			
			batchLoader.load(fileList, function(progress:Number, fileName:String):void {
				if (progress == 1)
				{
					init3();
					progressPopup.closeReleased();
				}
				else
					progressPopup.update(progress*100, fileName);
			});
		}
		
		private function addSdkLibs():void
		{
			var fileList:Vector.<String> = project.listFiles();
			
			//add playerglobals & stuff
			//TODO we need to do this better! it should be based on the project compile configuration
			if (config.target == ProjectConfig.TARGET_PLAYER)
			{
				fileList.push('sdk://frameworks/libs/player/10/playerglobal.swc');
				fileList.push('sdk://frameworks/libs/utilities.swc');
				if (config.useFlex)
					fileList.push('sdk://frameworks/libs/framework.swc');
				else
					fileList.push('sdk://frameworks/libs/flex.swc');
			}
			if (config.target == ProjectConfig.TARGET_AIR)
			{
				fileList.push('sdk://frameworks/libs/air/airglobal.swc');
			}
		}
		
		
		/* // We need to extend a bit the IProjectPlug to be able to load libraries from outside the project
		// for the online version, this will be a common repository
		private function addSDKLib(path:String):void
		{
			debug('SDK LIB: '+path);
			var str:FileStream = new FileStream;
			str.open(new File(SDKCompiler.sdkPath).resolvePath(path), FileMode.READ);
			var ba:ByteArray = new ByteArray;
			str.readBytes(ba, 0, str.bytesAvailable);
			str.close();
			TypeDB.setDB(path, SWCParser.parse(ba));
		}*/
		
		
		private function init3():void
		{
			debug('duration: '+(new Date().getTime() - t0)/1000);
			for (var i:int=0; i<project.listFiles().length; i++)
			{
				if (/\.as$/.test(project.listFiles()[i]))
				{
					debug('open file '+project.listFiles()[i]);				
					openFile(project.config.sourcePaths[0] + '/' + project.config.mainApp, 0);
					break;
				}
			}
		}
		
		
		private function getSearch():*
		{
			var sel:String = (crtEditor as ITextEditor).selection;
			if (searchPattern != null && sel == lastSerchResult)
				return searchPattern;
			if (sel.length)
			{
				searchPattern = sel;
				return sel;
			}
			return null;
		}
		
		
		public function searchNext(back:Boolean=false):void
		{
			if (!(crtEditor is ITextEditor)) return;
			var src:* = getSearch();
			if (src != null)
			{
				if ((crtEditor as ITextEditor).search(src, back))
					lastSerchResult = (crtEditor as ITextEditor).selection;
				else
					OptionPane.showMessageDialog('Alert', 'Can\'t find '+src+'!');
			}
			else
				searchReplace();
		}
		
		public function searchPrev():void
		{
			this.searchNext(true);
		}
		
		public function projectSearch():void
		{
			var swin:ProjectSearch = new ProjectSearch(project.listFiles())
			swin.show();
			swin.addEventListener('submit', function(e:Event):void {
				if (swin.value)
					openFile(swin.value);
			});
		}
		
		public function gotoLine():void
		{
			if (crtEditor is ScriptAreaComponent)
			{
				var gwin:GotoLine = new GotoLine;
				gwin.show();
				gwin.addEventListener('submit', function(e:Event):void {
					stage.focus = crtEditor as InteractiveObject;
					(crtEditor as ScriptAreaComponent).gotoLine(gwin.value);
				});
			}
		}
		
		public function refreshProject():void
		{
			var oldList:Vector.<String> = project.listFiles();
			
			progressPopup = new ProgressPopup('Refreshing project...');
			progressPopup.show();
			
			
			project.open(project.path, function():void {
				var newList:Vector.<String> = project.listFiles();
				addSdkLibs();
				panel.tree.loadPlainList(newList);
				var fileName:String;
				var diffNew:Vector.<String> = new Vector.<String>;
				
				//TODO
				//check if the file has changed, check file modified time (and size ?)
				
				//add new ones
				for each (fileName in newList)
				{
					if (oldList.indexOf(fileName) == -1)
						diffNew.push(fileName);
				}
				
				//remove missing ones
				for each (fileName in oldList)
				{
					if (newList.indexOf(fileName) == -1 && 
							/\.(sw[cf]|as)$/i.test(fileName) &&
							!project.isDirectory(fileName))
						TypeDB.removeDB(fileName);
				}
				
				batchLoader.load(diffNew, function(progress:Number, name:String):void {
					if (progress == 1)
						progressPopup.closeReleased();
					else
						progressPopup.update(progress * 100, name);
				});
				
			});
		}
		
		public function searchReplace():void
		{
			var editor:ScriptAreaComponent = crtEditor as ScriptAreaComponent;
			if (!editor) return;
			
			var sw:SearchReplace = SearchReplace.getInst();
			sw.search = searchPattern;
			sw.show();
			sw.submit = function():void {
				stage.focus = editor;
				searchPattern = sw.search;
				debug('search for '+searchPattern);
				if (sw.action == 'search')
					editor.search(sw.search);
				else
				{
					var re:RegExp = new RegExp(sw.search is RegExp ? sw.search.source : sw.search, 
						sw.ignoreCase ? 'gi' : 'g');
					if (sw.action == 'replaceAll')
					{
						editor.replaceAllText(editor.text.replace(re, sw.replace));
					}
					if (sw.action == 'replace')
					{
						re.lastIndex = editor.selectionBeginIndex;
						var mat:Array = re.exec(editor.text);
						if (mat)
						{
							editor.replaceText(re.lastIndex-mat[0].length, re.lastIndex, sw.replace);
							var pos:int = re.lastIndex-mat[0].length + sw.replace.length;
							editor.setSelection(pos, pos);
							editor.dispatchChange();
						}
					}
				}
			};
		}
		
		public function closeEditor():void
		{
			panel.checkCloseCrtEditor();
		}
		
		public function refreshButtons():void
		{
			panel.refreshButtons();
		}
		
		public function resetMarkers():void
		{
			panel.resetMarkers();
		}
	}
}
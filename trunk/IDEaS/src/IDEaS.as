package {
	import com.ideas.data.DataHolder;
	import com.ideas.edit.EditContainer;
	import com.ideas.file.FileManager;
	import com.ideas.gui.ConsoleScreen;
	import com.ideas.gui.CreateFolderScreen;
	import com.ideas.gui.ExitConfirm;
	import com.ideas.gui.MainScreen;
	import com.ideas.gui.MenuScreen;
	import com.ideas.gui.OverwriteScreen;
	import com.ideas.gui.Preloader;
	import com.ideas.gui.RecentFilesScreen;
	import com.ideas.gui.ServerLifeIndicator;
	import com.ideas.gui.SettingsScreen;
	import com.ideas.gui.ToastNotification;
	import com.ideas.gui.WonderflScreen;
	import com.ideas.local.SettingsController;
	import com.ideas.net.ServerHandler;
	import com.ideas.utils.DebugAnalyzer;
	import com.ideas.utils.Stats;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import jp.psyark.utils.CodeUtil;
	[SWF(width = "520", height = "660", frameRate = "60", backgroundColor = "#eeeeee")]
	public class IDEaS extends Sprite {
		private var mainScreen:MainScreen
		private var menu:MenuScreen = new MenuScreen();
		private var fileManager:FileManager = new FileManager();
		private var exitConfirm:ExitConfirm = new ExitConfirm();
		private var overwriteConfirm:OverwriteScreen = new OverwriteScreen();
		private var folderScreen:CreateFolderScreen = new CreateFolderScreen();
		private var settingsScreen:SettingsScreen = new SettingsScreen();
		private var serverHandler:ServerHandler = new ServerHandler();
		private var isSaveAndExit:Boolean = false;
		private var preloader:Preloader = new Preloader();
		private var editContainer:EditContainer = new EditContainer();
		private var settingsCtrl:SettingsController = new SettingsController();
		private var keyboardRect:Rectangle = new Rectangle();
		private var wflScreen:WonderflScreen = new WonderflScreen();
		private var serverLife:ServerLifeIndicator = new ServerLifeIndicator();
		private var recentFilesScreen:RecentFilesScreen = new RecentFilesScreen();
		private var consoleScreen:ConsoleScreen = new ConsoleScreen();
		[Embed(mimeType = "application/x-font", source = "C:/Windows/Fonts/Inconsolata.otf", fontName = "HelveticaComp", embedAsCFF = 'false', unicodeRange = 'U+0020,U+0041-U+005A,U+0020,U+0061-U+007A,U+0030-U+0039,U+002E,U+0020-U+002F,U+003A-U+0040,U+005B-U+0060,U+007B-U+007E,U+05e7,U+05e8,U+05d0,U+05d8,U+05d5,U+05df,U+05dd,U+05e4,U+05e9,U+05d3,U+05d2,U+05db,U+05e2,U+05d9,U+05d7,U+05dc,U+05da,U+05e3,U+05d6,U+05e1,U+05d1,U+05d4,U+05e0,U+05de,U+05e6,U+05ea,U+05e5')]
		public static const EmailFont:Class;
		public function IDEaS() {
			Font.registerFont(EmailFont);
			DataHolder.mainFont = new EmailFont();
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			ToastNotification.stage = this.stage;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			mainScreen = new MainScreen(this.stage);
			mainScreen.addEventListener(MainScreen.FOCUS_OUT, onFocusOut);
			mainScreen.addEventListener(MainScreen.COMPILE, onCompile);
			mainScreen.addEventListener(MainScreen.KEYBOARD_EVENT, onKeyboardActivate);
			stage.addChild(mainScreen);
			stage.addChild(serverLife);
			stage.addChild(editContainer);
			serverHandler.stageReference = this.stage;
			serverHandler.addEventListener(ServerHandler.COMPILE, onCompileDone);
			serverHandler.addEventListener(IOErrorEvent.IO_ERROR, onCompileError);
			serverHandler.addEventListener(ServerHandler.PROGRESS,onCompileProgress);
			serverHandler.addEventListener(ServerHandler.WELCOME_DONE, onWelcomeDone)
			serverHandler.addEventListener(ServerHandler.WELCOME_ERROR, onWelcomeError);
			serverHandler.addEventListener(ServerHandler.IN_WEB, onGoneInWeb);
			fileManager.addEventListener(FileManager.CANCEL, closeExplorer);
			fileManager.addEventListener(FileManager.SAVE_FILE, saveFileDone);
			fileManager.addEventListener(FileManager.OPEN_FILE, openFileSelect);
			fileManager.addEventListener(FileManager.CREATE_FOLDER, openCreateFoder);
			fileManager.addEventListener(FileManager.SHOW_OVERWRITE, openOverwriteScreen);
			//
			settingsScreen.addEventListener(SettingsScreen.SAVE_CLICKED, onSettingsSaved);
			settingsScreen.addEventListener(SettingsScreen.CANCEL_CLICKED, onSettingsCancel);
			exitConfirm.addEventListener(ExitConfirm.CANCEL_CLICKED, exitConfirmClose);
			exitConfirm.addEventListener(ExitConfirm.EXIT_CLICKED, onExitClicked);
			exitConfirm.addEventListener(ExitConfirm.SAVE_EXIT_CLICKED, onSaveExitClicked);
			//
			wflScreen.addEventListener(Event.COMPLETE, onWonderflCodeLoaded);
			overwriteConfirm.addEventListener(OverwriteScreen.CANCEL_CLICKED, onOvewriteClose);
			overwriteConfirm.addEventListener(OverwriteScreen.CONFIRM_CLICKED, onConfirmOvewrite);
			//
			folderScreen.addEventListener(CreateFolderScreen.CANCEL_CLICKED, onCancelFolder);
			folderScreen.addEventListener(CreateFolderScreen.SAVE_CLICKED, onSaveFolder);
			//
			consoleScreen.addEventListener(ConsoleScreen.CANCEL_CLICKED, onCancelConsole);
			consoleScreen.addEventListener(ConsoleScreen.CLEAR_CLICKED, onClearMarkup);
			//
			recentFilesScreen.addEventListener(RecentFilesScreen.OPEN_FILE, onOpenRecentFile);
			recentFilesScreen.addEventListener(RecentFilesScreen.UPDATE_LIST, onUpdateFilesList);
			editContainer.addEventListener(EditContainer.INDENT, onIndentClicked);
			editContainer.addEventListener(EditContainer.OUTDENT, onOutdentClicked);
			editContainer.addEventListener(EditContainer.REDO, onRedoClicked);
			editContainer.addEventListener(EditContainer.UNDO, onUndoClicked);
			editContainer.addEventListener(EditContainer.HINTS, onHintsClicked);
			editContainer.addEventListener(EditContainer.AUTO_INDENT, onAutoIndentClicked);
			editContainer.addEventListener(EditContainer.DEBUG, onOpenConsole);
			menu.addEventListener(MenuScreen.MENU_SELECTED, onMenuSelected);
			//stage.addChild(new Stats())
			this.stage.addEventListener(Event.RESIZE, onResizeStage);
			this.stage.stageFocusRect = false;
			if (Capabilities.cpuArchitecture == "ARM") {
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
			}
			this.settingsCtrl.initUserData();
			onSettingsSaved(null);
		}
		private function onActivate(e:Event):void {
			serverHandler.pause = false;
		}
		private function onDeactivate(e:Event):void {
			serverHandler.pause = true;
		}
		private function onWelcomeDone(e:Event):void {
			serverLife.status = ServerLifeIndicator.CONFIRM;
			if (!DataHolder.initialServerCheck) {
				DataHolder.initialServerCheck = true;
				ToastNotification.makeText("Server Status Ok");
			}
		}
		private function onWelcomeError(e:Event):void {
			serverLife.status = ServerLifeIndicator.ERROR;
			if (!DataHolder.initialServerCheck) {
				DataHolder.initialServerCheck = true;
				ToastNotification.makeText("Server Status Error");
			}
		}
		private function onKeyboardActivate(e:Event):void {
			keyboardRect = this.stage.softKeyboardRect;
			onResizeStage(null);
		}
		private function onAutoIndentClicked(e:Event):void {
			mainScreen.autoIndent();
		}
		private function onHintsClicked(e:Event):void {
			mainScreen.triggerAssist();
		}
		private function onRedoClicked(e:Event):void {
			mainScreen.setText(DataHolder.getHistory(1));
		}
		private function onUndoClicked(e:Event):void {
			mainScreen.setText(DataHolder.getHistory(-1));
		}
		private function onIndentClicked(e:Event):void {
			mainScreen.indent(true);
		}
		private function onOutdentClicked(e:Event):void {
			mainScreen.indent(false);
		}
		private function onOpenConsole(e:Event):void {
			mainScreen.forceKeyboardClose();
			this.openConsole();
		}
		private function onCancelConsole(e:Event):void {
			this.closeConsole();
		}
		private function onCancelFolder(e:Event):void {
			this.closeCreateFolder();
		}
		private function onSaveFolder(e:Event):void {
			if (fileManager.createNewDirectory(this.folderScreen.getFolderName())) {
				ToastNotification.makeText("Created Folder: " + folderScreen.getFolderName());
			} else {
				ToastNotification.makeText("Error Creating Folder");
			}
			this.closeCreateFolder();
		}
		private function onOvewriteClose(e:Event):void {
			this.stage.removeChild(this.overwriteConfirm);
		}
		private function onConfirmOvewrite(e:Event):void {
			this.fileManager.overwriteFile();
			onOvewriteClose(e);
		}
		private function saveFileDone(e:Event):void {
			if (DataHolder.setRecentFile(fileManager.currentlyEditedFile.nativePath)) {
				this.settingsCtrl.saveUserSettings();
			}
			if (isSaveAndExit) {
				onExitClicked(e);
			} else {
				closeExplorer();
				ToastNotification.makeText("Saved File: " + this.fileManager.fileName);
			}
		}
		private function onSaveExitClicked(e:Event):void {
			isSaveAndExit = true;
			fileManagerSave();
			exitConfirmClose();
		}
		private function onExitClicked(e:Event):void {
			NativeApplication.nativeApplication.exit();
		}
		private function onCompileError(event:Event):void {
			stage.removeChild(preloader);
			consoleScreen.setDebugger(serverHandler.message);
			ToastNotification.makeText(serverHandler.message);
		}
		private function onClearMarkup(event:Event):void {
			DataHolder.debugArray = null;
			mainScreen.highlightError();
			this.closeConsole();
		}
		
		private function onCompileProgress(event:Event):void {
			this.preloader.setPercent(this.serverHandler.percent);
		}
		private function onCompileDone(event:Event):void {
			stage.removeChild(preloader);
			DataHolder.debugArray = DebugAnalyzer.parse(serverHandler.message);
			consoleScreen.setDebugger(serverHandler.message);
			mainScreen.highlightError();
			if (!serverHandler.compile) {
				ToastNotification.makeText("Compile Error");
				openConsole();
			}else{
				fileManager.fileName = CodeUtil.getDefinitionLocalName(mainScreen.getCode());
				if(fileManager.writeSwfOnDisk()){
					serverHandler.loadFile(fileManager.getFolderName());
				}
			}
		}
		private function onFocusOut(event:Event):void {
			if (fileManager.stage) {
				return;
			}
			this.stage.focus = null;
			setTimeout(mainScreen.setSelection, 10);
		}
		private function openOverwriteScreen(e:Event):void {
			overwriteConfirm.setLabel(fileManager.fileName + ".as");
			stage.addChild(this.overwriteConfirm);
		}
		private function openCreateFoder(event:Event):void {
			stage.addChild(folderScreen);
		}
		private function onUpdateFilesList(event:Event):void {
			this.settingsCtrl.saveUserSettings();
		}
		private function onOpenRecentFile(event:Event):void {
			DataHolder.clearHistory();
			var code:String = this.recentFilesScreen.getCurrentData()
			mainScreen.setText(code, true);
			DataHolder.saveState(code);
			ToastNotification.makeText("Opened file: " + this.recentFilesScreen.fileName);
			fileManager.currentlyEditedFile = this.recentFilesScreen.currentFile;
			this.closeRecentFiles();
		}
		private function openFileSelect(event:Event):void {
			DataHolder.clearHistory();
			var code:String = this.fileManager.getCurrentData()
			mainScreen.setText(code, true);
			DataHolder.saveState(code);
			ToastNotification.makeText("Opened file: " + this.fileManager.fileName);
			closeExplorer();
		}
		private function onCompile(event:Event):void {
			//mainScreen.setDebugger("Sending");
			serverHandler.send(CodeUtil.getDefinitionLocalName(mainScreen.getCode()), mainScreen.getCode());
			stage.addChild(preloader);
		}
		private function handleKeys(event:KeyboardEvent):void {
			processKeyInput(event.keyCode, event);
		}
		private function processKeyInput(keyCode:uint, e:KeyboardEvent = null):void {
			if (keyCode == Keyboard.BACK) {
				e.preventDefault();
				if (serverHandler.inWeb) {
					closeWeb();
					return;
				}
				if (this.overwriteConfirm.stage) {
					onOvewriteClose(null);
					return;
				}
				if (this.folderScreen.stage) {
					closeCreateFolder();
					return;
				}
				if (fileManager.stage) {
					closeExplorer();
					return;
				}
				if (this.wflScreen.stage) {
					closeWonderfl();
					return;
				}
				if (this.recentFilesScreen.stage) {
					closeRecentFiles();
					return;
				}
				if (menu.stage) {
					closeMenu();
					return;
				}
				if (this.settingsScreen.stage) {
					this.closeSettings();
					return;
				}
				if (this.consoleScreen.stage) {
					this.closeConsole();
					return;
				}
				if (exitConfirm.stage) {
					exitConfirmClose();
				} else {
					exitConfirmOpen();
				}
			}
			if (keyCode == Keyboard.MENU) { // || event.keyCode == Keyboard.UP) {
				if (this.wflScreen.stage) {
					closeWonderfl();
					return;
				}
				if (this.recentFilesScreen.stage) {
					closeRecentFiles();
					return;
				}
				if (this.settingsScreen.stage) {
					return;
				}
				if (this.fileManager.stage) {
					return;
				}
				if (serverHandler.inWeb) {
					return;
				}
				if (menu.stage) {
					closeMenu();
				} else {
					openMenu();
				}
			}
		}
		private function exitConfirmClose(e:Event = null):void {
			this.stage.removeChild(exitConfirm);
		}
		private function exitConfirmOpen():void {
			mainScreen.forceKeyboardClose();
			stage.addChild(exitConfirm);
		}
		private function onResizeStage(e:Event):void {
			mainScreen.onResizeStage(e);
			menu.y = this.stage.stageHeight;
			menu.resize(this.stage.stageWidth);
			fileManager.onResizeStage(e);
			wflScreen.onResizeStage(e);
			serverHandler.resize();
			consoleScreen.resize(this.stage.stageWidth, this.stage.stageHeight);
			this.settingsScreen.resize(this.stage.stageWidth, this.stage.stageHeight);
			exitConfirm.resize(this.stage.stageWidth, this.stage.stageHeight);
			overwriteConfirm.resize(this.stage.stageWidth, this.stage.stageHeight);
			preloader.resize(this.stage.stageWidth , this.stage.stageHeight - this.stage.softKeyboardRect.height-60);
			folderScreen.onResizeStage(e);
			this.recentFilesScreen.resize(this.stage.stageWidth, this.stage.stageHeight);
			serverLife.resize(9, this.stage.stageHeight - this.stage.softKeyboardRect.height - 55);
			editContainer.resize(this.stage.stageWidth, this.stage.stageHeight - this.stage.softKeyboardRect.height);
			//
			this.graphics.clear();
			this.graphics.beginFill(0x808080);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			this.graphics.endFill();
		}
		private function fileManagerSave(saveAs:Boolean = false):void {
			fileManager.codeString = mainScreen.getCode();
			if (!saveAs) {
				if (fileManager.currentlyEditedFile) { //currently editing an existing file
					if (fileManager.saveCurrentlyEditedFile()) { //write was succesessfull
						return;
					}
				}
			}
			fileManager.fileName = CodeUtil.getDefinitionLocalName(mainScreen.getCode());
			fileManager.setType("save");
			openExplorer();
		}
		private function onMenuSelected(e:Event):void {
			e.stopImmediatePropagation();
			mainScreen.forceKeyboardClose()
			trace(menu.currentLabel);
			switch (menu.currentLabel) {
				case MenuScreen.LABEL[0]: //wonderfl  //about
					openWonderfl();
					break;
				case MenuScreen.LABEL[1]: //save
					fileManagerSave();
					break;
				case MenuScreen.LABEL[2]: //settings
					openSettings();
					break;
				case MenuScreen.LABEL[3]: //help
					openRecentFiles();
					//serverHandler.langref();
					break;
				case MenuScreen.LABEL[4]: //new
					createNew();
					break;
				case MenuScreen.LABEL[5]: //open
					fileManager.setType("open");
					openExplorer();
					break;
				case MenuScreen.LABEL[6]: //save as
					fileManagerSave(true);
					//mainScreen.autoIndent();
					break;
				case MenuScreen.LABEL[7]: //search
					mainScreen.toggleSearch();
					break;
			}
			closeMenu();
		}
		private function openConsole():void {
			stage.addChild(this.consoleScreen);
		}
		private function closeConsole():void {
			stage.removeChild(this.consoleScreen);
		}
		private function closeCreateFolder():void {
			stage.removeChild(folderScreen);
		}
		private function openRecentFiles():void {
			stage.addChild(recentFilesScreen);
		}
		private function closeRecentFiles():void {
			stage.removeChild(recentFilesScreen);
		}
		private function openWonderfl():void {
			stage.addChild(this.wflScreen);
		}
		private function closeWonderfl():void {
			stage.removeChild(wflScreen);
		}
		private function onSettingsSaved(e:Event):void {
			if (e) {
				this.settingsCtrl.saveUserSettings();
				closeSettings();
			}
			this.mainScreen.setSettings();
		}
		private function onSettingsCancel(e:Event):void {
			closeSettings();
		}
		private function openSettings():void {
			stage.addChild(this.settingsScreen);
		}
		private function closeSettings():void {
			this.stage.removeChild(this.settingsScreen);
		}
		private function onWonderflCodeLoaded(e:Event):void {
			DataHolder.clearHistory();
			mainScreen.setText(this.wflScreen.codeString, true);
			DataHolder.saveState(mainScreen.getCode());
			fileManager.fileName = CodeUtil.getDefinitionLocalName(mainScreen.getCode());
			fileManager.currentlyEditedFile = null;
			ToastNotification.makeText("Wonderfl code: " + CodeUtil.getDefinitionLocalName(mainScreen.getCode()));
			closeWonderfl();
		}
		private function createNew():void {
			//TODO: add confirmation screen
			fileManager.fileName = FileManager.MAIN_FILE_NAME;
			fileManager.currentlyEditedFile = null;
			mainScreen.setNew();
		}
		private function onGoneInWeb(e:Event):void {
			trace("onGoneInWeb");
			mainScreen.forceKeyboardClose();
		}
		private function closeWeb():void {
			serverHandler.inWeb = false;
		}
		private function openMenu():void {
			mainScreen.menuHelperDispose();
			mainScreen.forceKeyboardClose();
			stage.addChild(menu);
		}
		private function closeMenu():void {
			this.stage.removeChild(menu);
		}
		private function openExplorer():void {
			mainScreen.forceKeyboardClose();
			stage.addChild(fileManager);
		}
		private function closeExplorer(e:Event = null):void {
			this.isSaveAndExit = false;
			if (fileManager.stage) {
				this.stage.removeChild(fileManager);
			}
		}
		
	}
}

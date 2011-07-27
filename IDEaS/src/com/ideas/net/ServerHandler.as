package com.ideas.net {
	import com.ideas.data.DataHolder;
	import com.ideas.data.Resources;
	import com.ideas.gui.buttons.GeneralButton;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class ServerHandler extends EventDispatcher {
		//public static const LANG_REF:String="http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/all-classes.html";
		public static const LANG_REF:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/"
		public static const WRITE_URL:String = Resources.data.server_url + "compile_swf_html.jsp"
		public static const WELCOME_URL:String = Resources.data.server_url + "welcome.jsp"
		public static const FILES_URL:String = Resources.data.server_url + "compile/files/"
		public static const DELETE_URL:String = Resources.data.server_url + "delete_data.jsp"
		public static const COMPILE:String = "compile";
		public static const SAVE_SWF:String = "SAVE_SWF";
		public static const WELCOME_ERROR:String = "WELCOME_ERROR";
		public static const WELCOME_DONE:String = "WELCOME_DONE";
		public static const IN_WEB:String = "IN_WEB";
		public static const MENU_OFFSET:int = 55;
		private var _inMenu:Boolean = false;
		private var webView:StageWebView;
		private var codeLdr:URLLoader
		private var id:String;
		private var fileName:String;
		private var _message:String;
		private var _compile:Boolean;
		private var _inPlayer:Boolean;
		private var _inWeb:Boolean;
		private var _stageReference:Stage;
		private var deleteLdr:URLLoader = new URLLoader();
		private var stageBgCover:Sprite = new Sprite();
		public static const OFFSET:int = 10;
		private var localLoader:URLLoader = new URLLoader();
		private var _hasSwfToSave:Boolean;
		private var saveSwfButton:GeneralButton = new GeneralButton(120, 50, "Save Swf ");
		private var welcomeLdr:URLLoader = new URLLoader();
		private var _codeLoading:Boolean;
		public function ServerHandler() {
			codeLdr = new URLLoader();
			codeLdr.addEventListener(Event.COMPLETE, onLoadDone);
			codeLdr.addEventListener(IOErrorEvent.IO_ERROR, onError);
			deleteLdr.addEventListener(IOErrorEvent.IO_ERROR, onDeleteError);
			deleteLdr.addEventListener(Event.COMPLETE, onDeleteDone);
			localLoader.dataFormat = URLLoaderDataFormat.BINARY;
			localLoader.addEventListener(Event.COMPLETE, localLoaderDone);
			localLoader.addEventListener(IOErrorEvent.IO_ERROR, onLocalLoaderError);
			saveSwfButton.addEventListener(MouseEvent.CLICK, onSaveSwfClick);
			welcomeLdr.addEventListener(Event.COMPLETE, onCompleteWelcomeTest);
			welcomeLdr.addEventListener(IOErrorEvent.IO_ERROR, onErrorWelcomeTest);
			doCheckWelcome();
		}
		public function get compile():Boolean {
			return _compile;
		}
		public function loadLocally():void {
			_hasSwfToSave = false;
			DataHolder.swfData = null;
			var req:URLRequest = new URLRequest(FILES_URL + id + "/" + fileName + ".swf");
			localLoader.load(req);
		}
		private function onCompleteWelcomeTest(e:Event):void {
			XML.ignoreWhitespace = true;
			try {
				var xml:XML = new XML(e.target.data);
				trace(xml.message);
				if (xml.message == "welcome") {
					this.dispatchEvent(new Event(WELCOME_DONE))
					onErrorWelcomeTest(null);
					return;
				}
			} catch (e:*) {
			}
			onErrorWelcomeTest(e);
		}
		private function onErrorWelcomeTest(e:Event = null):void {
			if (e) {
				this.dispatchEvent(new Event(WELCOME_ERROR))
			}
			setTimeout(doCheckWelcome, 5 * 60 * 1000);
		}
		private function doCheckWelcome():void {
			if (_inPlayer) {
				onErrorWelcomeTest();
				return;
			}
			welcomeLdr.load(new URLRequest(WELCOME_URL + "?rnd=" + Math.random()));
		}
		private function onLocalLoaderError(e:Event):void {
			_hasSwfToSave = false;
			DataHolder.swfData = null;
		}
		private function localLoaderDone(e:Event):void {
			_hasSwfToSave = true;
			DataHolder.swfData = e.target.data;
			deleteFile();
		}
		public function langref():void {
			inPlayer = false;
			StageWebViewExample(LANG_REF);
		}
		public function send(file:String, code:String):void {
			if (_codeLoading) {
				try {
					codeLdr.close();
				} catch (e:*) {
				}
			}
			_codeLoading = true;
			fileName = file;
			trace("get init:"+getTimer());
			var variables:URLVariables = new URLVariables();
			var req:URLRequest = new URLRequest(WRITE_URL);
			variables.code = code;
			id = int(new Date().getTime() / 1000).toString();
			variables.id = id;
			variables.file = fileName;
			//
			variables.s = DataHolder.htmlStage;
			variables.w = DataHolder.htmlWidth + DataHolder.htmlSizeType;
			variables.h = DataHolder.htmlHeight + DataHolder.htmlSizeType;
			variables.wid = DataHolder.swfWidth;
			variables.hgt = DataHolder.swfHeight;
			req.data = variables;
			req.method = URLRequestMethod.POST;
			codeLdr.load(req);
		}
		private function onLoadDone(e:Event):void {
			trace("get done:"+getTimer());
			_codeLoading = false;
			XML.ignoreWhitespace = true;
			var xml:XML = new XML(e.target.data);
			_message = xml.message;
			if (xml.error != "null") {
				_message += "\nError: " + xml.error;
			}
			if (xml.compile == "true") {
				loadFile();
				_compile = true;
			} else {
				_compile = false;
			}
			this.dispatchEvent(new Event(COMPILE));
		}
		private function onDeleteError(e:Event):void {
			//ignore file delete error
			trace("onDeleteError: " + e);
		}
		private function onDeleteDone(e:Event):void {
			trace("onDeleteDone: " + e.target.data);
		}
		private function onError(e:Event):void {
			trace(e);
			_codeLoading = false;
			_message = "server error";
			this.dispatchEvent(new Event(IOErrorEvent.IO_ERROR));
			doCheckWelcome();
		}
		private function loadFile():void {
			inPlayer = true;
			StageWebViewExample(FILES_URL + id + "/index.html");
		}
		private function StageWebViewExample(link:String):void {
			inWeb = true;
			if (!webView) {
				webView = new StageWebView();
				webView.addEventListener(Event.COMPLETE, onWebViewLoadDone);
			}
			webView.viewPort = new Rectangle(OFFSET, OFFSET, _stageReference.stageWidth - OFFSET * 2, _stageReference.stageHeight - OFFSET * 2);
			webView.stage = this._stageReference;
			_stageReference.addChild(stageBgCover);
			webView.loadURL(link);
		}
		private function onWebViewLoadDone(e:Event):void {
			if (inPlayer) {
				loadLocally()
			}
		}
		private function deleteFile():void {
			var variables:URLVariables = new URLVariables();
			var req:URLRequest = new URLRequest(DELETE_URL);
			variables.id = id;
			variables.file = fileName;
			req.data = variables;
			req.method = URLRequestMethod.POST;
			deleteLdr.load(req);
		}
		private function removeWebStage():void {
			_inPlayer = false;
			_inWeb = false;
			webView.stage = null;
			_stageReference.removeChild(stageBgCover);
			webView.removeEventListener(Event.COMPLETE, onWebViewLoadDone);
			webView.dispose();
			webView = null;
			_inMenu = true;
			toggleMenu();
		}
		public function resize():void {
			var _height:Number = _stageReference.stageHeight - OFFSET * 2 - int(_inMenu) * MENU_OFFSET
			if (webView) {
				webView.viewPort = new Rectangle(OFFSET, OFFSET, _stageReference.stageWidth - OFFSET * 2, _height);
			}
			
			stageBgCover.graphics.clear();
			stageBgCover.graphics.beginFill(0x0, 0.1);
			stageBgCover.graphics.drawRect(0, 0, _stageReference.stageWidth, _stageReference.stageHeight);
			stageBgCover.graphics.endFill();
			stageBgCover.graphics.beginFill(0);
			stageBgCover.graphics.drawRect(OFFSET - 2, OFFSET - 2, _stageReference.stageWidth - OFFSET * 2 + 2 * 2, _height + 2 * 2);
			stageBgCover.graphics.endFill();
			stageBgCover.graphics.beginFill(0xffffff);
			stageBgCover.graphics.drawRect(OFFSET, OFFSET, _stageReference.stageWidth - OFFSET * 2, _height);
			stageBgCover.graphics.endFill();
			stageBgCover.filters = [ new GlowFilter(0, 1, 12, 12, 1, 3)];
			saveSwfButton.setWidth(_stageReference.stageWidth - 10);
			saveSwfButton.x = 5;
			saveSwfButton.y = _stageReference.stageHeight - saveSwfButton.height - 5;
		}
		public function get stageReference():Stage {
			return _stageReference;
		}
		public function set stageReference(value:Stage):void {
			_stageReference = value;
		}
		public function get inWeb():Boolean {
			return _inWeb;
		}
		public function set inWeb(value:Boolean):void {
			_inWeb = value;
			if (!_inWeb) {
				removeWebStage();
			} else {
				this.dispatchEvent(new Event(IN_WEB));
			}
		}
		public function setLabel(value:String):void {
			var devider:String = "/";
			var arr:Array = value.split(devider);
			if (arr.length <= 1) {
				devider = "\\";
				arr = value.split(devider);
			}
			if (value.length > 10) {
				value = arr[0] + devider + arr[1]
				if (arr[2]) {
					value += devider + arr[2]
				}
				if (arr[3]) {
					value += devider + "..."
				}
			}
			value = "Save: " + value + devider + fileName + ".swf";
			saveSwfButton.setText(value);
		}
		public function get inPlayer():Boolean {
			return _inPlayer;
		}
		public function set inPlayer(value:Boolean):void {
			_inPlayer = value;
		}
		public function get message():String {
			return _message;
		}
		private function onSaveSwfClick(e:Event):void {
			this.dispatchEvent(new Event(SAVE_SWF));
		}
		public function toggleMenu():void {
			_inMenu = !_inMenu;
			if (_inMenu) {
				_stageReference.addChild(saveSwfButton);
			} else {
				try {
					_stageReference.removeChild(saveSwfButton);
				} catch (e:*) {
				}
			}
			if ( this._inWeb && this.webView) {
				this.webView.viewPort = new Rectangle(5, 5, 100, 100);
				stageBgCover.graphics.clear();
				setTimeout(delayedLaunch, 100);
			}
		}
		public function delayedLaunch():void {
			this.webView.stage = this.stageReference
			resize();
		}
	}
}

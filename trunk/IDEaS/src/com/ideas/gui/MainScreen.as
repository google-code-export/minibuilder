package com.ideas.gui {
	import com.ideas.data.DataHolder;
	import com.ideas.gui.buttons.GeneralButton;
	import com.ideas.gui.scroller.ScrollerIndicator;
	import com.ideas.text.DebugPanel;
	import com.ideas.text.LineNumbers;
	import com.ideas.text.ScriptArea;
	import com.ideas.utils.MenuHelper;
	import com.ideas.utils.PrettyPrint;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ro.minibuilder.asparser.Controller;
	public class MainScreen extends Sprite {
		private var compileButton:GeneralButton = new GeneralButton(120, 50, "Run");
		private var writeTextField:ScriptArea = new ScriptArea();
		private var debugTextField:DebugPanel = new DebugPanel();
		private var numbersTextField:LineNumbers = new LineNumbers();
		private var yPos:Number = 0;
		private var searchScreen:SearchScreen = new SearchScreen();
		public static const FOCUS_IN:String = "focus_in";
		public static const FOCUS_OUT:String = "focus_out";
		public static const COMPILE:String = "compile";
		public static const KEYBOARD_EVENT:String = "KEYBOARD_EVENT";
		private var ctrl:Controller;
		private var menuHelper:MenuHelper;
		private var codeString:String = DataHolder.DEFAULT_CODE;
		private var _scrollerIndicator:ScrollerIndicator = new ScrollerIndicator();
		public function MainScreen(stg:Stage) {
			addChild(compileButton);
			addChild(numbersTextField);
			addChild(writeTextField);
			addChild(debugTextField);
			addChild(_scrollerIndicator);
			searchScreen.addEventListener(SearchScreen.SEARCH, onSearchButtonClick);
			debugTextField.addEventListener(DebugPanel.DEBUG_RESIZE, onResizeStage);
			writeTextField.addEventListener(Event.CHANGE, onChange);
			writeTextField.addEventListener(ScriptArea.INIT_SCROLLING, onScrollAreaInit);
			writeTextField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onKeyboardActivate);
			writeTextField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onKeyboardDeactivate);
			ctrl = new Controller(stg, writeTextField);
			ctrl.addEventListener("complete", onCtrlReady);
			menuHelper = new MenuHelper(stg, ctrl, writeTextField);
			DataHolder.saveState(codeString);
			setText(codeString);
			compileButton.addEventListener(MouseEvent.CLICK, onCompileClick);
		}
		private function onScrollAreaInit(e:Event):void {
			numbersTextField.scrollV = this.writeTextField.scrollV;
			_scrollerIndicator.y = this.y + (this.height - _scrollerIndicator.height) * writeTextField.percent;
			_scrollerIndicator.alpha = 1;
			_scrollerIndicator.addEventListener(Event.ENTER_FRAME, onScrollIndicator);
		}
		private function onCtrlReady(e:Event):void {
			trace(ctrl.status);
			updateLineNumbers();
			updateIndicator();
		}
		private function onKeyboardDeactivate(event:SoftKeyboardEvent):void {
			this.dispatchEvent(new Event(KEYBOARD_EVENT));
		}
		private function onKeyboardActivate(event:SoftKeyboardEvent):void {
			this.dispatchEvent(new Event(KEYBOARD_EVENT));
			writeTextField.checkCaretFocus();
		}
		public function setNew():void {
			if (codeString.split("\t").join("").split("\n").join("").split(" ").join("") != writeTextField.text.split("\t").join("").split("\n").join("").split("\r").join("").split(" ").join("")) {
				writeTextField.text = codeString;
				ctrl.sourceChanged(getCode())
			}
		}
		public function setText(value:String, scrollUp:Boolean = false):void {
			if (!value) {
				return;
			}
			if (scrollUp) {
				writeTextField.scrollV = 0;
			}
			writeTextField.text = value;
			ctrl.sourceChanged(getCode())
		}
		public function onResizeStage(e:Event):void {
			if (!this.stage) {
				return;
			}
			numbersTextField.x = 5;
			numbersTextField.y = 5;
			numbersTextField.width = 100;
			writeTextField.x = numbersTextField.numbersWidth + 5 + 5;
			writeTextField.y = 5;
			writeTextField.width = this.stage.stageWidth - 10 - numbersTextField.numbersWidth - 5;
			numbersTextField.height = writeTextField.height = this.stage.stageHeight - compileButton.height - 15 - this.stage.softKeyboardRect.height;
			compileButton.x = 5;
			compileButton.y = this.stage.stageHeight - compileButton.height - 5 - this.stage.softKeyboardRect.height
			debugTextField.x = compileButton.x + compileButton.width + 5;
			debugTextField.width = this.stage.stageWidth - debugTextField.x - 10 - 50;
			debugTextField.height = compileButton.height + debugTextField.getDebugOffset();
			debugTextField.y = this.stage.stageHeight - compileButton.height - 5 - this.stage.softKeyboardRect.height - debugTextField.getDebugOffset();
			searchScreen.x = this.stage.stageWidth - 10 - SearchScreen.WIDTH;
			_scrollerIndicator.x = this.stage.stageWidth - 5 - ScrollerIndicator.WIDTH - 2;
			writeTextField.fixTextHeight();
			updateIndicator();
			menuHelper.resize();
			if (e) {
				updateLineNumbers();
			}
		}
		private function updateIndicator():void {
			if (writeTextField.maxScrollV > 1) {
				_scrollerIndicator.visible = true;
			} else {
				_scrollerIndicator.visible = false;
			}
			_scrollerIndicator.setHeight(writeTextField.height * ((writeTextField.bottomScrollV - writeTextField.scrollV) / writeTextField.numLines));
		}
		private function onCompileClick(e:Event):void {
			this.dispatchEvent(new Event(COMPILE));
		}
		public function indent(more:Boolean):void {
			writeTextField.indent(more);
		}
		public function forceKeyboardClose():void {
			writeTextField.forceKeyboardClose();
		}
		public function toggleSearch():void {
			if (this.searchScreen.stage) {
				this.removeChild(this.searchScreen);
			} else {
				writeTextField.toggleFocusListener(false);
				this.addChild(this.searchScreen);
				this.stage.focus = searchScreen.inputText;
				searchScreen.inputText.setSelection(0, 0);
				searchScreen.inputText.requestSoftKeyboard();
				writeTextField.toggleFocusListener(true);
			}
		}
		private function onChange(e:Event):void {
			trace("onChange");
			DataHolder.saveState(writeTextField.text);
			onResizeStage(e);
		}
		private function onScrollIndicator(e:Event):void {
			_scrollerIndicator.alpha -= 0.01;
			if (_scrollerIndicator.alpha < 0) {
				_scrollerIndicator.removeEventListener(Event.ENTER_FRAME, onScrollIndicator);
			}
		}
		private function updateLineNumbers():void {
			var str:String = this.writeTextField.getLinesNumbers();
			numbersTextField.updateDefaultFormat();
			numbersTextField.text = str;
			if (numbersTextField.getTextWidth()) {
				onResizeStage(null);
			}
		}
		public function getCode():String {
			return this.writeTextField.text;
		}
		public function setDebugger(value:String):void {
			this.debugTextField.text = value;
		}
		public function getDebugger():String {
			return debugTextField.text;
		}
		public function setSettings():void {
			numbersTextField.setFontSize();
			this.stage.displayState = DataHolder.displayState;
			writeTextField.backgroundColor = DataHolder.backgroundColor;
			ctrl.updateFormating();
		}
		private function onSearchButtonClick(e:Event):void {
			searchScreen.pickRegExp;
			var searchText:String = searchScreen.getText();
			if (searchText.length > 0) {
				var matches:Object = searchScreen.pickRegExp.exec(writeTextField.text);
				if (!matches) {
					matches = searchScreen.pickRegExp.exec(writeTextField.text);
					if (!matches) {
						trace("no matches");
						return;
					}
				}
				writeTextField.setSelection(matches.index, matches.index + searchText.length);
			}
		}
		public function menuHelperDispose():void {
			this.menuHelper.menuDispose();
		}
		public function setSelection():void {
			this.writeTextField.setSelection(writeTextField.caretIndex, writeTextField.caretIndex);
		}
		public function autoIndent():void {
			this.writeTextField.text = PrettyPrint.autoIndent(this.writeTextField.text);
			ctrl.sourceChanged(getCode());
		}
		public function triggerAssist():void {
			this.menuHelper.triggerAssist();
		}
		public function highlightError(value:Boolean = true):void {
			this.debugTextField.highlightError(value);
		}
	}
}

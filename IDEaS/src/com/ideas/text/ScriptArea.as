package com.ideas.text {
	import com.ideas.data.DataHolder;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	public class ScriptArea extends TextField {
		public static const INIT_SCROLLING:String = "init_scrolling";
		private var _killKeyboardManually:Boolean = false;
		private var scrollDiffernce:Number = 0;
		private var _scrollV:Number = 0;
		private var mouseDown:Boolean;
		private var scrollDelta:int = 0;
		private var _percent:Number = 0;
		private var scrollTimerDelta:int = 0;
		public function ScriptArea() {
			this.embedFonts = true;
			//this.border = true;
			this.type = TextFieldType.INPUT;
			this.multiline = true;
			this.wordWrap = true;
			//this.background = true;
			this.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			this.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			this.addEventListener(MouseEvent.MOUSE_UP, onWriteTextUp);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onWriteTextDown);
			this.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, TextKeyFocusChange);
			this.addEventListener(Event.SCROLL, scrollHandler);
			this.antiAliasType = AntiAliasType.ADVANCED;
			//this.backgroundColor = DataHolder.backgroundColor;
			this.defaultTextFormat = new TextFormat(DataHolder.mainFont.fontName, DataHolder.fontSize);
		}
		public function getLinesNumbers():String {
			var str:String="";
			var paragraphCounter:int = 1;
			var curParagraphOffset:int = -1;
			for (var i:int = 0; i < this.numLines; i++) {
				if (this.getFirstCharInParagraph(this.getLineOffset(i)) == this.getLineOffset(i) && this.getFirstCharInParagraph(this.getLineOffset(i)) > curParagraphOffset) {
					str += paragraphCounter + "\n";
					paragraphCounter++;
					curParagraphOffset = this.getFirstCharInParagraph(this.getLineOffset(i));
				} else {
					str += "\n";
				}
			}
			return str;
		}
		public function checkCaretFocus():void{
			//trace("checkCaretFocus",this.scrollV,this.getLineOffset(this.scrollV),this.caretIndex,this.getLineIndexOfChar(this.caretIndex-1));
			this.scrollV=this.getLineIndexOfChar(this.caretIndex-1);
		}
		public function get percent():Number {
			return _percent;
		}
		public function forceKeyboardClose():void {
			_killKeyboardManually = true;
			this.stage.focus = null;
		}
		private function onWriteTextDown(e:MouseEvent):void {
			scrollDiffernce = 0;
			mouseDown = true;
			this.removeEventListener(Event.ENTER_FRAME, onKineticScroll);
		}
		private function onWriteTextUp(e:MouseEvent):void {
			mouseDown = false;
			if (Math.abs(scrollDiffernce) > 0) {
				_scrollV = this.scrollV;
				this.addEventListener(Event.ENTER_FRAME, onKineticScroll);
			}
		}
		private function onFocusIn(e:FocusEvent):void {
			_killKeyboardManually = false;
		}
		private function onFocusOut(e:FocusEvent):void {
			if (_killKeyboardManually) {
				_killKeyboardManually = false;
				return;
			}
			this.stage.focus = this;
		}
		public function indent(more:Boolean):void {
			var prevIndex:int = this.caretIndex;
			var i:int = this.getFirstCharInParagraph(this.caretIndex);
			if (more) {
				this.replaceText(i, i, "\t");
				this.setSelection(prevIndex + 1, prevIndex + 1)
			} else {
				if (this.text.charAt(i) == "\t") {
					this.replaceText(i, i + 1, "");
					this.setSelection(prevIndex - 1, prevIndex - 1)
				}
			}
			DataHolder.saveState(text);
		}
		public function fixTextHeight():void {
			this.textHeight;
		}
		public function toggleFocusListener(add:Boolean):void {
			if (add) {
				this.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			} else {
				this.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			}
		}
		private function TextKeyFocusChange(e:FocusEvent):void {
			if (e) {
				e.preventDefault();
			}
			this.replaceText(this.caretIndex, this.caretIndex, "\t");
			this.setSelection(this.caretIndex + 1, this.caretIndex + 1);
			DataHolder.saveState(this.text);
			
		}
		private function onKineticScroll(e:Event):void {
			scrollDiffernce *= 0.95;
			_scrollV -= scrollDiffernce / 2;
			this.scrollV = _scrollV
			//this.scrollV -= scrollDiffernce / Math.abs(scrollDiffernce);
			var scrollIndex:int = this.getLineOffset(this.scrollV)
			this.setSelection(scrollIndex, scrollIndex);
			//
			if (Math.abs(scrollDiffernce) <= 0.1) {
				scrollDiffernce = 0;
				this.removeEventListener(Event.ENTER_FRAME, onKineticScroll);
			}
		}
		private function scrollHandler(e:Event):void {
			if (mouseDown) {
				var dif:Number = scrollDelta - this.scrollV;
				if (getTimer() - scrollTimerDelta < 40) { //100
					scrollDiffernce += dif
				} else {
					scrollDiffernce = 0;
				}
				scrollTimerDelta = getTimer();
				scrollDelta = this.scrollV
			}
			_percent = (this.scrollV - 1) / (this.maxScrollV - 1);
			this.dispatchEvent(new Event(INIT_SCROLLING));
		}
	}
}

/*
* @Author Dramba Victor
* 2009
*
* You may use this code any way you like, but please keep this notice in
* The code is provided "as is" without warranty of any kind.
*/
package com.ideas.utils {
	import com.ideas.gui.scroller.ScrollerEvent;
	import com.ideas.tool.ToolTip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import ro.minibuilder.asparser.Controller;
	import ro.victordramba.util.vectorToArray;
	public class MenuHelper {
		private var menuData:Vector.<String>
		private var fld:TextField;
		private var menu:MenuBox;
		private var ctrl:Controller;
		private var stage:Stage;
		private var menuStr:String;
		private var assistPos:int = 10000000;
		private var tooltip:ToolTip;
		private var tooltipCaret:int;
		public function MenuHelper(stage:Stage, ctrl:Controller, field:TextField) {
			fld = field;
			this.ctrl = ctrl;
			this.stage = stage;
			menu = new MenuBox();
			//menu in action
			menu.addEventListener(ScrollerEvent.UNIT_SELECTED, onSelectedUnit);
			tooltip = new ToolTip(stage);
			tooltip.addEventListener(Event.ENTER_FRAME, onTooltipCaretChecker);
			fld.addEventListener(Event.CHANGE, onChange);
			//used to close the tooltip
			fld.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			fld.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		public function closeToolTip():void {
			if (tooltip.isShowing()) {
				tooltip.disposeToolTip();
			}
		}
		private function onTooltipCaretChecker(e:Event):void {
			if (tooltip.isShowing() && Math.abs(tooltip.toolCaretIndex - fld.caretIndex) > 3) {
				tooltip.disposeToolTip();
			}
		}
		private function filterMenu():Boolean {
			var a:Array = [];
			for each (var s:String in menuData)
				if (s.toLowerCase().indexOf(menuStr.toLowerCase()) == 0)
					a.push(s);
			if (a.length == 0)
				return false;
			menu.setListData(a);
			var rect:Rectangle = getCharPos(fld.caretIndex - 1)
			menu.show(stage, rect.x + fld.x + rect.width, rect.y+ fld.y + rect.height);
			/*
			var rect:Rectangle = fld.getCharBoundaries(fld.caretIndex - 1);
			if (!rect) {
				rect = new Rectangle();
			}
			menu.show(stage, rect.x + fld.x + rect.width, rect.y);
			*/
			
			//
			return true;
		}
		private function onKeyUp(e:KeyboardEvent):void {
			if (tooltip.isShowing()) {
				tooltip.toolCaretIndex = fld.caretIndex;
				//
				var rect:Rectangle = getCharPos(fld.caretIndex - 1);
				var yPos:Number = (rect.y + fld.y + rect.height + 2);
				var xPos:Number = (rect.x + fld.x + rect.width);
				tooltip.moveLocationRelatedTo(yPos, xPos);
				//
				if (String.fromCharCode(e.charCode) == ')' || fld.caretIndex < tooltipCaret) {
					tooltip.disposeToolTip();
				}
			}
		}
		private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == 13) { // indent next line according to previous line indent
				e.preventDefault();
				if (menu.isShowing) { //close menu on enter selection
					menu.setSelectedValueToFloating();
					onSelectedUnit(null);
					return;
				}
				var extra:String = "";
				if (fld.text.charAt(fld.caretIndex - 1) == "{") {
					extra = "\t"
				}
				var ln:int = fld.getLineIndexOfChar(fld.caretIndex - 2);
				if (ln < 0) {
					return;
				}
				var i:int = fld.getFirstCharInParagraph(fld.getLineOffset(ln));
				var amount:int = 0;
				var tmpCount:int = 0;
				var str:String = "";
				while (true) {
					if (fld.text.charAt(i + tmpCount) != "\t") {
						break;
					}
					str += "\t";
					tmpCount++;
				}
				tmpCount += extra.length;
				str += extra;
				str += "\n";
				fld.replaceText(fld.caretIndex + 1, fld.caretIndex + 1, str);
				fld.setSelection(fld.caretIndex + tmpCount + 1, fld.caretIndex + tmpCount + 1);
				//prevent missed letters formating	
				ctrl.sourceChanged(fld.text);
			}
			if (fld.caretIndex > assistPos) {
				menuStr = fld.text.substring(assistPos + 1, fld.caretIndex).toLowerCase();
				var ch:String = String.fromCharCode(e.charCode);
				if (e.keyCode == Keyboard.BACKSPACE) {
					if (menuStr.length > 0) {
						menuStr = menuStr.substr(0, -1);
						if (filterMenu())
							return;
					}
				} else {
					menuStr += ch.toLowerCase();
					if (filterMenu())
						return;
				}
			}
			menuDispose();
		}
		public function menuDispose():void {
			menu.dispose();
			assistPos = 10000000;
		}
		public function resize():void {
			menu.resize();
			if (tooltip.isShowing()) {
				var rect:Rectangle = getCharPos(fld.caretIndex - 1);
				var yPos:Number = (rect.y + fld.y + rect.height + 2);
				var xPos:Number = (rect.x + fld.x + rect.width);
				tooltip.moveLocationRelatedTo(yPos, xPos);
			}
		}
		private function onSelectedUnit(e:Event):void {
			var c:int = fld.caretIndex;
			fldReplaceText(c - menuStr.length, c, menu.getSelectedValue());
			checkAddImports(menu.getSelectedValue());
			ctrl.sourceChanged(fld.text);
			assistPos = 100000;
			menu.dispose();
		}
		private function checkAddImports(name:String):void {
			var caret:int = fld.caretIndex;
			if (!ctrl.isInScope(name, caret - name.length)) {
				var missing:Vector.<String> = ctrl.getMissingImports(name, caret - name.length);
				if (missing) {
					var sumChars:int = 0;
					for (var i:int = 0; i < missing.length; i++) {
						var pos:int = fld.text.lastIndexOf('package', fld.caretIndex);
						pos = fld.text.indexOf('{', pos) + 1;
						var imp:String = '\n\t' + (i > 0 ? '//' : '') + 'import ' + missing[i] + '.' + name + ';';
						sumChars += imp.length;
						fld.replaceText(pos, pos, imp);
					}
					fld.setSelection(caret + sumChars, caret + sumChars);
				}
			}
		}
		private function fldReplaceText(begin:int, end:int, text:String):void {
			//var scrl:int = fld.scrollV;
			fld.replaceText(begin, end, text);
			fld.setSelection(begin + text.length, begin + text.length);
			//fld.scrollV = scrl;
		}
		public function triggerAssist():void {
			var pos:int = fld.caretIndex;
			//look back for last trigger
			var tmp:String = fld.text.substring(Math.max(0, pos - 100), pos).split('').reverse().join('');
			var m:Array = tmp.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
			var trigger:String = m ? m[2] : '';
			//
			if (tooltip.isShowing() && trigger == '(')
				trigger = '';
			if (m)
				menuStr = m[1];
			else {
				m = tmp.match(/^(\w*)\b/);
				menuStr = m ? m[1] : '';
			}
			menuStr = menuStr.split('').reverse().join('')
			pos -= menuStr.length + 1;
			menuData = null;
			if (trigger == 'wen' || trigger == 'sa' || trigger == ':') {
				menuData = ctrl.getTypeOptions();
			} else if (trigger == '.') {
				menuData = ctrl.getMemberList(pos);
			} else if (trigger == '') {
				menuData = ctrl.getAllOptions(pos);
			} else if (trigger == '(') {
				var fd:String = ctrl.getFunctionDetails(pos);
				if (fd) {
					tooltip.setTipText(fd);
					var rect:Rectangle = getCharPos(pos);
					//
					var yPos:Number = (rect.y + fld.y + rect.height + 2);
					var xPos:Number = (rect.x + fld.x + rect.width);
					tooltip.showToolTip();
					tooltip.toolCaretIndex = fld.caretIndex;
					tooltip.moveLocationRelatedTo(yPos, xPos);
					tooltipCaret = fld.caretIndex;
					return;
				}
			}
			if (!menuData || menuData.length == 0)
				return;
			assistPos = pos;
			showMenu();
			if (menuStr.length)
				filterMenu();
		}
		private function getCharPos(index:int):Rectangle {
			
			var rect:Rectangle = fld.getCharBoundaries(index);
			if (!rect) {
				rect = new Rectangle();
			}
			var scrollIndex:int = fld.getLineOffset(fld.scrollV - 1)
			var rect2:Rectangle = fld.getCharBoundaries(scrollIndex);
			if (rect2) {
				rect.x -= rect2.x;
				rect.y -= rect2.y;
			}
			return rect;
		}
		private function onChange(e:Event):void {
			if (triggerCheck())
				triggerAssist();
			else
				ctrl.sourceChanged(fld.text);
		}
		protected function triggerCheck():Boolean {
			var str:String = fld.text.substring(Math.max(0, fld.caretIndex - 10), fld.caretIndex);
			str = str.split('').reverse().join('');
			return (/^(?:\(|\:|\.|\s+sa\b|\swen\b|\ssdnetxe)/.test(str))
		}
		private function showMenu():void {
			menu.setListData(vectorToArray(menuData));
			var rect:Rectangle = getCharPos(fld.caretIndex - 1)
			menu.show(stage, rect.x + fld.x + rect.width, rect.y+ fld.y + rect.height);
			/*
			var rect:Rectangle = fld.getCharBoundaries(fld.caretIndex - 1);
			if (!rect) {
				rect = new Rectangle();
			}
			menu.show(stage, rect.x + fld.x + rect.width, rect.y);
			*/
		}
	}
}

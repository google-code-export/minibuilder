package com.ideas.gui {
	import com.ideas.data.Resources;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.ideas.gui.buttons.ExpandButton;
	import com.ideas.gui.buttons.IconButton;

	public class EditButtons extends Sprite {
		private var expandButton:ExpandButton=new ExpandButton(50, 50);
		private var contractButton:ExpandButton=new ExpandButton(50, 50);
		private var indentButton:IconButton;
		private var outdentButton:IconButton;
		private var undoButton:IconButton;
		private var redoButton:IconButton;
		private var hintsButton:IconButton;
		private var autoIndentButton:IconButton;
		//private var helpSearchButton:IconButton
		public static const EXPAND:String="expand";
		public static const CONTRACT:String="contract";
		private var _expanded:Boolean;
		public static const OUTDENT:String="OUTDENT";
		public static const INDENT:String="INDENT";
		public static const UNDO:String="UNDO";
		public static const REDO:String="REDO";
		public static const HINTS:String="HINTS";
		public static const AUTO_INDENT:String="AUTO_INDENT";
		public static const HELP_SEARCH:String="HELP_SEARCH";
		
		public function EditButtons() {
			indentButton=new IconButton(new Resources.IndentMoreIcon(), 50, 50);
			outdentButton=new IconButton(new Resources.IndentLessIcon(), 50, 50);
			undoButton=new IconButton(new Resources.UndoIcon(), 50, 50);
			redoButton=new IconButton(new Resources.UndoIcon(), 50, 50);
			hintsButton=new IconButton(new Resources.FormatIcon(), 50, 50);
			autoIndentButton=new IconButton(new Resources.AutoIndentIcon(), 50, 50);
			//helpSearchButton=new IconButton(new Resources.HelpIcon(), 50, 50);
			addChild(expandButton);
			this.addChild(contractButton);
			this.addChild(indentButton);
			this.addChild(outdentButton);
			this.addChild(undoButton);
			this.addChild(redoButton);
			this.addChild(hintsButton);
			this.addChild(autoIndentButton);
			//this.addChild(helpSearchButton);
			contractButton.scaleX=-1;
			redoButton.scaleX=-1;
			contractButton.x=-5;
			expandButton.x=-expandButton.width - 5;
			outdentButton.x=expandButton.x - outdentButton.width - 5
			indentButton.x=outdentButton.x - indentButton.width - 5;
			//
			autoIndentButton.x=indentButton.x -autoIndentButton.width - 5;
			redoButton.x=autoIndentButton.x - 5;
			undoButton.x=redoButton.x - redoButton.width*2 - 5;
			hintsButton.x=undoButton.x-undoButton.width-5;
			//helpSearchButton.x=hintsButton.x-hintsButton.width-5;
			//
			autoIndentButton.y=hintsButton.y=redoButton.y=undoButton.y=outdentButton.y=indentButton.y=contractButton.y=expandButton.y=-expandButton.height - 5;
			expandButton.addEventListener(MouseEvent.CLICK, onExpandClick);
			contractButton.addEventListener(MouseEvent.CLICK, onContractClick);
			indentButton.addEventListener(MouseEvent.CLICK, onIndentClicked);
			outdentButton.addEventListener(MouseEvent.CLICK, onOutdentClicked);
			//
			redoButton.addEventListener(MouseEvent.CLICK, onRedoClicked);
			undoButton.addEventListener(MouseEvent.CLICK, onUndoClicked);
			hintsButton.addEventListener(MouseEvent.CLICK, onHintsClicked);
			autoIndentButton.addEventListener(MouseEvent.CLICK, onAutoIndentClicked);
			//helpSearchButton.addEventListener(MouseEvent.CLICK, onHelpSearchClicked);
			//
			expanded=false;
		}
		/*
		private function onHelpSearchClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(HELP_SEARCH));
		}
		*/
		private function onAutoIndentClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(AUTO_INDENT));
		}
		private function onHintsClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(HINTS));
		}
		private function onRedoClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(REDO));
		}
		private function onUndoClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(UNDO));
		}
		private function onIndentClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(INDENT));
		}
		private function onOutdentClicked(e:MouseEvent):void {
			this.dispatchEvent(new Event(OUTDENT));
		}
		private function onExpandClick(e:MouseEvent):void {
			expanded=true;
			this.dispatchEvent(new Event(EXPAND));
		}
		private function onContractClick(e:MouseEvent):void {
			expanded=false;
			this.dispatchEvent(new Event(CONTRACT));
		}
		public function get expanded():Boolean {
			return _expanded;
		}
		public function set expanded(value:Boolean):void {
			_expanded=value;
			expandButton.visible=!_expanded;
			contractButton.visible=!expandButton.visible;
			indentButton.visible=_expanded;
			outdentButton.visible=_expanded;
			undoButton.visible=_expanded;
			redoButton.visible=_expanded;
			hintsButton.visible=_expanded;
			autoIndentButton.visible=_expanded;
			//helpSearchButton.visible=_expanded;
			this.graphics.clear();
			if(_expanded){
				this.graphics.lineStyle(0,0)
				this.graphics.beginFill(0x808080);
				this.graphics.drawRect(0,0,(-expandButton.width-5)*7-5,-expandButton.height - 10);
				this.graphics.endFill();
			}
		}
	}
}
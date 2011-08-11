package com.ideas.edit {
	import com.ideas.data.Resources;
	import com.ideas.gui.scroller.BasicScrollerUnit;
	import com.ideas.gui.scroller.HorizontalScrollerContainer;
	import com.ideas.gui.scroller.ScrollerEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	public class EditContainer extends Sprite {
		private var _wid:int = 0;
		private var _hgt:int = 0;
		
		public static const OUTDENT:String="OUTDENT";
		public static const INDENT:String="INDENT";
		public static const UNDO:String="UNDO";
		public static const REDO:String="REDO";
		public static const HINTS:String="HINTS";
		public static const AUTO_INDENT:String="AUTO_INDENT";
		public static const DEBUG:String="DEBUG";
		private var arrowLeft:EditIndicatorArrow=new EditIndicatorArrow();
		private var arrowRight:EditIndicatorArrow=new EditIndicatorArrow();
		private var listData:Array = [{title:"hints",event:HINTS,icon:new Resources.FormatIcon()},	
			{title:"debug",event:DEBUG,icon:new Resources.DebugIcon()},
			{title:"undo",event:UNDO,icon:new Resources.UndoIcon()},
			{title:"redo",event:REDO,icon:new Resources.RedoIcon()},
			{title:"in-dent",event:INDENT,icon:new Resources.IndentMoreIcon()},
			{title:"out-dent",event:OUTDENT,icon:new Resources.IndentLessIcon()},
			{title:"auto-dent",event:AUTO_INDENT,icon:new Resources.AutoIndentIcon()}];
		private var scrollerContainer:HorizontalScrollerContainer;
		public function EditContainer() {
			scrollerContainer=new HorizontalScrollerContainer();
			scrollerContainer.addEventListener(ScrollerEvent.UNIT_SELECTED, onScrollerUnitSelected);
			for (var i:int = 0; i < 20; i++) {
				var unit:BasicScrollerUnit = new BasicScrollerUnit();
				unit.setGraphicUnit(new EditScrollerGraphic());
				scrollerContainer.addUnit(unit);
			}
			this.addChild(arrowLeft);
			this.addChild(arrowRight);
			arrowRight.scaleX=-1;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}
		public function resize(wid:int, hgt:int):void {
			_wid = wid;
			_hgt = hgt;
			this.scrollerContainer.onResize(_wid-80-10-5-EditIndicatorArrow.ARROW_BORDERS*2 , 60);
			scrollerContainer.y = _hgt-60;
			scrollerContainer.x = 80+10+EditIndicatorArrow.ARROW_BORDERS;
			this.graphics.clear();
			arrowLeft.visible=arrowRight.visible=scrollerContainer.hasScroller
			
				arrowLeft.x=80+10;
				arrowRight.x=_wid-5;
				arrowLeft.y=arrowRight.y=_hgt-60;
			
		}
		private function onAdd(e:Event):void {
			addChild(scrollerContainer);
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			scrollerContainer.setListData(listData);
		}
		private function onScrollerUnitSelected(e:Event):void {
			var data:Object = scrollerContainer.selectedItem.data;
			this.dispatchEvent(new Event(data.event));
		}
	}
}

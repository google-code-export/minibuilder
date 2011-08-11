package com.ideas.gui.scroller {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	public class HorizontalScrollerContainer extends Sprite {
		private var _selectedItem:BasicScrollerUnit;
		private var container:Sprite = new Sprite;
		private var setTimer:int = 0;
		private var containerMask:Shape = new Shape;
		private var fingerPos:Point = new Point;
		private var scrollDelta:Number = 0;
		private var containerHeight:Number = 0;
		private var _hasScroller:Boolean = false;
		private var containerPos:Point = new Point;
		private var _width:Number;
		private var _height:Number;
		private var positionCounter:int = 0;
		private var itemData:Array;
		private var unitCont:Vector.<BasicScrollerUnit> = new Vector.<BasicScrollerUnit>();
		private var _overDisabled:Boolean
		public function HorizontalScrollerContainer() {
			addChild(container);
			addChild(containerMask);
			container.mask = containerMask;
			container.mouseEnabled = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		public function get hasScroller():Boolean {
			return _hasScroller;
		}
		public function set selectedItem(value:BasicScrollerUnit):void {
			_selectedItem = value;
		}
		private function onAdd(e:Event):void {
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageClk);
		}
		private function onRemoved(e:Event):void {
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageClk);
		}
		private function onStageClk(e:Event):void {
			this.dispatchEvent(new ScrollerEvent(ScrollerEvent.LEAVE_STAGE_DOWN));
		}
		public function get selectedItem():BasicScrollerUnit {
			return _selectedItem;
		}
		public function clearContainer():void {
			_selectedItem = null;
			_overDisabled = false;
			this.container.x = 0; //TODO: make generic
			positionCounter = 0;
			containerHeight = 0;
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			}
			itemData = [];
			updateData();
		}
		public function setListData(list:Array):void {
			itemData = list
			positionCounter = 0;
			containerHeight = itemData.length * unitCont[0].width; //TODO: make generic
			limits();
			updateData();
		}
		public function addUnit(unit:BasicScrollerUnit):void {
			unitCont.push(unit);
			container.addChild(unit);
			unit.addEventListener(MouseEvent.MOUSE_DOWN, onUnitDown, false, 0, true);
			unit.addEventListener(MouseEvent.MOUSE_UP, onUnitUp, false, 0, true);
			unit.addEventListener(MouseEvent.MOUSE_OVER, onUnitOver, false, 0, true);
			unit.addEventListener(MouseEvent.MOUSE_OUT, onUnitOut, false, 0, true);
			unit.visible = false;
			//
			_selectedItem = container.getChildAt(0) as BasicScrollerUnit;
			limits();
		}
		public function onResize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			resizeUnits();
		}
		private function resizeUnits():void {
			containerMask.graphics.clear();
			containerMask.graphics.beginFill(0);
			containerMask.graphics.drawRect(0, 0, _width, _height);
			containerMask.graphics.endFill();
			//
			this.graphics.clear();
			this.graphics.beginFill(0, 0.001);
			this.graphics.drawRect(0, 0, Math.min(this._width, containerHeight), _height) //TODO: make generic
			this.graphics.endFill();
			//
			if (container.numChildren > 0) {
				for (var i:int = 0; i < container.numChildren; i++) {
					BasicScrollerUnit(container.getChildAt(i)).setHeight(_height); //TODO: make generic
				}
			}
			limits();
		}
		private function onUnitOut(e:MouseEvent):void {
			e.currentTarget.over = false;
		}
		private function onUnitOver(e:MouseEvent):void {
			if (_overDisabled) {
				return;
			}
			e.currentTarget.over = true;
			//
		}
		private function onUnitDown(e:MouseEvent):void {
			e.stopImmediatePropagation();
			this.removeEventListener(Event.ENTER_FRAME, onSlide);
			setTimer = getTimer();
			_selectedItem = e.currentTarget as BasicScrollerUnit;
			//_selectedItem.over=true;
			fingerPos.x = e.stageX;
			fingerPos.y = e.stageY;
			containerPos.x = container.x;
			containerPos.y = container.y;
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
		}
		private function onStageUp(e:Event):void {
			_overDisabled = false;
			checkForSlide();
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			}
		}
		private function onStageMouseMove(e:MouseEvent):void {
			if (Math.abs(fingerPos.x - e.stageX) > 10) {
				_overDisabled = true;
			}
			if (!_hasScroller) {
				return;
			}
			scrollDelta = container.x;
			container.x = containerPos.x - (fingerPos.x - e.stageX);
			scrollDelta = scrollDelta - container.x;
			limits();
		}
		private function limits():void {
			if (container.numChildren <= 0) {
				return;
			}
			/////////////////////////////////////
			if (containerHeight < this._width) {
				container.x = 0;
			} else {
				if (container.x > 0) {
					container.x = 0;
					scrollDelta = 0;
				}
				if (container.x < this._width - containerHeight) {
					container.x = this._width - containerHeight;
					scrollDelta = 0;
				}
			}
			var perc:Number = container.x / (this._width - containerHeight);
			/////////////////
			var pos:int = int(-container.x / container.getChildAt(0).width);
			if (pos != positionCounter) {
				positionCounter = pos;
				updateData();
			}
			///////////////
			checkScrollerHeight();
		}
		private function onUnitUp(e:Event):void {
			var unit:BasicScrollerUnit = e.currentTarget as BasicScrollerUnit;
			setTimer = getTimer() - setTimer;
			if (unit == _selectedItem && setTimer < 300 && Math.abs(fingerPos.x - this.stage.mouseX) < 10) {
				fingerPos.y = fingerPos.x = 0;
				this.dispatchEvent(new ScrollerEvent(ScrollerEvent.UNIT_SELECTED));
			} else {
				checkForSlide();
			}
		}
		private function checkForSlide():void {
			if (Math.abs(scrollDelta) > 4) {
				this.addEventListener(Event.ENTER_FRAME, onSlide);
			} else {
				//indicator.visible = false;
			}
		}
		private function onSlide(e:Event):void {
			scrollDelta *= 0.95;
			container.x -= scrollDelta;
			limits();
			if (Math.abs(scrollDelta) < 0.1) {
				//indicator.visible = false;
				this.removeEventListener(Event.ENTER_FRAME, onSlide);
			}
		}
		private function checkScrollerHeight():void {
			_hasScroller = true;
			if (_width >= containerHeight) {
				container.x = 0;
				_hasScroller = false;
			}
		}
		public function getFirstItem():BasicScrollerUnit {
			return unitCont[0];
		}
		private function updateData():void {
			if (!unitCont || !itemData || !unitCont.length) {
				return;
			}
			for (var i:int = 0; i < unitCont.length; i++) {
				unitCont[i].x = (i + positionCounter) * unitCont[0].width;
				if (i + positionCounter < itemData.length) {
					unitCont[i].data = itemData[i + positionCounter];
					unitCont[i].visible = true;
					unitCont[i].over = false;
				} else {
					unitCont[i].visible = false;
				}
			}
		}
	}
}

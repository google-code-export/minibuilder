package com.ideas.gui {
	import com.ideas.data.Resources;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class MenuScreen extends Sprite {
		private var _wid:int;
		public static const MENU_SELECTED:String = "menu_selected";
		public static const HEIGHT:int = 160;
		public static const LIMIT:int = 4;
		private var icons:Vector.<Bitmap> = Vector.<Bitmap>([ new Resources.MenuWonderfl(), new Resources.MenuSave(), new Resources.MenuSettings(), new Resources.MenuRecent(), new Resources.MenuNew(), new Resources.MenuOpen(), new Resources.MenuSaveAs(), new Resources.MenuSearch()]);
		private var labels:Vector.<TextField> = new Vector.<TextField>(8, true);
		public static const LABEL:Vector.<String> = Vector.<String>([ "Wonderfl", "Save", "Settings", "Recent Files", "New", "Open", "Save As", "Search" ]);
		private var icon_wid:int = icons[0].width;
		private var _currentLabel:String;
		public function MenuScreen() {
			for (var i:int = 0; i < icons.length; i++) {
				labels[i] = new TextField();
				labels[i].defaultTextFormat = new TextFormat("_sans", 18, 0x555555, false, null, null, null, null, "center")
				labels[i].height = 30;
				labels[i].selectable = false;
				labels[i].text = LABEL[i];
				this.addChild(icons[i]);
				this.addChild(labels[i]);
			}
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.MOUSE_OVER, onMenuOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMenuDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMenuUp);
		}
		public function resize(wid:int):void {
			_wid = wid;
			redraw();
		}
		private function onMenuOver(e:MouseEvent):void {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}
		private function onMenuOut(e:MouseEvent):void {
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
		}
		private function onMenuDown(e:MouseEvent):void {
		}
		private function onMove(e:MouseEvent):void {
			if (this.mouseX > 0 && this.mouseX < _wid && this.mouseY < 0 && this.mouseY > -HEIGHT) {
				var xx:int = this.mouseX / (_wid / LIMIT);
				var yy:int = this.mouseY / -(HEIGHT / 2);
				redraw(new Rectangle(xx * (_wid / LIMIT), yy * -(HEIGHT / 2), _wid / LIMIT, -HEIGHT / 2));
				return;
			}
			redraw();
		}
		private function onMenuUp(e:MouseEvent):void {
			e.stopImmediatePropagation();
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			var xx:int = this.mouseX / (_wid / LIMIT);
			var yy:int = this.mouseY / -(HEIGHT / 2);
			var num:int = xx + yy * LIMIT;
			if (num >= LABEL.length) {
				return;
			}
			_currentLabel = LABEL[num];
			this.dispatchEvent(new Event(MENU_SELECTED));
		}
		private function redraw(rect:Rectangle = null):void {
			this.graphics.clear();
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(3, 0, _wid - 6, -HEIGHT + 4);
			this.graphics.endFill();
			if (rect) {
				this.graphics.beginFill(0xcccccc);
				this.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				this.graphics.endFill();
			}
			this.graphics.beginFill(0x6d6d6d);
			this.graphics.drawRect(0, 0, _wid, -HEIGHT);
			this.graphics.drawRect(3, 0, _wid - 6, -HEIGHT + 4);
			this.graphics.endFill();
			this.graphics.lineStyle(0, 0x6d6d6d);
			this.graphics.moveTo(6, -HEIGHT / 2);
			this.graphics.lineTo(_wid - 6, -HEIGHT / 2);
			for (var i:int = 1; i < LIMIT; i++) {
				this.graphics.moveTo(_wid * i / LIMIT, -HEIGHT + 6);
				this.graphics.lineTo(_wid * i / LIMIT, -3);
			}
			repositionIcons();
		}
		private function repositionIcons():void {
			for (var i:int = 0; i < icons.length; i++) {
				var xx:int = (i % LIMIT) * (_wid / LIMIT) + (_wid / (2 * LIMIT)) - icon_wid / 2;
				var yy:int = int(i / LIMIT) * (-HEIGHT / 2) - (HEIGHT / 2) + 5;
				icons[i].x = xx;
				icons[i].y = yy;
				//
				labels[i].width = _wid / LIMIT;
				labels[i].x = (i % LIMIT) * (_wid / LIMIT);
				labels[i].y = int(i / LIMIT) * (-HEIGHT / 2) - 24 //-(HEIGHT / 2)+5;
			}
		}
		public function get currentLabel():String {
			return _currentLabel;
		}
	}
}

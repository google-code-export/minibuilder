package com.ideas.gui {
	import com.ideas.gui.scroller.ScrollerGraphic;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class WonderScrollerGraphic extends ScrollerGraphic {
		public static const HEIGHT:int = 120;
		public static const ICON:int = 100;
		private var txt:TextField = new TextField();
		private var dateTxt:TextField = new TextField();
		private var iconContainer:Sprite = new Sprite();
		private var icon:Loader
		private var format:TextFormat = new TextFormat("_sans", 24, 0xffffff, false);
		private var dateFormat:TextFormat = new TextFormat("_sans", 12, 0xcccccc, false, null, null, null, null, "right");
		private var _value:Object;
		private var _iconLoading:Boolean
		public function WonderScrollerGraphic() {
			dateTxt.x = txt.x = HEIGHT;
			txt.height = ICON;
			dateTxt.height = 16;
			txt.y = 10;
			txt.selectable = false;
			txt.defaultTextFormat = format;
			txt.multiline = true;
			txt.wordWrap = true;
			dateTxt.y = HEIGHT - 10 - 16;
			dateTxt.defaultTextFormat = dateFormat;
			addChild(txt);
			this.addChild(dateTxt);
			this.addChild(iconContainer);
		}
		override public function clear():void {
			if (icon) {
				icon.unloadAndStop();
				onError(null);
			}
		}
		override public function setData(value:Object):void {
			_value = value;
			if(icon && _iconLoading){
				onError(null);
				icon.unloadAndStop();
			}
			if (!_value) {
				return;
			}
			var date:Date = new Date(Number(_value.date) * 1000);
			txt.text = _value.title
			dateTxt.text = "Created: " + date.toLocaleString();
			while (iconContainer.numChildren) {
				iconContainer.removeChildAt(0);
			}
			if (_value.icon) {
				addItem(_value.icon);
				return;
			}
			if (_value.thumbnail && _value.thumbnail.length > 10) {
				icon = new Loader();
				icon.contentLoaderInfo.addEventListener(Event.COMPLETE, onIconDone);
				icon.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				_iconLoading=true;
				icon.load(new URLRequest(value.thumbnail));
			}
		}
		private function onError(e:Event):void {
			_iconLoading=false;
			icon.contentLoaderInfo.removeEventListener(Event.COMPLETE, onIconDone);
			icon.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		private function addItem(item:DisplayObject):void {
			if (!_value || !item) {
				return;
			}
			iconContainer.addChild(item);
			_value.icon = item;
			item.width = item.height = ICON;
			item.x = item.y = (HEIGHT - ICON) / 2;
		}
		private function onIconDone(e:Event):void {
			addItem(icon);
			onError(e);
		}
		override public function redraw(state:Boolean):void {
			format.color = state ? 0x000000 : 0xffffff;
			dateTxt.width = txt.width = _width - HEIGHT - 10;
			if (txt.length > 0) {
				txt.setTextFormat(format, 0, txt.length);
			}
			this.graphics.clear();
			this.graphics.lineStyle(0, 0xcccccc);
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(HEIGHT, HEIGHT, Math.PI / 2, 0, 0);
			this.graphics.beginGradientFill("linear", state ? [ 0x8c4600, 0xff8000 ] : [ 0x555555, 0x0 ], [ 1, 1 ], [ 0, 0xff ], mtrx);
			this.graphics.drawRect(0, 0, _width, HEIGHT);
			this.graphics.endFill();
			this.cacheAsBitmap = true;
		}
	}
}

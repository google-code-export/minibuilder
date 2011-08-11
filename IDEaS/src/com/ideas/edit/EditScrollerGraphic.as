package com.ideas.edit {
	import com.ideas.data.Resources;
	import com.ideas.gui.scroller.ScrollerGraphic;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class EditScrollerGraphic extends ScrollerGraphic {
		public static const WIDTH:int = 60;
		public static const CELL:int = 54;
		public static const ICON:int = 30;
		private var txt:TextField = new TextField();
		private var icon:Bitmap;
		private var format:TextFormat = new TextFormat("_sans", 12, 0xffffff, false, null, null, null, null, "center");
		public function EditScrollerGraphic() {
			addChild(txt);
			txt.height = 30;
			txt.width = WIDTH;
			txt.y=2;
			txt.selectable = false;
			txt.defaultTextFormat = format;
			txt.alpha = 0.8;
		}
		override public function setData(value:Object):void {
			txt.text = value.title.toString();
			if (icon && icon.parent == this) {
				this.removeChild(icon);
			}
			icon = value.icon;
			icon.smoothing = true;
			icon.width = icon.height = ICON;
			icon.x = (WIDTH - ICON) / 2;
			icon.y = 22;
			addChildAt(icon, 0);
		}
		override public function redraw(state:Boolean):void {
			this.graphics.clear();
			this.graphics.beginFill(0,0.0001)
			this.graphics.drawRect(0,0,WIDTH,WIDTH);
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(WIDTH, WIDTH, Math.PI / 2, 0, 0);
			this.graphics.lineStyle(1, 0xcccccc, 1, true);
			this.graphics.beginGradientFill("linear", state ? [ 0x8c4600, 0xff8000 ] : [ 0x555555, 0x0 ], [ 1, 1 ], [ 0, 0xff ], mtrx);
			this.graphics.drawRoundRect((WIDTH - CELL) / 2, (WIDTH - CELL) / 2-2, CELL, CELL, 8, 8);
			this.graphics.endFill();
		}
	}
}

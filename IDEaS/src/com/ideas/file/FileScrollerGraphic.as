package com.ideas.file {
	import com.ideas.data.Resources;
	
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.text.*;
	import com.ideas.gui.scroller.ScrollerGraphic;

	public class FileScrollerGraphic extends ScrollerGraphic {
		public static const HEIGHT:int = 80;
		public static const ICON:int = 60;
		private var txt:TextField = new TextField();
		private var icon:Bitmap;
		private var format:TextFormat= new TextFormat("_sans", 24, 0xffffff, false);
		public function FileScrollerGraphic() {
			
			txt.x = HEIGHT;
			txt.height = 50;
			txt.y = 25;
			txt.selectable = false;
			txt.defaultTextFormat =format;
			addChild(txt);
		}
		override public function setData(value:Object):void {
			if(!value){
				return;
			}
			txt.text = value.title; //(is_parent ? "../" : _file.name);
			if(icon && icon.parent==this){
				this.removeChild(icon);
			}
			if(!value.icon){
				if (value.isDirectory) {
					icon = new Resources.FolderIcon()
				} else {
					if (value.extension == "txt") {
						icon = new Resources.NoteIcon()
					} else if (value.extension == "as") {
						icon = new Resources.ActionScriptIcon()
					} else if (value.extension == "swf") {
						icon = new Resources.SwfIcon()
					} else {
						icon = new Resources.DocumentBlankIcon()
					}
				}
				if (value.is_parent) {
					icon = new Resources.FolderParentIcon();
				}
			
				value.icon=icon;
			}else{
				icon=value.icon;
			}
			icon.width = icon.height = ICON;
			icon.x = icon.y = (HEIGHT - ICON) / 2;
			addChild(icon);
		}
		override public function redraw(state:Boolean):void {
			format.color = state ? 0x000000 : 0xffffff;
			txt.width = _width - HEIGHT;
			if(txt.length>0){
				txt.setTextFormat(format, 0,txt.length);
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

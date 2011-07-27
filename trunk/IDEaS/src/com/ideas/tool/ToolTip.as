package com.ideas.tool {
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class ToolTip extends Sprite {
		private var defaultRoot:DisplayObjectContainer;
		public static const HEIGHT:int=20;
		public static const OFFSET:int=10;
		public var toolCaretIndex:int=0;
		private var _isShowing:Boolean=false;
		private var _yPos:int=0;
		private var _xPos:int=0;
		private var _textField:TextFieldScroll=new TextFieldScroll();
		private var _format:TextFormat=new TextFormat("_sans",14,0);
        public function ToolTip(defaultStage:DisplayObjectContainer) {
			defaultRoot=defaultStage;
			this.addChild(_textField);
			_textField.defaultTextFormat=_format;
			_textField.height=HEIGHT;
			_textField.x=OFFSET
			_textField.selectable=false;
			this.mouseChildren=false;
			this.mouseEnabled=false;
        }
		public function isShowing():Boolean {
            return _isShowing;
        }
		public function showToolTip():void {
			defaultRoot.addChild(this);
			_isShowing=true;
		}
		public function moveLocationRelatedTo(yPos:Number,xPos:Number):void{
			_yPos=yPos;
			_xPos=xPos;
			resize();
		}
		public function disposeToolTip():void {
			if(defaultRoot && this.parent){
				defaultRoot.removeChild(this);
			}
			toolCaretIndex=0;
			_isShowing=false;
        }
		public function setTipText(value:String):void {
			_textField.text=value;
			resize();
		}
		public function resize():void{
			if(!defaultRoot || !_isShowing){
				return;
			}
			
			this.y=_yPos;
			this.graphics.clear();
			this.graphics.lineStyle(2,0xff8000);
			this.graphics.beginFill(0xffff00,0.9);
			var maxWidth:int=Math.min(this.stage.stageWidth-OFFSET*2,_textField.textWidth+4);
			_textField.width=maxWidth;
			this.graphics.drawRoundRect(OFFSET,0,maxWidth,HEIGHT,5,5);
			this.graphics.endFill();
			this.x=_xPos;
			if(_xPos+maxWidth>this.stage.stageWidth-OFFSET*2 ){
				this.x=this.stage.stageWidth-maxWidth-OFFSET*2;
			}
		}
    }
}

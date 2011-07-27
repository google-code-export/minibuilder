package com.ideas.gui {
	import com.ideas.data.DataHolder;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	public class ToastNotification {
		public static var stage:Stage;
		private static var _textField:TextField;
		private static var _shape:Shape;
		private static var _time:Number;
		private static var _timeMax:Number;
		public static const OFFSET:int = 10;
		public static const SHOW_TIME:int = 5;
		public static const LENGTH_LONG:int = 5* 24;
		public static const LENGTH_SHORT:int = 3 * 24;
		public static function makeText(text:String, time:int = LENGTH_SHORT):void {
			_timeMax = _time = time;
			stage.addEventListener(Event.RESIZE, onResize);
			clear();
			_shape = new Shape();
			_shape.filters = [ DataHolder.SHADOW ]
			_textField = new TextField();
			_textField.defaultTextFormat = new TextFormat("_sans", 18, 0xcccccc, null, null, null, null, null, "center");
			_textField.text = text;
			_textField.multiline = true;
			_textField.wordWrap = true;
			_textField.selectable = false;
			_textField.autoSize = TextFieldAutoSize.LEFT
			_textField.mouseEnabled = false;
			_textField.addEventListener(Event.ENTER_FRAME, onTick, false, 0, false);
			_textField.alpha=_shape.alpha=0;
			stage.addChild(_shape);
			stage.addChild(_textField);
			
			resize();
		}
		private static function onResize(e:Event):void {
			resize();
		}
		private static function onTick(e:Event):void {
			_time--;
			
			if (_time <= 0) {
				clear();
			} else {
				if (stage.numChildren - 1 != stage.getChildIndex(_textField)) {
					stage.setChildIndex(_textField, stage.numChildren - 1);
					stage.setChildIndex(_shape, stage.numChildren - 2);
				}
				//
				var perc:Number=1
				if(_timeMax-_time<=SHOW_TIME){
					perc=Math.abs(_timeMax-_time)/SHOW_TIME;
				}
				if(_time<=SHOW_TIME){
					perc=_time/SHOW_TIME;
					
				}
				_shape.alpha=perc;
				_textField.alpha=perc;
			}
		}
		private static function clear():void {
			if (_textField) {
				_textField.removeEventListener(Event.ENTER_FRAME, onTick);
				stage.removeChild(_textField);
				_textField = null;
			}
			if (_shape) {
				_shape.graphics.clear();
				stage.removeChild(_shape);
				_shape = null;
			}
		}
		private static function resize():void {
			if(!_textField){
				return;
			}
			var maxWidth:int = Math.min(stage.stageWidth - OFFSET * 2, _textField.textWidth + 4);
			_textField.width = stage.stageWidth - OFFSET * 2;
			_textField.height = _textField.textHeight + 4;
			_textField.x = OFFSET;
			_textField.y = (stage.stageHeight - _textField.height) / 2
			_shape.graphics.clear();
			_shape.graphics.lineStyle(2, 0xcccccc, 1, true);
			_shape.graphics.beginFill(0x555555, 0.7);
			_shape.graphics.drawRoundRect((stage.stageWidth - _textField.textWidth - 8) / 2, _textField.y - 4, _textField.textWidth + 8, _textField.height + 8, 10, 10);
			_shape.graphics.endFill();
		}
	}
}

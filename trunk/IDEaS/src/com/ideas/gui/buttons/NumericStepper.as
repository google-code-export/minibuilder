package com.ideas.gui.buttons {
	import com.ideas.gui.TextContent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	public class NumericStepper extends Sprite {
		private var _upperLimit:int;
		private var _lowerLimit:int;
		private var _step:int;
		public static const LOWER_LIMIT:Number = 200;
		public static const HIGHER_LIMIT:Number = 1000;
		private var _timerDelay:int = HIGHER_LIMIT;
		private var textBox:TextContent = new TextContent();
		private var plusButton:PlusButton = new PlusButton(50, 50);
		private var minusButton:MinusButton = new MinusButton(50, 50);
		private var _direction:int = 0;
		private var _over:Boolean = false;
		//
		public function NumericStepper(lowerLimit:int = 0, upperLimit:int = 100, step:int = 1) {
			_upperLimit = upperLimit
			_lowerLimit = lowerLimit
			_step = step;
			this.addChild(plusButton);
			this.addChild(minusButton);
			this.addChild(textBox);
			plusButton.x = textBox.width + 10;
			minusButton.x = plusButton.x + plusButton.width + 10;
			plusButton.data = 1;
			minusButton.data = -1;
			this.plusButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.plusButton.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.plusButton.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//
			this.minusButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.minusButton.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.minusButton.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		public function setValue(value:int):void {
			textBox.text = value.toString();
		}
		public function getValue():int {
			return int(textBox.text);
		}
		private function onMouseOver(e:MouseEvent):void {
			_timerDelay = HIGHER_LIMIT;
			_direction = e.target.data;
			_over = true
		}
		private function onMouseOut(e:MouseEvent):void {
			_timerDelay = HIGHER_LIMIT;
			_over = false
		}
		private function onMouseDown(e:MouseEvent):void {
			_direction = e.target.data;
			_timerDelay = HIGHER_LIMIT;
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			increase();
		}
		private function onUp(e:MouseEvent):void {
			_direction = 0;
			_timerDelay = HIGHER_LIMIT;
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			}
		}
		private function increase():void {
			if (_direction == 0) {
				_timerDelay = HIGHER_LIMIT;
				return;
			}
			setTimeout(increase, _timerDelay);
			if (!_over) {
				_timerDelay = HIGHER_LIMIT;
				return;
			}
			_timerDelay=_timerDelay<LOWER_LIMIT?LOWER_LIMIT:(_timerDelay - 100);
			
			var num:int = int(textBox.text);
			if (num > _lowerLimit && _direction < 0) {
				num += _step * _direction;
			} else if (num < _upperLimit && _direction > 0) {
				num += _step * _direction;
			}
			textBox.text = num.toString();
		}
	}
}

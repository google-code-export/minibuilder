package com.ideas.gui.buttons {
	import com.ideas.gui.TextContent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	public class NumericStepper extends Sprite {
		private var _upperLimit:int;
		private var _lowerLimit:int;
		private var _step:int;
		private var textBox:TextContent = new TextContent();
		private var plusButton:PlusButton = new PlusButton(50, 50);
		private var minusButton:MinusButton = new MinusButton(50, 50);
		//
		public function NumericStepper(lowerLimit:int = 0, upperLimit:int = 100,step:int=1) {
			_upperLimit = upperLimit
			_lowerLimit = lowerLimit
			_step=step;
			this.addChild(plusButton);
			this.addChild(minusButton);
			this.addChild(textBox);
			plusButton.x=textBox.width+10;
			minusButton.x=plusButton.x+plusButton.width+10;
			this.plusButton.addEventListener(MouseEvent.CLICK, onPlusClick);
			this.minusButton.addEventListener(MouseEvent.CLICK, onMinusClick);
		}
		public function setValue(value:int):void {
			textBox.text = value.toString();
		}
		public function getValue():int {
			return int(textBox.text);
		}
		private function onPlusClick(e:MouseEvent):void {
			var num:int = int(textBox.text);
			if (num < _upperLimit) {
				num+=_step;
			}
			textBox.text = num.toString();
		}
		private function onMinusClick(e:MouseEvent):void {
			var num:int = int(textBox.text);
			if (num > _lowerLimit) {
				num-=_step;
			}
			textBox.text = num.toString();
		}
	}
}

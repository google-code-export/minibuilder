/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.main.editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.aswing.JSharedToolTip;
	
	public class LineNumbers extends Sprite
	{
		private var fmt:TextFormat;
		private var box:Point;
		private static var cache:Array = [];
		private var begin:int;
		private var markLines:Array;
		private var markTips:Array;
		
		private var numbers:Sprite;
		private var marks:Sprite;
		
		
		public function LineNumbers(boxSize:Point, fmt:TextFormat)
		{
			this.fmt = fmt;
			box = boxSize;
			markLines = [];
			addChild(marks = new Sprite);
			addChild(numbers = new Sprite);
			hitArea = numbers;
			mouseChildren = false;
		}
		
		override public function get width():Number
		{
			return box.x * 5;
		}
		
		private function checkCreateItem(no:int):Bitmap
		{
			if (cache[no]) return new Bitmap(cache[no]);
			
			var tf:TextField = new TextField;
			tf.width = box.x * 5;
			var fmt2:TextFormat = new TextFormat;
			fmt2.align = 'right';
			tf.text = String(no);
			tf.setTextFormat(fmt);
			tf.setTextFormat(fmt2);
			
			var bd:BitmapData = new BitmapData(box.x * 5, box.y, true, 0x55ffffff);
			bd.draw(tf, new Matrix(1,0,0,1,-1,-1));
			cache[no] = bd;
			return new Bitmap(bd);
		}
		
		
		public function draw(begin:int, size:int, max:int):void
		{
			this.begin = begin;
			
			while (numbers.numChildren) numbers.removeChildAt(0);
			
			for (var i:int=0; i < size && (i+begin) < max; i++)
			{
				var bmp:Bitmap = checkCreateItem(i+begin+1);
				bmp.y = i * box.y;
				numbers.addChild(bmp);
			}
			
			numbers.graphics.clear();
			numbers.graphics.beginFill(0, .07);
			numbers.graphics.drawRect(0, 0, box.x*5, box.y*size);
			numbers.graphics.beginFill(0x6CE26C);
			numbers.graphics.drawRect(box.x * 5 - 3, 0, 3, box.y*size);
			numbers.graphics.endFill();
			
			drawMark();
		}
		
		
		
		public function mark(lines:Array, tips:Array):void
		{
			markLines = lines;
			markTips = tips;
			drawMark();
		}
		
		public function drawMark():void
		{
			while (marks.numChildren) marks.removeChildAt(0);
			for (var i:int=0; i< markLines.length; i++)
			{
				var m:Sprite = new Sprite;
				var markColor:uint = /^.?error/i.test(markTips[i]) ? 0xff0000 : 0xFF9705; 
				
				m.graphics.beginFill(markColor, 1);
				m.graphics.drawRect(0, 0, 4, box.y);
				m.graphics.beginFill(markColor, .1);
				//m.graphics.drawRect(2, 2, box.x*5-4, box.y-4);
				//m.graphics.beginFill(0, 0);
				m.graphics.drawRect(0, 0, stage.stageWidth, box.y);
				m.y = (markLines[i]-begin-1) * box.y;
				
				marks.addChild(m);
				JSharedToolTip.getSharedInstance().registerComponent(m, markTips[i]);
			}
		}
		
		
	}
}
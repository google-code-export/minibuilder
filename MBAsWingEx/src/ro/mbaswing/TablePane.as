package ro.mbaswing
{
	import org.aswing.Component;
	import org.aswing.Container;
	import org.aswing.FlowLayout;
	import org.aswing.Insets;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JSeparator;
	import org.aswing.LayoutManager;
	import org.aswing.border.EmptyBorder;
	import org.aswing.geom.IntDimension;
	
	import ro.victordramba.util.ArrayEx;
	
	public class TablePane extends JPanel implements LayoutManager
	{
		static public const ALIGN_LEFT:int =  1;
		static public const ALIGN_CENTER:int = 2;
		static public const ALIGN_RIGHT:int = 4;
		static public const EXPAND_H:int = 8;
		static public const ALIGN_TOP:int = 16;
		static public const ALIGN_MIDDLE:int = 32;
		static public const ALIGN_BOTTOM:int = 64;
		static public const EXPAND_V:int = 128;
		
		private var hGap:int;
		private var vGap:int;
		
		private var expandRow:int;
		private var expandCol:int;
		
		private var rows:Vector.<Vector.<Cell>>;
		private var colCount:int = 0;
		private var colSizes:Vector.<int>;
		
		private var userColSizes:Vector.<int>;
		
		public function TablePane(expandedColIndex:int=-1, expandedRowIndex:int=-1)
		{
			layout = this;
			hGap = vGap = 5;
			
			expandCol = expandedColIndex;
			expandRow = expandedRowIndex;
			
			rows = new Vector.<Vector.<Cell>>;
			userColSizes = new Vector.<int>;
			
			super.setLayout(this);
		}
		
		public function setColWidths(...widths):void
		{
			for (var i:int=0; i<widths.length; i++)
			{
				if (widths[i] == '*')
					expandCol = i;
				else
					userColSizes[i] = widths[i];
			}
		}
		
		public function setVGap(gap:int):void
		{
			if (vGap != gap) {
				vGap = gap;
				revalidate();
			}
		}
		
		public function getVGap():int
		{
			return vGap;
		}	
		
		public function setHGap(gap:int):void
		{
			if (hGap != gap) {
				hGap = gap;
				revalidate();
			}
		}
		
		public function getHGap():int
		{
			return hGap;
		}
		
		
		public static function hBox(gap:int, ...comps):Container
		{
			var p:JPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, gap, 0, false));
			for each(var i:Component in comps){
				p.append(i);
			}
			return p;
		}
		
		override public function setLayout(layout:LayoutManager):void 
		{
			throw new ArgumentError("Can't change the layout of FormEx!");
		}
		
		public function newRow(isExpanded:Boolean=false):void
		{
			if (rows.length == 0 || rows[rows.length-1].length != 0)
				rows.push(new Vector.<Cell>);//only add if needed
			if (isExpanded)
			{
				if (expandRow != -1 && rows.length-1 != expandRow) throw new ArgumentError('You can only set one expanded row.');
				expandRow = rows.length - 1;
			}
		}
		
		public function addSeparatorRow(height:int=10):void
		{
			newRow();
			var sep:JSeparator = new JSeparator();
			sep.setBorder(new EmptyBorder(null, new Insets(10)));
			addCell(sep, 136, colCount);
			newRow();
		}
		
		public function addCell(component:Component, constraints:int=136, colspan:int=1):void
		{
			if (rows.length == 0) newRow();
			rows[rows.length-1].push(new Cell(component, constraints, colspan));
			colCount = Math.max(colCount, rows[rows.length-1].length);
			
			if (component)
				append(component);
			
			for (var i:int=0; i<colspan-1; i++)
				addCell(null);
		}
		
		public function addLabel(text:String, constraints:int=136, colspan:int=1):JLabel
		{
			var label:JLabel = new JLabel(text, null, JLabel.LEFT);
			addCell(label, constraints, colspan);
			return label;
		}
		
		private function computeColSizes():void
		{
			colSizes = new Vector.<int>;
			for (var i:int=0; i<colCount; i++)
			{
				colSizes[i] = i < userColSizes.length ? userColSizes[i] : 0;
			}
			
			for (var row:int=0; row<rows.length; row++)
			{
				var spans:Array = [];
				for (var col:int=0; col<colCount; col++)
				{
					if (col == rows[row].length) break;
					var cell:Cell = rows[row][col];
					if (spans[col])
					{
						colSizes[col] = Math.max(colSizes[col], 0);//spans[col]);
					}
					else if (cell.span > 1)
						spans[col+cell.span-1] = cell.component.getPreferredWidth();
					else if (cell.component)
						colSizes[col] = Math.max(colSizes[col], cell.component.getPreferredWidth());
				}
			}
		}
		
		private var rowHeights:Vector.<int>;
		
		private function computeRowHights():void
		{
			rowHeights = new Vector.<int>;
			for (var row:int=0; row<rows.length; row++)
			{
				rowHeights[row] = 0;
				for (var col:int=0; col<colCount; col++)
				{
					if (col == rows[row].length) break;
					var cell:Cell = rows[row][col];
					if (cell.component)
						rowHeights[row] = Math.max(rowHeights[row], cell.component.getPreferredHeight());
				}
			}
		}
		
		public function preferredLayoutSize(target:Container):IntDimension
		{
			computeColSizes();
			computeRowHights();
			
			var width:int = ArrayEx.sum(colSizes) + hGap * (colCount - 1);
			var height:int = ArrayEx.sum(rowHeights) + vGap * (rows.length -1);
			
			var dim:IntDimension = new IntDimension(width, height);
			return getInsets().getOutsideSize(dim);
		}
		
		public function maximumLayoutSize(target:Container):IntDimension
		{
			return IntDimension.createBigDimension();
		}
	
		public function layoutContainer(target:Container):void
		{
			var insets:Insets = getInsets();
			var w:int = getWidth() - insets.getMarginWidth();
			var h:int = getHeight() - insets.getMarginHeight();
			computeColSizes();
			computeRowHights();
			if (expandCol != -1)
			{
				colSizes[expandCol] = 0;
				colSizes[expandCol] = w - ArrayEx.sum(colSizes) - hGap*(colCount-1);
			}
			if (expandRow != -1)
			{
				rowHeights[expandRow] = 0;
				rowHeights[expandRow] = h - ArrayEx.sum(rowHeights) - vGap*(rows.length-1);
			}
			
			var sy:int = insets.top;
			for (var row:int=0; row<rows.length; row++)
			{
				var sx:int = insets.left;
				for (var col:int=0; col<colCount; col++)
				{
					var cell:Cell = col < rows[row].length ? rows[row][col] : null;
					if (cell && cell.component)
					{
						var cellW:int = 0;
						for (var j:int=col; j<col+cell.span; j++)
							cellW += colSizes[j] + hGap;
						cellW -= hGap;
						
						var cx:int, cy:int, cw:int, ch:int;
						//width
						if (cell.constraints & EXPAND_H)
							cw = cellW;
						else
							cw = cell.component.getPreferredWidth();
						
						//height
						if (cell.constraints & EXPAND_V)
							ch = rowHeights[row];
						else
							ch = cell.component.getPreferredHeight();
						
						//position x
						if (cell.constraints & ALIGN_RIGHT)
							cx = sx + cellW - cell.component.getPreferredWidth();
						else if (cell.constraints & ALIGN_CENTER)
							cx = sx + (cellW-cell.component.getPreferredWidth())/2;
						else//left or expand
							cx = sx;
						
						//position y
						if (cell.constraints & ALIGN_BOTTOM)
							cy = sy + rowHeights[row] - cell.component.getPreferredHeight();
						else if (cell.constraints & ALIGN_MIDDLE)
							cy = sy + (rowHeights[row] - cell.component.getPreferredHeight())/2;
						else//left or expand
							cy = sy;
						cell.component.setComBoundsXYWH(cx, cy, cw, ch);
					}
					sx += colSizes[col] + hGap;
				}
				sy += rowHeights[row] + vGap;
			}
		}

		public function removeLayoutComponent(comp:Component):void{
		}
		
		public function getLayoutAlignmentY(target:Container):Number{
			return getAlignmentY();
		}
		
		public function getLayoutAlignmentX(target:Container):Number{
			return getAlignmentX();
		}
		public function addLayoutComponent(comp:Component, constraints:Object):void{
		}
		
		public function invalidateLayout(target:Container):void{
		}
		
		public function minimumLayoutSize(target:Container):IntDimension{
			return getInsets().getOutsideSize(new IntDimension(0, 0));;
		}
	}
}



import org.aswing.Component;

class Cell
{
	function Cell(component:Component, constraints:int, span:int)
	{
		this.component = component;
		this.constraints = constraints;
		this.span = span;
	}
	public var component:Component;
	public var constraints:int;
	public var span:int;
}
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

package ro.minibuilder.main
{
	import __AS3__.vec.Vector;
	
	import org.aswing.JTree;
	import org.aswing.tree.DefaultMutableTreeNode;
	import org.aswing.tree.DefaultTreeModel;
	import org.aswing.tree.GeneralTreeCellFactory;
	import org.aswing.tree.TreePath;

	public class MBTree extends JTree
	{
		private var _filter:RegExp;
		
		function MBTree()
		{
			setCellFactory(new GeneralTreeCellFactory(Cell));
			
			setModel(new DefaultTreeModel(new DefaultMutableTreeNode('')));
			setRootVisible(false);
		}
		
		public function set filter(re:RegExp):void
		{
			_filter = re;
		}
		
		private var savedExpanded:Array;
		
		public function loadPlainList(paths:Vector.<String>):void
		{
			//save expanded
			savedExpanded = getExpandedDescendants(new TreePath([getModel().getRoot()]));
			
			var model:DefaultTreeModel = new DefaultTreeModel(new DefaultMutableTreeNode('Project'));
			setModel(model);
			setRootVisible(false);
			
			var o:Object = {};
			var entry:String;
			for each (entry in paths)
			{
				entry = entry.replace('://', '/');
				var path:Array = entry.split('/');
				
				//filter
				var found:Boolean = false;
				for each (var nn:String in path)
					if (_filter && nn.match(_filter))
					{
						found = true
						break;
					}
				if (found) continue;

				
				var name:String = path.pop();
				if (name.length == 0) name = path.pop();
				if (!name) continue;
				
				
				var oo:Object = o;
				for each (var dir:String in path)
				{
					if (!oo[dir]) oo[dir] = {};
					oo = oo[dir];
					oo.__dir__ = true;
				}
				oo[name] = {};
			}
			
			var root:DefaultMutableTreeNode = model.getRoot() as DefaultMutableTreeNode;
			recBuildTree(root, o);				
			model.nodeStructureChanged(root);
			
			if (savedExpanded && savedExpanded.length)
			{
				//TODO this is not optimal
				var enum:Array = root.breadthFirstEnumeration();
				var n:DefaultMutableTreeNode;
				for each (var tp:TreePath in savedExpanded)
					for each (n in enum)
					{
						var tp1:TreePath = new TreePath(n.getPath());
						if (String(tp1) == String(tp))
							setExpandedState(tp1, true);
					}
			}
		}
		
		static private function recBuildTree(node:DefaultMutableTreeNode, o:Object):void
		{
			var a:Array = [];
			var b:Array = [];
			for (var name:String in o)
			{
				if (name == '__dir__') continue;
				(o[name].__dir__ ? a : b).push(name);
			}
			a.sort();
			b.sort();
			
			for each (name in a.concat(b))
			{
				var n:DefaultMutableTreeNode = new DefaultMutableTreeNode(name);
				node.append(n);
				recBuildTree(n, o[name]);
			}
		}
		
		public function getSelectedFilePath():String
		{
			var sel:TreePath = getSelectionModel().getSelectionPath();
			if (!sel) return null;
			var aPath:Array = sel.getPath();
			aPath.shift();
			return aPath.join('/');
		}
		
		public function setSelectedPath(path:String):void
		{
			var root:DefaultMutableTreeNode = getModel().getRoot() as DefaultMutableTreeNode;
			path = root.getUserObject() + '/' + path.replace(/\\/g,'/');
			//TODO this is not optimal
			var enum:Array = root.breadthFirstEnumeration();
			for each (var n:DefaultMutableTreeNode in enum)
			{
				//debug('c '+n.getUserObjectPath().join('/') + '=' + path);
				if (n.getUserObjectPath().join('/') == path)
				{
					var a:Array = n.getPath();
					expandPath(new TreePath(a.slice(0, a.length-1)));
					setSelectionPath(new TreePath(a), true);
					break;
				}
			}
		}
	}
}
import org.aswing.tree.DefaultTreeCell;
import org.aswing.Icon;
import ro.minibuilder.main.Skins;
import ro.minibuilder.main.editor.EditorMap;

class Cell extends DefaultTreeCell
{
	override public function getCollapsedFolderIcon():Icon
	{
		return Skins.icnFolder();
	}
	override public function getExpandedFolderIcon():Icon
	{
		return Skins.icnFolderOpen();
	}
		
	override public function getLeafIcon():Icon
	{
		var icn:Icon = EditorMap.getIcon(getCellValue());
		return icn ? icn : super.getLeafIcon();
	}
}
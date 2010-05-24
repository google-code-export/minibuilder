/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.Flash MiniBuilder is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.© Victor Dramba 2010*/

package ro.minibuilder.main.additem
{
	import flash.events.Event;
	
	import ro.minibuilder.data.IProjectPlug;
	import ro.minibuilder.main.ActionManager;

	public class AddPackage extends AbstractAdd
	{
		static private var inst:AbstractAdd;
		static public function show(project:IProjectPlug, path:String):void
		{
			if (!inst) inst = new AddPackage;
			inst.init(project, path);
		}
		
		override protected function getFilePath():String
		{
			return path + '/' + nameTxt.getText();
		}
		
		public function AddPackage()
		{
			label.setText('Package Name');
			regex = /^[_a-z]\w*$/;
		}
		
		override protected function doAction(e:Event=null):void
		{
			var file:String = getFilePath();
			project.newDir(file, function():void {
				ActionManager.inst.doRefreshProject();
			});
		}
	}
}
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
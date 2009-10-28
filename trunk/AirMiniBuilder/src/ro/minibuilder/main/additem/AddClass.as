package ro.minibuilder.main.additem
{
	import ro.minibuilder.data.Constants;
	import ro.minibuilder.data.IProjectPlug;

	public class AddClass extends AbstractAdd
	{
		static private var inst:AbstractAdd;
		static public function show(project:IProjectPlug, path:String):void
		{
			if (!inst) inst = new AddClass;
			inst.init(project, path);
		}
		
		public function AddClass()
		{
			label.setText('Class Name');
			regex = /^[_A-Z]\w*$/;
			template = Constants.classTpl;
		}
	}
}
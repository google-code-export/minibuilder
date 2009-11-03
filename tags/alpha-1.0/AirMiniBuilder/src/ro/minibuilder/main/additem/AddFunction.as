package ro.minibuilder.main.additem
{
	import ro.minibuilder.data.Constants;
	import ro.minibuilder.data.IProjectPlug;

	public class AddFunction extends AbstractAdd
	{
		static private var inst:AbstractAdd;
		static public function show(project:IProjectPlug, path:String):void
		{
			if (!inst) inst = new AddFunction;
			inst.init(project, path);
		}
		
		public function AddFunction()
		{
			label.setText('Function Name');
			regex = /^[_a-z]\w*$/;
			template = Constants.functionTpl;
		}
	}
}
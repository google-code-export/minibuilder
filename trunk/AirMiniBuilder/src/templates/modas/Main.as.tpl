package
{
	import modas.HTTP;
	import modas.out;
	import ${PACKAGE}.*;
	
	public class Main
	{
		public static function main():void
		{
			var pages:Object = {
				helo: Helo,
				form: Form,
				upload: FileUpload,
				tal: Tal
			};
			
			if (HTTP.GET.page in pages)
				new (pages[HTTP.GET.page[0]]);
			else
				new Home;
		}
	}
}
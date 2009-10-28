package ${PACKAGE}
{
	import modas.out;
	
	public class Helo
	{
		public function Helo()
		{
			out('Content-type: text/html; charset=utf-8\n\n');
			out('Salut from ActionScript!<br>');
			out('Output is UTF-8 encoded. Here are some chars: ö€șț');
		}
	}
}
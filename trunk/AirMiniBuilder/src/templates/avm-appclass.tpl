package ${PACKAGE}
{
	/**
	 * Application entry-point
	 */
	public class Application
	{
		public function Application()
		{
			print('Salut from AVM2 Tamarin');
		}
	}
	
	//add this init code in each class in a Tamarin targeted project
	//see http://code.google.com/p/minibuilder/wiki/AVM2ProjectStater
	Starter.init();
}
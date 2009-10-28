package ${PACKAGE}
{
	import modas.Header;
	import modas.outXHTML;
	
	public class Home
	{
		public function Home()
		{
			XML.ignoreWhitespace = false;
			var html:XML = 
				<html>
					<head>
						<title>Mod ActionScript Examples</title>
					</head>
					<body>
						Here are a few basic example pages made with Mod Actionscript<br/>
						<small><em>Mod ActionScript</em> is solution to run ActionScript on server-side
						under a FastCGI compatible web-server</small>  
						<hr/>
						<ul>
							<li><a href="?page=helo">Hello World</a></li>
							<li><a href="?page=form">Form</a></li>
							<li><a href="?page=upload">File Upload</a></li>
							<li><a href="?page=tal">TAL Template</a></li>
						</ul>
					</body>
				</html>;
				
			Header.add(Header.CONTENT_TYPE_HTML);
			Header.out();
			outXHTML(html);
		}
	}
}
package ${PACKAGE}
{
	import avmplus.File;
	
	import modas.Header;
	import modas.outXHTML;
	import modas.tal.AS_TAL;
	
	public class Tal
	{
		public function Tal()
		{
			XML.ignoreWhitespace = false;
			XML.ignoreComments = false;
			
			//Normaly, you would load the template  from disk, something like this:
			//var html:XML = XML(File.read('template.tal.html'));
				
			
			var html:XML = 
				<html xmlns:tal="http://xml.zope.org/namespaces/tal">
					<head>
						<title>Mod ActionScript Examples: Form</title>
						<style type="text/css"><!--
							.red { color: red }
						--></style>
					</head>
					<body>
						TAL Template example<br/>
						<small>Basic tags support: content, replace, attributes, repeat. Basic TALES support.<br/>
						<a href="?page=">Back to examples</a></small>
						<hr/>
						Content: <span class="cls1" tal:content="content1">test</span><br/>
						Replace: <h1 tal:replace="replace1">test</h1><br/>
						Attributes: <span tal:attributes="class myClass">Styled Text</span><br/>
						Repeat:<br/>
						<ul tal:repeat="item list1">
							<li><span tal:replace="item"/> Item</li>
						</ul><br/>
						String: <span tal:content="string: var1 equals $var1"/>
					</body>
				</html>;
				
				var data:Object = {
					content1: 'My Content',
					replace1: 'My Replacement',
					myClass: 'red',
					list1: ['First', 'Fecond', 'Third'],
					var1: 100
				}
				
				Header.add(Header.CONTENT_TYPE_HTML);
				Header.out();
				AS_TAL.process(html, data);
				outXHTML(html);
		}
	}
}
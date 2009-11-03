package ${PACKAGE}
{
	import modas.HTTP;
	import modas.Header;
	import modas.outXHTML;
	import modas.textXML;
	
	public class Form
	{
		public function Form()
		{
			XML.ignoreWhitespace = false;
			XML.ignoreComments = false;
			XML.prettyPrinting = false;
			
			var data:XML = <div/>;
			if (HTTP.getEnv('REQUEST_METHOD') == 'POST')
			{
				data.appendChild(<div>Posted data</div>);
				for (var key:String in HTTP.POST)
				{
					var item:XML = <div/>;
					//the textXML utility creates an XML text node
					item.appendChild(textXML(key + '=' + HTTP.POST[key]));
					data.appendChild(item);
				}
				
				//here's an example of how to test a POST variable
				//HTTP.POST.check is an Array (!), but it's converted to string prior to equality check
				data.appendChild(<div><br/>Only check1 is checked: {HTTP.POST.check == 'check1'}</div>);
			}
			
			
			var html:XML = 
				<html>
					<head>
						<title>Mod ActionScript Examples: Form</title>
						<style type="text/css"><!--
							td {
								vertical-align: top;
							}
						--></style>
					</head>
					<body>
						From example<br/>
						<small>Simple POST form. See the submited values below.<br/>
						<a href="?page=">Back to examples</a></small>
						<hr/>
						<form method="post" action="?page=form">
							<table cellspacing="5">
								<tr>
									<td>Text field 1</td>
									<td><input type="text" name="field1"/></td>
								</tr>
								<tr>
									<td>Text field 2</td>
									<td><input type="text" name="field2"/></td>
								</tr>
								<tr>
									<td>Text area</td>
									<td><textarea name="field3"/></td>
								</tr>
								<tr>
									<td>Checkboxes</td>
									<td>
										<input type="checkbox" name="check" value="check1" id="c1"/><label for="c1">check1</label><br/>
										<input type="checkbox" name="check" value="check2" id="c2"/><label for="c2">check2</label><br/>
										<input type="checkbox" name="check" value="check3" id="c3"/><label for="c3">check3</label><br/>
									</td>
								</tr>
								<tr>
									<td/>
									<td align="right"><input type="submit" value="Submit"/></td>
								</tr>
							</table>
						</form>
						{data}
					</body>
				</html>;
				Header.add(Header.CONTENT_TYPE_HTML);
				Header.out();
				outXHTML(html);
		}
	}
}
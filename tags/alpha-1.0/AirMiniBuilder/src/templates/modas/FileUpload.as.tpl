package ${PACKAGE}
{
	import avmplus.File;
	import avmplus.System;
	
	import modas.HTTP;
	import modas.Header;
	import modas.Upload;
	import modas.outXHTML;
	import modas.textXML;
	
	public class FileUpload
	{
		public function FileUpload()
		{
			XML.ignoreWhitespace = false;
			XML.ignoreComments = false;
			XML.prettyPrinting = false;
			
			var msg:String = '';
			if (Upload.isUploaded('file1'))
			{
				System.exec('rm saved.jpg');
				if (Upload.getFileSize('file1') < 2e5 /*Max ~200K*/)
				{
					try {
						Upload.saveFile('file1', 'saved.jpg');
					} catch (e:Error) {
						msg = "Saving uploaded file failed. Check directory write permissions.";
					}
				}
				else
					msg = "Uploaded file is too large";
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
						File Upload example<br/>
						<small>Multipart encoded form.<br/>
						<a href="?page=">Back to examples</a></small>
						<hr/>
						<form method="post" enctype="multipart/form-data" action="?page=upload">
							<table cellspacing="5">
								<tr>
									<td>Text field 1</td>
									<td><input type="text" name="field1"/></td>
								</tr>
								<tr>
									<td>Upload JPEG Image</td>
									<td><input type="file" name="file1"/></td>
								</tr>
								<tr>
									<td/>
									<td align="right"><input type="submit" value="Submit"/></td>
								</tr>
							</table>
						</form>
						Field1: {textXML(HTTP.POST.field1)}<br/>
						<br/>
						Uploaded Image:<br/>
						{File.exists('saved.jpg') ? <img src={'saved.jpg?'+(new Date).getTime()}/> : ''}<br/>
						<span style="color:red">{msg}</span>
					</body>
				</html>;
				Header.add(Header.CONTENT_TYPE_HTML);
				Header.out();
				outXHTML(html);
		}
	}
}
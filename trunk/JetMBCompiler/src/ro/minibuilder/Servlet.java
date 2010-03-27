package ro.minibuilder;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import flex2.tools.oem.Application;
import flex2.tools.oem.ProgressMeter;

public class Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void init() throws ServletException {
		//make sure we have "application.home" set. it is set by an Application static block.
		new Application();
		
		log("MB STARTUP");
	}
	
	/** GET */
	protected void doGet(HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
		
		
		//get a file (SWC) from the SDK
		String value; 
		if ((value = request.getParameter("file")) != null)
		{
			File file = new File(System.getProperty("application.home") + File.separator + value);
			log("get file: " + file.getCanonicalPath());
			
			response.setContentType("application/octet-stream");
			response.setContentLength((int) file.length());
			BufferedInputStream in = new BufferedInputStream(new FileInputStream(file));
			int length;
			byte[] buf = new byte[4096];
			while ((in != null) && ((length = in.read(buf)) != -1))
				response.getOutputStream().write(buf,0,length);
			response.getOutputStream().close();
		}
		else if ((value = request.getParameter("log")) != null)
		{
			//get command log
			PrintWriter out = response.getWriter();
			response.setContentType("text/plain");
			out.write(cmdResults.get(value));
			out.close();
			//System.out.println("get log:"+cmdResults.get(value));
			cmdResults.remove(value);
		}
		else
		{
			//ping
			PrintWriter out = response.getWriter();
			response.setContentType("text/plain");
			out.write("ok");
			log("ping");
			out.close();
		}
	}
	
	private static HashMap<String, String> cmdResults = new HashMap<String, String>();
	
	/** POST */
	protected void doPost(HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
		//XML xml = XML.create(new ByteArrayInputStream(cmd.getBytes()));
		
		BufferedInputStream in = new BufferedInputStream(request.getInputStream());
		XML xml = XML.create(in);
		for (String key : xml.attributes().keySet())
			System.out.println(key + '=' + xml.attribute(key));
		
		if ("compile".equals(xml.attribute("name")))
			doCompile(xml, response);
		else if ("exec".equals(xml.attribute("name")))
		{
			ArrayList<String> cmd = new ArrayList<String>();
			cmd.add(xml.attribute("command"));
			for (XML arg : xml.children("arg"))
				cmd.add(arg.content());
			Runtime.getRuntime().exec(cmd.toArray(new String[cmd.size()]));
		}
	}
	
	protected void doCompile(XML xml, final HttpServletResponse response) throws ServletException, IOException {
		
		response.setContentType("text/plain");
		
		
		
		class ProgressHelper {
			public int last = 0;
			public void set(int value) {
				if (value <= last) return;
				try {
					for (int i=last; i<value; i++)
						response.getOutputStream().print("*");
					response.getOutputStream().flush();
				} catch (IOException e) { }
				last = value;
			}
		}
		final ProgressHelper ph = new ProgressHelper();
		
		//we output 101 chars so we can track progress without sending actual data
		response.setContentLength(101);
		
		String log = CompileManager.inst().compile(xml, new ProgressMeter() {
			
			public void start() { }
			
			public void percentDone(int p) {
				ph.set(p);
			}
			
			public void end() {
				ph.set(100);
			}
		});
		ph.set(101);
		
		cmdResults.put(xml.attribute("id"), log);
	}
}

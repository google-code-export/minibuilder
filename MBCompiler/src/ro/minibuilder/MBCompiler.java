package ro.minibuilder;

import flex2.tools.oem.Application;
import flex2.tools.oem.Configuration;

import java.io.*;
import java.util.HashMap;

import net.contentobjects.jnotify.JNotify;
import net.contentobjects.jnotify.JNotifyListener;


//java/MyAppCompiler.java
public class MBCompiler 
{
	private static HashMap<String, Application> apps = new HashMap<String, Application>();
	private static File msgDir;
	private static File cmdFile;
	private static File qCmdFile;
	private static boolean verbose = true;
	
    public static void main(String[] args) throws InterruptedException, IOException 
    {
    	if (args.length > 0 && args[0].equals("-nv"))
    		verbose = false;
    	
    	msgDir = new File(System.getProperty("user.home") + File.separator + ".mbcompiler/msg");
    	
    	final File presenceFile = new File(msgDir.getPath() + File.separator + "mbclive");
    	presenceFile.createNewFile();
    	
    	if (!msgDir.isDirectory() && !msgDir.mkdirs())
    	{
    		System.err.println("Can't create "+msgDir);
    		System.err.println("Make sure path is writable");
    		return;
    	}
    	
    	if (System.getProperty("application.home") == null)
    	{
    		System.err.println("Add -Dapplication.home argument to jvm. It should point to SDK root dir");
    		return;
    	}
    	
		//delete old commands
		if (msgDir.isDirectory())
		{
			for (File f : msgDir.listFiles())
				if (f.getName().startsWith("command-"))
					f.delete();
		}

    	
    	System.out.println("MiniBuilder Compilation server started.");
    	if (verbose) System.out.println("Verbose");
    	System.out.println("Listening to " + msgDir);
    	
    	try {
			JNotify.addWatch(msgDir.getCanonicalPath(), JNotify.FILE_CREATED|JNotify.FILE_DELETED, false, new JNotifyListener()
			{
				public void fileRenamed(int wd, String rootPath, String oldName, String newName) {}
				public void fileModified(int wd, String rootPath, String name) {}
				public void fileDeleted(int wd, String rootPath, String name) 
				{
					if ("mbclive".equals(name))
						System.exit(0);
				}

				public void fileCreated(int wd, String rootPath, String name)
				{
					if (name.equals("stop"))
					{
						try { Thread.sleep(50); } catch (InterruptedException e) {}
						System.out.println("Server stopped gracefully");
						new File(msgDir + File.separator + name).delete();
						System.exit(0);
					}
					
					if (name.startsWith("command-"))
					{
						File file = new File(msgDir + File.separator + name);
						if (cmdFile == null)
							cmdFile = file;
						else
							qCmdFile = file;
					}
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
		}
    	
    	while(true)
    	{
    		Thread.sleep(50);
    		if (cmdFile != null)
    		{
    			try {
					doCommand(cmdFile);
				} catch (Exception e) {
					e.printStackTrace();
				}
				cmdFile.delete();
				cmdFile = null;
    		}
    		if (qCmdFile != null)
    		{
    			cmdFile = qCmdFile;
    			qCmdFile = null;
    		}
    	}
    }
    
    static void doCommand(File file) throws Exception
    {
    	//if the file was not written entirely, we get an exception here. so we retry later
    	XML xml = null;
    	try {
    		xml = new XML(file.getCanonicalPath(), "command");
    	} catch (Exception e) {
    		Thread.sleep(100);
    		doCommand(file);
    		return;
    	}
    	if (verbose)
    		System.out.println(file.getCanonicalPath());
    	
    	String doName = xml.string("name");
    	if (doName.equals("exec"))
    		doExec(xml);
    	else if (doName.equals("compile"))
    		doCompile(xml, file.getName());
    	else if (doName.equals("ping"))
    		new File(xml.string("log")).delete();
    }
    
    static private void doExec(XML xml)
    {
    	String cmd = xml.string("command");
    	if (cmd == null)
    	{
    		System.err.println("Error: No command attribute in xml");
    		return;
    	}
    	
    	if (verbose)
    		System.out.println("Execute " + cmd);
    	
    	try {
			Runtime.getRuntime().exec(cmd);
		} catch (IOException e) {
			e.printStackTrace();
		}
    }
    
    static private void doCompile(XML xml, String id)
    {
    	
    	String mainApplication = xml.string("mainApplication");
        String configFile = xml.string("configFile");
        String outPath = xml.string("out");
        //String targetConf = xml.string("target");
        String clean = xml.string("clean");
        String logFile = xml.string("log");
        
        if (mainApplication == null)
        {
    		System.err.println("Error: No mainApplication attribute in xml");
    		return;
        }
        if (logFile == null || logFile.length() == 0)
        {
    		System.err.println("Error: No log attribute in xml");
    		return;
        }
        
    	File mainAppFile = new File(mainApplication);
		if (outPath == null)
			outPath = mainApplication.substring(0, mainApplication.lastIndexOf('.')) + ".swf";
		else if (!outPath.endsWith(".swf"))
		{
			String name = mainAppFile.getName();
			outPath = outPath + File.separator + name.substring(0, name.lastIndexOf('.')) + ".swf";
		}
       
    	if (verbose)
    		System.out.println("Compile " + mainApplication);
    	if (verbose)
    		System.out.println("out="+outPath);
        
        try {
        	Application app;
        	
        	String key = mainAppFile.getCanonicalPath();
        	if (clean != null && (clean.equals("yes") || clean.equals("1")))
        	{
            	if (verbose)
            		System.out.println("new application");
        		apps.remove(key);
        		new File(outPath).delete();
        	}
        	
        	if (apps.containsKey(key))
        	{
            	if (verbose)
            		System.out.println("incremental");
        		app = apps.get(key);
        	}
        	else
        	{
            	if (verbose)
            		System.out.println("new application");
	            app = new Application(mainAppFile);
	            apps.put(key, app);
        	}
        	MBLogger log;
            log = new MBLogger(logFile);
            app.setLogger(log);
            app.setProgressMeter(log);
            
            if (configFile != null)
            {
            	if (verbose)
            		System.out.println("override config:" + configFile);
	            Configuration conf = app.getDefaultConfiguration();
	            //conf.setConfiguration(new File(System.getProperty("application.home")+"/frameworks/flex-config.xml"));
	            conf.addConfiguration(new File(configFile));
	            app.setConfiguration(conf);
            }
            
            File outFile = new File(outPath);
            File outDir = new File(outFile.getParent());
            if (!outDir.isDirectory() && !outDir.mkdirs())
       		{
            	if (verbose)
                    System.out.println("COMPILE FAILED");
            	log.log("The output directory cannot be created.", -1, -1, "error", "", -1);
            	log.end(false);
            	return;
            }
	    	
            app.setOutput(outFile);
            
            long result = app.build(true);
        	if (verbose)
                System.out.println(result > 0 ? "COMPILE OK" : "COMPILE FAILED");
        	log.end(result > 0);
        	
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}

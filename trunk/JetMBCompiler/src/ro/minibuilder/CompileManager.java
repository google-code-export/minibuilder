package ro.minibuilder;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.HashMap;

import flex2.tools.oem.Application;
import flex2.tools.oem.Configuration;
import flex2.tools.oem.Logger;
import flex2.tools.oem.Message;
import flex2.tools.oem.ProgressMeter;

public class CompileManager {
	
	private static CompileManager inst;
	private static boolean verbose = true;
	private HashMap<String, AppJob> apps = new HashMap<String, AppJob>();

	//singleton
	private CompileManager() {}
	public static CompileManager inst()
	{
		if (inst == null) inst = new CompileManager();
		return inst;
	}
	
	public String getLog(String key)
	{
		if (!apps.containsKey(key)) return null;
		return apps.get(key).getLog();
	}
	
	public String compile(XML cmd, ProgressMeter progress)
	{
    	String mainApplication = cmd.attribute("mainApplication");
        String config = cmd.child("config").content(); //configuration is mandatory
        String outPath = cmd.attribute("out");
        String sc = cmd.attribute("clean");
        boolean clean = "yes".equals(sc) || "1".equals(sc);
		
        if (mainApplication == null)
        {
    		System.err.println("Error: No mainApplication attribute in xml");
    		return null;
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
        	String key = mainAppFile.getCanonicalPath();
        	if (clean)
        	{
            	if (verbose)
            		System.out.println("clean");
        		apps.remove(key);
        		new File(outPath).delete();
        	}
	        	
        	AppJob job;
        	if (apps.containsKey(key))
        	{
            	if (verbose)
            		System.out.println("incremental");
        		job = apps.get(key);
        	}
        	else
        	{
            	if (verbose)
            		System.out.println("new application");
	            job = new AppJob(new Application(mainAppFile));
	            apps.put(key, job);
        	}
            job.app.setProgressMeter(progress);
	            
            //compilations one at the time on the same project
        	synchronized (job) {
	            
        		if (!config.equals(job.config))
        		{
	            	if (verbose)
	            		System.out.println("config:" + config);
	            	job.config = config;
	            	
	            	config = config.replace("$sdk/", System.getProperty("application.home") + "/");
	            	File tmpFile = File.createTempFile("mbcompiler", ".xml");
	            	BufferedWriter bw = new BufferedWriter(new FileWriter(tmpFile));
	            	bw.write(config);
	            	bw.close();
	            	
		            Configuration conf = job.app.getDefaultConfiguration();
		            conf.addConfiguration(tmpFile);
		            job.app.setConfiguration(conf);
	            }
	            
	            File outFile = new File(outPath);
	            File outDir = new File(outFile.getParent());
	            if (!outDir.isDirectory() && !outDir.mkdirs())
	       		{
	            	if (verbose)
	                    System.out.println("COMPILE FAILED");
	            	job.log("The output directory cannot be created.", -1, -1, "error", "", -1);
	            	progress.end();
	            	return job.getLog();
	            }
		    	
	            job.app.setOutput(outFile);
	            
	            long result = job.app.build(true);
	        	if (verbose)
	                System.out.println(result > 0 ? "COMPILE OK" : "COMPILE FAILED");
	        	
	        	return (result > 0 ? "compile-ok\n" : "") + job.getLog();
        	}
        	
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
	}
}


class AppJob implements Logger
{
	public AppJob(Application app) {
		this.app = app;
		app.setLogger(this);
	}
	
	public Application app;
	public String config;
	private StringBuffer logBuff = new StringBuffer();
	
    public void log(String message, int line, int col, String level, String path, int errorCode)
    {
    	char sep = '|';
    	logBuff.append(String.valueOf(errorCode)); logBuff.append(sep);
    	logBuff.append(line); logBuff.append(sep);
    	logBuff.append(col); logBuff.append(sep);
    	logBuff.append(level); logBuff.append(sep);
    	logBuff.append(path); logBuff.append(sep);
    	logBuff.append(message + "\n");
    	System.out.println(message);
    }
    
	public void log(Message msg, int errorCode, String source) {
		log(msg.toString(), msg.getLine(), msg.getColumn(), msg.getLevel(), msg.getPath(), errorCode);
	}
	
	public String getLog()
	{
		if (logBuff.length() == 0) return null;
		String str = logBuff.toString();
		logBuff = new StringBuffer();
		return str;
	}
}

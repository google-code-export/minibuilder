package ro.minibuilder;

//java/SimpleLogger.java
import flex2.tools.oem.Message;
import flex2.tools.oem.Logger;
import flex2.tools.oem.ProgressMeter;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;

public class MBLogger implements Logger, ProgressMeter
{
	private File file;
	private String messages;
	private String status;
	
    MBLogger(String file) 
    {
        this.file = new File(file);
        messages = "";
        status = "0";
    }
    
    public void log(String message, int line, int col, String level, String path, int errorCode)
    {
    	char sep = '|';
    	messages += String.valueOf(errorCode) + sep +
			line + sep +
			col + sep +
			level + sep +
			path + sep +
			message + "\n";
    	writeDelayed();
    }
    public void log(Message msg, int errorCode, String source) 
    {
    	log(msg.toString(), msg.getLine(), msg.getColumn(), msg.getLevel(), msg.getPath(), errorCode);
    }
    
    public void writeDelayed()
    {
    	if (new Date().getTime() - lastWrite > 100)
    		write();
    }
    
    long lastWrite;
    
    public void write()
    {
    	lastWrite = new Date().getTime();
    	try {
			BufferedWriter bw = new BufferedWriter(new FileWriter(file));
			bw.write(status + "\n" + messages);
			bw.close();
		} catch (IOException e) {
			System.out.println("log retry");
			try { Thread.sleep(50);	} catch (InterruptedException e1) { }
			write();
		}
    }
    
	@Override
	public void end() {
	}
	@Override
	public void percentDone(int percent) {
		status = String.valueOf(percent);
		writeDelayed();
	}
	@Override
	public void start() {
	}
	
	public void end(boolean ok)
	{
		status = ok ? "end-ok" : "end-failed";
		write();
	}
}

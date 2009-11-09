package ro.minibuilder;

import java.io.File;
import java.util.HashSet;

import net.contentobjects.jnotify.IJNotify;
import net.contentobjects.jnotify.JNotifyException;
import net.contentobjects.jnotify.JNotifyListener;

public class PollNotify implements IJNotify 
{
	
	private static boolean stop = false;
	private static JNotifyListener listener = null;
	//poll interval, miliseconds
	private static int pollInterval = 100;
	
	public int addWatch(String path, int mask, boolean watchSubtree, JNotifyListener listener) throws JNotifyException 
	{
		if (PollNotify.listener != null)
			throw new RuntimeException("Only one listener supported");
		
		PollNotify.listener = listener;
		startWatch(path);
		return 0;
	}

	public boolean removeWatch(int arg0) throws JNotifyException 
	{
		stop = true;
		return true;
	}
	
	private void startWatch(String path)
	{
		final File file = new File(path);
		
		
		(new Thread(){
			
			public void run() 
			{
				HashSet<String> files = null;
				while (true)
				{
					if (stop)
					{
						stop = false;
						return;
					}
					
					try {
						Thread.sleep(pollInterval);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					
					
					HashSet<String> files0 = files;
					files = new HashSet<String>();
					
					for (File f : file.listFiles())
						files.add(f.getName());
	
					if (files0 != null)
					{
						for (String name : files)
							if (!files0.contains(name))
							{
								//new file
								listener.fileCreated(0, file.getPath(), name);
							}
					}
				}
			}
		}).start();
	}
}

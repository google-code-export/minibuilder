package ro.minibuilder;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class XML implements Iterable<XML>
{
	public static XML create(InputStream is)
	{
		try
		{
			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = builderFactory.newDocumentBuilder();
			Document document = builder.parse(is);
			Element rootElement = document.getDocumentElement();
			return new XML(rootElement);
		}
		catch(Exception exception)
		{
			throw new RuntimeException(exception);
		}
		finally
		{
			if(is!=null)
			{
				try
				{
					is.close();
				}
				catch(Exception exception)
				{
					throw new RuntimeException(exception);
				}
			}
		}
	}
	
	private XML(Element element)
	{
		name = element.getNodeName();
		
		//get text content
		StringBuilder text = new StringBuilder();
        NodeList chars = element.getChildNodes();
        int len = chars.getLength();
        for (int k=0; k<len; k++)
            text.append(chars.item(k).getNodeValue());
		content = text.toString();
		
		
		NamedNodeMap namedNodeMap = element.getAttributes();
		int n = namedNodeMap.getLength();
		for(int i=0;i<n;i++)
		{
			Node node = namedNodeMap.item(i);
			nameAttributes.put(node.getNodeName(), node.getNodeValue());
		}		
		NodeList nodes = element.getChildNodes();
		n = nodes.getLength();
	    for(int i=0;i<n;i++)
	    {
	    	Node node = nodes.item(i);
	    	int type = node.getNodeType();
	    	if(type==Node.ELEMENT_NODE) addChild(new XML((Element)node));
	    }
	}
	
	private void addChild(XML child)
	{
		List<XML> children = nameChildren.get(child.name);
		if(children==null)
		{
			children = new ArrayList<XML>();
			nameChildren.put(child.name, children);
		}
		children.add(child);
	}
	
	public String name()
	{
		return name;
	}
	
	public String content()
	{
		return content;
	}
	
	public XML child(String name)
	{
		List<XML> children = children(name);
		if(children.size() == 0) return null; 
		return children.get(0);
	}
	
	public List<XML> children(String name)
	{
		List<XML> children = nameChildren.get(name);
		return children==null ? new ArrayList<XML>() : children;			
	}
	
	public List<XML> children()
	{
		ArrayList<XML> list = new ArrayList<XML>();
		for (String name : nameChildren.keySet())
			list.addAll(nameChildren.get(name));
		return list;
	}
	
	public Iterator<XML> iterator() 
	{
		return children().iterator();
	}
	
	public String attribute(String name)
	{
		String value = nameAttributes.get(name);
		return value;
	}
	
	public Map<String,String> attributes()
	{
		return nameAttributes;
	}
	
	@Override
	public String toString() {
		return content();
	}
	
	private String name;
	private String content;
	private Map<String,String> nameAttributes = new HashMap<String,String>();
	private Map<String,List<XML>> nameChildren = new HashMap<String,List<XML>>();
}
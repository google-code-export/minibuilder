/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.main
{


import flash.display.InteractiveObject;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.net.SharedObject;

import org.aswing.AsWingConstants;
import org.aswing.BorderLayout;
import org.aswing.EmptyLayout;
import org.aswing.FlowLayout;
import org.aswing.Icon;
import org.aswing.Insets;
import org.aswing.JButton;
import org.aswing.JClosableTabbedPane;
import org.aswing.JComboBox;
import org.aswing.JLabel;
import org.aswing.JPanel;
import org.aswing.JProgressBar;
import org.aswing.JScrollPane;
import org.aswing.JSplitPane;
import org.aswing.Viewportable;
import org.aswing.border.EmptyBorder;
import org.aswing.event.TabCloseEvent;
import org.aswing.geom.IntDimension;

import ro.mbaswing.OptionPane;
import ro.minibuilder.main.editor.EditorMap;
import ro.minibuilder.main.editor.IEditor;
import ro.minibuilder.main.editor.ITextEditor;

/**
 * MyPane
 */
public class AppPanel extends JPanel
{
	//members
	private var _tree:MBTree;
	private var msgList:MessagesList;

	private var lbl1:JLabel;
	
	
	public var progressBar:JProgressBar;

	private var targetCmb:JComboBox;	
	private var tabs:JClosableTabbedPane;
	
	private var buttonsPane:JPanel;
	
	public function refreshButtons():void
	{
		var so:SharedObject = SharedObject.getLocal('buttons');
		var buttons:Array = so.data.buttons ? so.data.buttons : [];
		
		buttonsPane.removeAll();
		
		for each (var nm:String in buttons)
		{
			(function(nm:String):void {
				var btn:JButton;
				buttonsPane.append(btn = new JButton(nm));
				//btn.setToolTipText('Save File [Ctrl+S]');
				btn.addActionListener(function():void {
					ActionManager.inst['do'+nm]();
				});
			})(nm);
		}
	}
	
	/**
	 * MyPane Constructor
	 */
	public function AppPanel()
	{
		//component creation
		setSize(new IntDimension(300, 300));
		var border0:EmptyBorder = new EmptyBorder(null, new Insets(3,3,3,3));
		setBorder(border0);
		var layout2:BorderLayout = new BorderLayout();
		setLayout(layout2);

		//button list
		buttonsPane = new JPanel(new FlowLayout);
		var btn:JButton;
		
		refreshButtons();
		
		
		/*pan.append(btn = new JButton('Save'));
		btn.setToolTipText('Save File [Ctrl+S]');
		btn.addActionListener(function():void {
			ActionManager.inst.doSave();
		})
		
		pan.append(btn = new JButton('Compile and Fun'));
		btn.setToolTipText('Compile and Run [F8]');
		btn.addActionListener(function():void {
			ActionManager.inst.doCompile();
		})
		
		pan.append(btn = new JButton('Search'));
		btn.setToolTipText('Search [F3 | Ctrl+K]');
		btn.addActionListener(function():void {
			ActionManager.inst.doSearchNext();
		})
		
		pan.append(btn = new JButton('In-Project Search'));
		btn.setToolTipText('Search for a file [Ctrl+R]');
		btn.addActionListener(function():void {
			ActionManager.inst.doProjectSearch();
		})
		
		pan.append(btn = new JButton('Goto Line'));
		btn.setToolTipText('Goto line number [Ctrl+L]');
		btn.addActionListener(function():void {
			ActionManager.inst.doGotoLine();
		})
		
		pan.append(btn = new JButton('About MiniBuilder'));
		btn.addActionListener(function():void {new AboutDialog().show()});*/
		
		
		//top right
		var toppan:JPanel = new JPanel(new BorderLayout);
		toppan.append(buttonsPane, BorderLayout.CENTER);
		
		var pan:JPanel;
		
		pan = new JPanel(new EmptyLayout);
		pan.setSize(new IntDimension(200, 18));
		
		lbl1 = new JLabel('');
		lbl1.setPreferredWidth(200);
		lbl1.setHorizontalAlignment(JLabel.RIGHT);
		lbl1.setSize(new IntDimension(173, 22));
		lbl1.setLocationXY(0, 3);
		pan.append(lbl1);
		
		progressBar = new JProgressBar;
		progressBar.setSize(new IntDimension(100, 12));
		progressBar.setLocationXY(75, 8);
		progressBar.visible = false;
		pan.append(progressBar);

		toppan.append(pan, BorderLayout.EAST);
		append(toppan, BorderLayout.NORTH);
		
		
		
		tabs = new JClosableTabbedPane;
		tabs.addEventListener(TabCloseEvent.TAB_CLOSING, function(e:TabCloseEvent):void {
			checkCloseEditor(e.getIndex());
		});
		
		tabs.addStateListener(function():void {
			if (noTabChangeDisplatch) return;
			else dispatchEvent(new Event('selectedEditor'));
		});
		
		var split1:JSplitPane = new JSplitPane(AsWingConstants.VERTICAL, true, 
			tabs,
			new JScrollPane(msgList = new MessagesList));
		split1.setResizeWeight(1);
		split1.setDividerLocation(-50);
		
		var split:JSplitPane = new JSplitPane(AsWingConstants.HORIZONTAL, true, new JScrollPane(_tree = new MBTree), split1);
		_tree.setMinimumWidth(150);
		split.setResizeWeight(0);
		split.setDividerLocation(200);
		append(split);
	}
	
	public function resetMarkers():void
	{
		for (var i:int=0; i<tabs.getComponentCount(); i++)
		{
			var ed:ITextEditor = getEditorAt(i) as ITextEditor;
			if (ed)
				ed.markLines([], []);
		}
	}
	
	public function listUnsaved():Vector.<String>
	{
		var a:Vector.<String> = new Vector.<String>;
		for (var i:int=0; i<tabs.getComponentCount(); i++)
		{
			var ed:ITextEditor = getEditorAt(i) as ITextEditor;
			if (ed && ed.changed)
				a.push(ed.filePath);
		}
		return a;
	}
	
	public function checkCloseCrtEditor():void
	{
		checkCloseEditor(tabs.getSelectedIndex());
	}
	
	private function checkCloseEditor(index:int):void
	{
		if (getEditorAt(index).changed)
		{
			OptionPane.showMessageDialog('Save', 'Your file has unsaved changes.\nSave changes before closing?',
				function(result:int):void 
				{
					if (result & OptionPane.CANCEL)
						return;
					if (result & OptionPane.YES)
						ActionManager.inst.doSave();
					closeTab(index);
				}, null, true, null, OptionPane.YES|OptionPane.NO|OptionPane.CANCEL
			);
		}
		else
			closeTab(index);
	}
	
	private function closeTab(index:int):void
	{
		tabs.removeTabAt(index);
		tabs.setSelectedIndex(0);
		tree.setSelectionPath(null);
		
		stage.focus = crtEditor as InteractiveObject;
	}
	
	private var noTabChangeDisplatch:Boolean = false;
	
	public function getEditor(fullpath:String):IEditor
	{
		//lookup
		for (var i:int=0; i<tabs.getComponentCount(); i++)
		{
			var editor:IEditor = getEditorAt(i);
			if (editor && editor.filePath == fullpath)
			{
				tabs.setSelectedIndex(i);
				return editor;
			}
		}
		return null;
	}
	
	
	public function newEditor(title:String, clazz:Class, fullpath:String, isDir:Boolean):IEditor
	{
		var editor:IEditor = new clazz;
		var icon:Icon = isDir ? Skins.icnFolder() : EditorMap.getIcon(fullpath);
		tabs.appendTab(new JScrollPane(editor), title, icon, fullpath);
		tabs.setSelectedIndex(tabs.getComponentCount()-1);
		editor.filePath = fullpath;
		
		editor.addEventListener('status', onEditorStatus, false, 0, true);
		return editor;
	}
	
	private function getEditorAt(i:int):IEditor
	{
		var vp:Viewportable = (tabs.getComponent(i) as JScrollPane).getViewport();
		var editor:IEditor = vp is IEditor ? (vp as IEditor) : ((tabs.getComponent(i) as JScrollPane).getViewportView() as IEditor);
		return editor;
	}
	
	public function get crtEditor():IEditor
	{
		if (!tabs.getSelectedComponent()) return null;
		var vp:Viewportable = (tabs.getSelectedComponent() as JScrollPane).getViewport();
		var editor:IEditor = vp is IEditor ? (vp as IEditor) : ((tabs.getSelectedComponent() as JScrollPane).getViewportView() as IEditor);
		return editor;
	}
	
	private function onEditorStatus(e:Event):void
	{
		var editor:IEditor = crtEditor;
		if (e.target != editor) return;
		
		lbl1.setText(editor.status);
		progressBar.setValue(editor.percentReady*100);
		progressBar.visible = editor.percentReady < 1;
	}

	public function get tree():MBTree
	{
		return _tree;
	}
	
	public function get messages():MessagesList
	{
		return msgList;
	}
	
	private var _fileName:String = 'Main.as';

	public function get fileName():String
	{
		return _fileName;
	}
	
	public function setTarget(target:String):void
	{
		if (target == 'aswing')
		{
			targetCmb.setSelectedIndex(1);
			ExternalInterface.call('setPlayTarget', 'aswing');
		}
		else
		{
			targetCmb.setSelectedIndex(0);
			ExternalInterface.call('setPlayTarget', 'swf');
		}
	}
	
	public function set status(msg:String):void
	{
		lbl1.setText(msg);
	}
}
}
